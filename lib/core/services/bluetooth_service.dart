import 'dart:async';
import 'dart:convert';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

const String kZplitServiceId = 'com.zplit.aossie.transfer';

class BtEndpoint {
  final String id;
  final String name;
  BtEndpoint(this.id, this.name);
}

sealed class ZplitBtEvent {}

class BtEndpointFound extends ZplitBtEvent {
  final BtEndpoint endpoint;
  BtEndpointFound(this.endpoint);
}

class BtEndpointLost extends ZplitBtEvent {
  final String endpointId;
  BtEndpointLost(this.endpointId);
}

class BtConnectionInitiated extends ZplitBtEvent {
  final String endpointId;
  final String endpointName;
  final String authenticationToken;
  BtConnectionInitiated(
    this.endpointId,
    this.endpointName,
    this.authenticationToken,
  );
}

class BtConnected extends ZplitBtEvent {
  final String endpointId;
  BtConnected(this.endpointId);
}

class BtConnectionRejected extends ZplitBtEvent {
  final String endpointId;
  BtConnectionRejected(this.endpointId);
}

class BtConnectionError extends ZplitBtEvent {
  final String endpointId;
  final String message;
  BtConnectionError(this.endpointId, this.message);
}

class BtDisconnected extends ZplitBtEvent {
  final String endpointId;
  BtDisconnected(this.endpointId);
}

class BtPayloadReceived extends ZplitBtEvent {
  final String endpointId;
  final String jsonPayload;
  BtPayloadReceived(this.endpointId, this.jsonPayload);
}

class BtTransferProgress extends ZplitBtEvent {
  final String endpointId;
  final double progress; // 0.0 - 1.0
  BtTransferProgress(this.endpointId, this.progress);
}

class BluetoothTransportService {
  final Nearby _nearby = Nearby();
  final _controller = StreamController<ZplitBtEvent>.broadcast();
  Stream<ZplitBtEvent> get events => _controller.stream;

  bool _advertising = false;
  bool _discovering = false;

  /// Requests every permission Nearby Connections needs at runtime.
  /// Returns false if the user denies something required — surface this
  /// as BluetoothPermissionDenied in the bloc rather than silently failing.
  Future<bool> ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ].request();

    return statuses.values.every(
      (s) => s.isGranted || s.isLimited || s == PermissionStatus.provisional,
    );
  }

  /// Makes this device discoverable so others can find and connect to it.
  /// [userName] is shown to the other device — use the display name, not
  /// the raw public key.
  Future<void> startAdvertising(String userName) async {
    if (_advertising) return;
    try {
      final ok = await _nearby.startAdvertising(
        userName,
        Strategy.P2P_STAR,
        serviceId: kZplitServiceId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      _advertising = ok;
      if (!ok) {
        _controller.add(BtConnectionError('', 'Could not start advertising'));
      }
    } catch (e) {
      _controller.add(BtConnectionError('', 'Advertising failed: $e'));
    }
  }

  /// Starts scanning for nearby devices advertising the Zplit service.
  Future<void> startDiscovery(String userName) async {
    if (_discovering) return;
    try {
      final ok = await _nearby.startDiscovery(
        userName,
        Strategy.P2P_STAR,
        serviceId: kZplitServiceId,
        onEndpointFound: (id, name, serviceId) {
          _controller.add(BtEndpointFound(BtEndpoint(id, name)));
        },
        onEndpointLost: (id) {
          if (id != null) _controller.add(BtEndpointLost(id));
        },
      );
      _discovering = ok;
      if (!ok) {
        _controller.add(BtConnectionError('', 'Could not start discovery'));
      }
    } catch (e) {
      _controller.add(BtConnectionError('', 'Discovery failed: $e'));
    }
  }

  /// Discoverer side: request a connection to an endpoint found via
  /// startDiscovery.
  Future<void> requestConnection(String myName, String endpointId) async {
    try {
      await _nearby.requestConnection(
        myName,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      _controller.add(BtConnectionError(endpointId, 'Request failed: $e'));
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    _controller.add(
      BtConnectionInitiated(
        id,
        info.endpointName,
        info.authenticationToken ?? '',
      ),
    );
  }

  /// Call after the user confirms (or you auto-confirm) a connection.
  Future<void> acceptConnection(String endpointId) async {
    await _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: (id, payload) {
        if (payload.type == PayloadType.BYTES && payload.bytes != null) {
          final jsonStr = utf8.decode(payload.bytes!);
          _controller.add(BtPayloadReceived(id, jsonStr));
        }
      },
      onPayloadTransferUpdate: (id, update) {
        if (update.totalBytes > 0) {
          _controller.add(
            BtTransferProgress(id, update.bytesTransferred / update.totalBytes),
          );
        }
      },
    );
  }

  Future<void> rejectConnection(String endpointId) async {
    await _nearby.rejectConnection(endpointId);
    _controller.add(BtConnectionRejected(endpointId));
  }

  void _onConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      _controller.add(BtConnected(id));
    } else {
      _controller.add(BtConnectionError(id, 'Connection $status'));
    }
  }

  void _onDisconnected(String id) {
    _controller.add(BtDisconnected(id));
  }

  /// Sends a signed transaction (or invite) payload — same JSON schema
  /// you already use for QR / deep links — as raw bytes over the
  /// established connection.
  Future<void> sendPayload(String endpointId, String jsonPayload) async {
    final bytes = utf8.encode(jsonPayload);
    await _nearby.sendBytesPayload(endpointId, bytes);
  }

  Future<void> disconnect(String endpointId) async {
    await _nearby.disconnectFromEndpoint(endpointId);
  }

  Future<void> stopAdvertising() async {
    if (!_advertising) return;
    await _nearby.stopAdvertising();
    _advertising = false;
  }

  Future<void> stopDiscovery() async {
    if (!_discovering) return;
    await _nearby.stopDiscovery();
    _discovering = false;
  }

  Future<void> stopAll() async {
    await _nearby.stopAllEndpoints();
    _advertising = false;
    _discovering = false;
  }

  void dispose() {
    _controller.close();
  }
}
