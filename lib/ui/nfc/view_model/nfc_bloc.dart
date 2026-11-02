import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/core/services/nfc_service.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';

class NfcBloc extends Bloc<NfcEvent, NfcState> {
  final NfcService _nfcService;

  NfcBloc({NfcService? nfcService})
    : _nfcService = nfcService ?? NfcService(),
      super(const NfcState()) {
    on<NfcToggled>(_onToggled);
    on<NfcSendPayload>(_onSendPayload);
    on<NfcStartListening>(_onStartListening);
    on<NfcReset>(_onReset);
  }

  Future<void> _onToggled(NfcToggled event, Emitter<NfcState> emit) async {
    if (event.enabled) {
      final available = await _nfcService.isAvailable();
      if (!available) {
        emit(
          state.copyWith(
            enabled: false,
            errorMessage: 'NFC not available on this device',
          ),
        );
        return;
      }
    }
    emit(state.copyWith(enabled: event.enabled, clearError: true));
  }

  Future<void> _onSendPayload(
    NfcSendPayload event,
    Emitter<NfcState> emit,
  ) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      await _nfcService.shareViaNfc(event.payload);
      emit(state.copyWith(isBusy: false));
    } catch (e) {
      emit(state.copyWith(isBusy: false, errorMessage: 'NFC send failed: $e'));
    }
  }

  Future<void> _onStartListening(
    NfcStartListening event,
    Emitter<NfcState> emit,
  ) async {
    emit(state.copyWith(isBusy: true, clearError: true));
    try {
      final payload = await _nfcService.receiveViaNfc();
      if (payload == null) {
        emit(
          state.copyWith(
            isBusy: false,
            errorMessage: 'No readable data found on tap',
          ),
        );
        return;
      }
      emit(state.copyWith(isBusy: false, lastReceivedPayload: payload));
    } catch (e) {
      emit(
        state.copyWith(isBusy: false, errorMessage: 'NFC receive failed: $e'),
      );
    }
  }

  void _onReset(NfcReset event, Emitter<NfcState> emit) {
    emit(state.copyWith(clearError: true, clearReceived: true));
  }
}
