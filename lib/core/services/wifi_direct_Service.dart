import 'dart:async';
import 'dart:math';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

/// Wraps flutter_p2p_connection's host/client split into a single
/// Bluetooth-shaped API. The plugin has no built-in "auto-decide who
/// hosts" behaviour, so this class fakes it with a scan-first,
/// host-as-fallback heuristic: each device briefly scans for an
/// existing Zplit host; if it finds one it joins as a client, if not
/// it becomes the host itself.
///
/// NOTE: flutter_p2p_connection's BLE scan (FlutterP2pClient.startScan)
/// is already scoped to devices running this same plugin's hosts via
/// its own internal/default BLE service UUID — it does NOT return
/// arbitrary nearby Bluetooth devices. `BleDiscoveredDevice.deviceName`
/// is just the peer phone's real Bluetooth device name (e.g. "Sourav's
/// Galaxy S21"), not anything app-controlled. There is no way to set a
/// custom advertised name via createGroup(), so we do NOT filter scan
/// results by name — any device returned by startScan() is already a
/// valid Zplit host to connect to.
///
/// NOTE 2: there is deliberately NO background "glare correction"
/// re-scan on the host side. The plugin's native Android side shares a
/// single underlying manager instance across the whole app process, so
/// spinning up a throwaway FlutterP2pClient probe on a timer and
/// disposing it after each check also tore down THIS host's own BLE
/// advertising and hotspot as a side effect — the host would silently
/// restart every ~10s and never stay connectable long enough for a
/// peer to actually find and connect to it. The initial scan-then-host
/// jitter below (3-4s) is enough to avoid both devices becoming hosts
/// simultaneously in the common 1-to-1 pairing case.
///
/// NOTE 3: on the client side, WifiConnected is emitted as soon as
/// connectWithDevice() succeeds, NOT when streamHotspotState() reports
/// isActive: true. In practice that state stream can be slow or fail
/// to fire its first update reliably, leaving the UI stuck on
/// "searching" even though the connection (and data transfer) is
/// already working underneath. streamReceivedTexts() firing is also
/// treated as proof of connection, as a second safety net.
const String kZplitWifiServiceName = 'ZplitWifiDirect'; // kept for logging only

sealed class ZplitWifiEvent {}

class WifiSearching extends ZplitWifiEvent {}

class WifiConnected extends ZplitWifiEvent {
  final String peerId;
  final String peerName;
  WifiConnected(this.peerId, this.peerName);
}

class WifiDisconnected extends ZplitWifiEvent {
  final String peerId;
  WifiDisconnected(this.peerId);
}

class WifiConnectionError extends ZplitWifiEvent {
  final String message;
  WifiConnectionError(this.message);
}

class WifiPayloadReceived extends ZplitWifiEvent {
  final String fromPeerId;
  final String jsonPayload;
  WifiPayloadReceived(this.fromPeerId, this.jsonPayload);
}

class WifiDirectTransportService {
  final _controller = StreamController<ZplitWifiEvent>.broadcast();
  Stream<ZplitWifiEvent> get events => _controller.stream;

  FlutterP2pHost? _host;
  FlutterP2pClient? _client;

  bool _enabled = false;
  bool _isHost = false;
  String? _connectedPeerId;

  StreamSubscription? _scanSub;
  StreamSubscription? _hotspotStateSub;
  StreamSubscription? _clientListSub;
  StreamSubscription? _receivedTextSub;

  /// Checks and requests everything the plugin needs. Call before
  /// enable() so the caller can surface a clean "permission denied"
  /// state rather than a silent failure deep in the scan/host logic.
  Future<bool> ensurePermissions() async {
    final probe = FlutterP2pHost();
    if (!await probe.checkStoragePermission()) {
      await probe.askStoragePermission();
    }
    if (!await probe.checkP2pPermissions()) {
      await probe.askP2pPermissions();
    }
    if (!await probe.checkBluetoothPermissions()) {
      await probe.askBluetoothPermissions();
    }
    final ok =
        await probe.checkP2pPermissions() &&
        await probe.checkBluetoothPermissions();
    return ok;
  }

  Future<void> ensureServicesEnabled() async {
    final probe = FlutterP2pHost();
    if (!await probe.checkWifiEnabled()) await probe.enableWifiServices();
    if (!await probe.checkLocationEnabled()) {
      await probe.enableLocationServices();
    }
    if (!await probe.checkBluetoothEnabled()) {
      await probe.enableBluetoothServices();
    }
  }

  Future<void> enable(String myDisplayName) async {
    if (_enabled) return;
    _enabled = true;
    _controller.add(WifiSearching());
    await _attemptScanThenHost(myDisplayName);
  }

