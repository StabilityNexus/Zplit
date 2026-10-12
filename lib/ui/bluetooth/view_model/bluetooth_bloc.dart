// lib/ui/bluetooth/view_model/bluetooth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/core/services/bluetooth_service.dart';
import 'bluetooth_event.dart';
import 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final BluetoothTransportService _service;
  StreamSubscription<ZplitBtEvent>? _sub;

  BluetoothBloc({BluetoothTransportService? service})
    : _service = service ?? BluetoothTransportService(),
      super(const BluetoothState()) {
    on<BluetoothToggled>(_onToggled);
    on<BluetoothConnectRequested>(_onConnectRequested);
    on<BluetoothConnectionAccepted>(_onConnectionAccepted);
    on<BluetoothConnectionRejected>(_onConnectionRejected);
    on<BluetoothSendPayload>(_onSendPayload);
    on<BluetoothDisconnectRequested>(_onDisconnectRequested);
    on<BluetoothInternalEvent>(_onInternalEvent);

    _sub = _service.events.listen((e) => add(BluetoothInternalEvent(e)));
  }

  Future<void> _onToggled(
    BluetoothToggled e,
    Emitter<BluetoothState> emit,
  ) async {
    if (!e.enabled) {
      await _service.stopAll();
      emit(
        state.copyWith(
          enabled: false,
          nearbyEndpoints: [],
          connectionStatus: {},
        ),
      );
      return;
    }

    final granted = await _service.ensurePermissions();
    if (!granted) {
      emit(state.copyWith(permissionDenied: true, enabled: false));
      return;
    }

    emit(
      state.copyWith(enabled: true, permissionDenied: false, clearError: true),
    );
    await _service.startAdvertising(e.myDisplayName);
    await _service.startDiscovery(e.myDisplayName);
  }

  Future<void> _onConnectRequested(
    BluetoothConnectRequested e,
    Emitter<BluetoothState> emit,
  ) async {
    final statuses = Map<String, BtConnectionStatus>.from(
      state.connectionStatus,
    );
    statuses[e.endpointId] = BtConnectionStatus.connecting;
    emit(state.copyWith(connectionStatus: statuses));
    await _service.requestConnection(e.myDisplayName, e.endpointId);
  }

  Future<void> _onConnectionAccepted(
    BluetoothConnectionAccepted e,
    Emitter<BluetoothState> emit,
  ) async {
    await _service.acceptConnection(e.endpointId);
  }

  Future<void> _onConnectionRejected(
    BluetoothConnectionRejected e,
    Emitter<BluetoothState> emit,
  ) async {
    await _service.rejectConnection(e.endpointId);
  }

  Future<void> _onSendPayload(
    BluetoothSendPayload e,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      await _service.sendPayload(e.endpointId, e.jsonPayload);
    } catch (err) {
      emit(state.copyWith(errorMessage: 'Send failed: $err'));
    }
  }

  Future<void> _onDisconnectRequested(
    BluetoothDisconnectRequested e,
    Emitter<BluetoothState> emit,
  ) async {
    await _service.disconnect(e.endpointId);
  }

  void _onInternalEvent(
    BluetoothInternalEvent wrapped,
    Emitter<BluetoothState> emit,
  ) {
    final e = wrapped.rawEvent;
    final statuses = Map<String, BtConnectionStatus>.from(
      state.connectionStatus,
    );
    final progressMap = Map<String, double>.from(state.transferProgress);

    switch (e) {
      case BtEndpointFound(:final endpoint):
        final list = [...state.nearbyEndpoints];
        if (!list.any((d) => d.id == endpoint.id)) list.add(endpoint);
        emit(state.copyWith(nearbyEndpoints: list));

      case BtEndpointLost(:final endpointId):
        final list = state.nearbyEndpoints
            .where((d) => d.id != endpointId)
            .toList();
        emit(state.copyWith(nearbyEndpoints: list));

      case BtConnectionInitiated(:final endpointId):
        statuses[endpointId] = BtConnectionStatus.pending;
        emit(state.copyWith(connectionStatus: statuses));
        add(BluetoothConnectionAccepted(endpointId));

      case BtConnected(:final endpointId):
        statuses[endpointId] = BtConnectionStatus.connected;
        emit(state.copyWith(connectionStatus: statuses, clearError: true));

      case BtConnectionRejected(:final endpointId):
        statuses[endpointId] = BtConnectionStatus.none;
        emit(state.copyWith(connectionStatus: statuses));

      case BtConnectionError(:final endpointId, :final message):
        if (endpointId.isNotEmpty) {
          statuses[endpointId] = BtConnectionStatus.none;
        }
        emit(state.copyWith(connectionStatus: statuses, errorMessage: message));

      case BtDisconnected(:final endpointId):
        statuses[endpointId] = BtConnectionStatus.disconnected;
        progressMap.remove(endpointId);
        emit(
          state.copyWith(
            connectionStatus: statuses,
            transferProgress: progressMap,
            errorMessage: 'Connection lost — you can reconnect and resend',
          ),
        );

      case BtPayloadReceived(:final endpointId, :final jsonPayload):
        emit(
          state.copyWith(
            lastReceivedPayload: jsonPayload,
            lastReceivedFromEndpointId: endpointId,
          ),
        );

      case BtTransferProgress(:final endpointId, :final progress):
        progressMap[endpointId] = progress;
        emit(state.copyWith(transferProgress: progressMap));
    }
  }

  void clearReceivedPayload() {
    emit(state.copyWith(clearReceived: true));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _service.stopAll();
    _service.dispose();
    return super.close();
  }
}
