import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/core/services/wifi_direct_Service.dart';

import 'package:zplit/ui/wifi/view_model/Wifi_direct_event.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_state.dart';

class WifiBloc extends Bloc<WifiEvent, WifiState> {
  final WifiDirectTransportService _service;
  StreamSubscription<ZplitWifiEvent>? _sub;

  WifiBloc({WifiDirectTransportService? service})
    : _service = service ?? WifiDirectTransportService(),
      super(const WifiState()) {
    on<WifiToggled>(_onToggled);
    on<WifiSendPayload>(_onSendPayload);
    on<WifiReset>(_onReset);
    on<WifiInternalEvent>(_onInternalEvent);

    _sub = _service.events.listen((e) => add(WifiInternalEvent(e)));
  }

  Future<void> _onToggled(WifiToggled e, Emitter<WifiState> emit) async {
    if (!e.enabled) {
      await _service.disable();
      emit(const WifiState());
      return;
    }

    final granted = await _service.ensurePermissions();
    if (!granted) {
      emit(state.copyWith(permissionDenied: true, enabled: false));
      return;
    }
    await _service.ensureServicesEnabled();

    emit(
      state.copyWith(
        enabled: true,
        permissionDenied: false,
        isSearching: true,
        clearError: true,
      ),
    );
    await _service.enable(e.myDisplayName);
  }

  Future<void> _onSendPayload(
    WifiSendPayload e,
    Emitter<WifiState> emit,
  ) async {
    try {
      await _service.sendPayload(e.jsonPayload);
    } catch (err) {
      emit(state.copyWith(errorMessage: 'Send failed: $err'));
    }
  }

  void _onReset(WifiReset e, Emitter<WifiState> emit) {
    emit(state.copyWith(clearError: true, clearReceived: true));
  }

  void _onInternalEvent(WifiInternalEvent wrapped, Emitter<WifiState> emit) {
    final e = wrapped.rawEvent;
    switch (e) {
      case WifiSearching():
        emit(state.copyWith(isSearching: true));

      case WifiConnected(:final peerId, :final peerName):
        emit(
          state.copyWith(
            isSearching: false,
            isConnected: true,
            peerId: peerId,
            peerName: peerName,
            clearError: true,
          ),
        );

      case WifiDisconnected():
        emit(
          state.copyWith(
            isConnected: false,
            clearPeer: true,
            errorMessage: 'WiFi Direct connection lost',
          ),
        );

      case WifiConnectionError(:final message):
        emit(state.copyWith(errorMessage: message, isSearching: false));

      case WifiPayloadReceived(:final jsonPayload):
        emit(state.copyWith(lastReceivedPayload: jsonPayload));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _service.disable();
    _service.dispose();
    return super.close();
  }
}