  Future<void> _attemptScanThenHost(String myDisplayName) async {
    final client = FlutterP2pClient();
    await client.initialize();
    _client = client;

    final jitterMs = 3000 + Random().nextInt(1000); // 3.0-4.0s
    BleDiscoveredDevice? found;

    final completer = Completer<void>();
    final sub = await client.startScan((devices) {
      for (final d in devices) {
        print(
          '[WiFiDirect] discovered: "${d.deviceName}" (${d.deviceAddress})',
        );
      }
      // startScan() is already scoped to flutter_p2p_connection hosts
      // via the plugin's BLE service — anything returned here is a
      // valid Zplit host. No name filtering (see class doc comment).
      if (devices.isNotEmpty && !completer.isCompleted) {
        found = devices.first;
        completer.complete();
      }
    });
    _scanSub = sub;

    await Future.any([
      completer.future,
      Future.delayed(Duration(milliseconds: jitterMs)),
    ]);

    await client.stopScan();

    if (found != null) {
      await _becomeClient(client, found!);
    } else {
      await client.dispose();
      _client = null;
      await _becomeHost(myDisplayName);
    }
  }

  Future<void> _becomeClient(
    FlutterP2pClient client,
    BleDiscoveredDevice device,
  ) async {
    _isHost = false;
    try {
      await client.connectWithDevice(device);
    } catch (e) {
      _controller.add(WifiConnectionError('Connect failed: $e'));
      return;
    }

    // connectWithDevice() completing without throwing IS the connection
    // signal — don't wait on streamHotspotState() to separately confirm
    // isActive, since that stream can be slow or fail to fire its first
    // update reliably. Emit WifiConnected right away.
    if (_connectedPeerId == null) {
      _connectedPeerId = 'host';
      _controller.add(WifiConnected('host', 'Host'));
    }

    _hotspotStateSub = client.streamHotspotState().listen((state) {
      // From here on, only use this stream to detect disconnection —
      // the initial "connected" signal already came from
      // connectWithDevice() succeeding above.
      if (!state.isActive && _connectedPeerId != null) {
        final id = _connectedPeerId!;
        _connectedPeerId = null;
        _controller.add(WifiDisconnected(id));
      }
    });

    _receivedTextSub = client.streamReceivedTexts().listen((text) {
      // Belt-and-suspenders: receiving any payload is undeniable proof
      // we're connected, even if the state stream above was flaky.
      if (_connectedPeerId == null) {
        _connectedPeerId = 'host';
        _controller.add(WifiConnected('host', 'Host'));
      }
      // The client always has exactly one peer — the host.
      _controller.add(WifiPayloadReceived('host', text));
    });
  }

  Future<void> _becomeHost(String myDisplayName) async {
    _isHost = true;
    final host = FlutterP2pHost();
    await host.initialize();
    _host = host;

    final state = await host.createGroup(advertise: true);
    if (state.failureReason != null) {
      _controller.add(
        WifiConnectionError('Could not create group: ${state.failureReason}'),
      );
      return;
    }

    _clientListSub = host.streamClientList().listen((clients) {
      if (clients.isNotEmpty && _connectedPeerId == null) {
        final c = clients.first;
        _connectedPeerId = c.id;
        _controller.add(WifiConnected(c.id, c.username));
      } else if (clients.isEmpty && _connectedPeerId != null) {
        final id = _connectedPeerId!;
        _connectedPeerId = null;
        _controller.add(WifiDisconnected(id));
      }
    });

    _receivedTextSub = host.streamReceivedTexts().listen((text) {
      // streamReceivedTexts() on the host doesn't carry a sender id.
      // Fine for the 1-to-1 case this app targets — best-effort
      // attribution to whichever peer is currently connected.
      _controller.add(WifiPayloadReceived(_connectedPeerId ?? 'client', text));
    });

    // No background re-scan here — see NOTE 2 above. The host just
    // stays up and advertising, waiting for streamClientList() to
    // report a connected peer.
  }

  Future<void> sendPayload(String jsonPayload) async {
    if (_isHost) {
      if (_connectedPeerId == null) {
        throw StateError('No connected peer to send to');
      }
      final ok = await _host!.sendTextToClient(jsonPayload, _connectedPeerId!);
      if (!ok) throw StateError('Send failed');
    } else {
      if (_client == null) {
        throw StateError('No client connection to send over');
      }
      // broadcastText returns void — the plugin gives no success/failure
      // signal on the client side. A thrown exception (e.g. socket
      // closed) is the only way this will ever surface a failure to
      // WifiBloc; a silent no-op send on the plugin's end is
      // structurally invisible from here.
      await _client!.broadcastText(jsonPayload);
    }
  }

  Future<void> _teardownHost() async {
    await _clientListSub?.cancel();
    await _receivedTextSub?.cancel();
    await _host?.removeGroup();
    await _host?.dispose();
    _host = null;
    _connectedPeerId = null;
  }

  Future<void> disable() async {
    if (!_enabled) return;
    _enabled = false;
    await _scanSub?.cancel();
    await _hotspotStateSub?.cancel();
    await _clientListSub?.cancel();
    await _receivedTextSub?.cancel();

    if (_isHost) {
      await _host?.removeGroup();
      await _host?.dispose();
      _host = null;
    } else {
      await _client?.disconnect();
      await _client?.dispose();
      _client = null;
    }
    _connectedPeerId = null;
  }

  void dispose() {
    _controller.close();
  }
}
