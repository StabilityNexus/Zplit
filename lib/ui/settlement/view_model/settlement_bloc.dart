import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/core/services/settlement_service.dart';
import 'package:zplit/ui/settlement/view_model/settlement_event.dart';
import 'package:zplit/ui/settlement/view_model/settlement_state.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  SettlementBloc() : super(SettlementInitial()) {
    on<SettleRequested>(_onSettleRequested);
    on<SettlementReset>((event, emit) => emit(SettlementInitial()));
  }

  Future<void> _onSettleRequested(
    SettleRequested event,
    Emitter<SettlementState> emit,
  ) async {
    emit(SettlementLaunching());
    try {
      final opened = await SettlementService.launchWalletTransfer(
        recipientAddress: event.friendWalletAddress,
        usdcAmount: event.usdcAmount,
      );

      if (!opened) {
        emit(SettlementNoWalletFound());
        return;
      }

      emit(SettlementLaunched());
    } catch (e) {
      emit(SettlementError(e.toString()));
    }
  }
}
