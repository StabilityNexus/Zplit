import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/domain/repositories/balance/balance_repository.dart';
import 'package:zplit/ui/balance/view_models/balance_event.dart';
import 'package:zplit/ui/balance/view_models/balance_state.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final BalanceRepository _balanceRepository;

  BalanceBloc({required BalanceRepository balanceRepository})
    : _balanceRepository = balanceRepository,
      super(BalanceInitial()) {
    on<LoadAllBalances>(_onLoadAllBalances);
    on<LoadBalancesForUser>(_onLoadBalancesForUser);
    on<LoadPositiveBalances>(_onLoadPositiveBalances);
    on<LoadNegativeBalances>(_onLoadNegativeBalances);
    on<UpsertBalance>(_onUpsertBalance);
    on<DeleteBalance>(_onDeleteBalance);
  }

  Future<void> _onLoadAllBalances(
    LoadAllBalances event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceLoading());
    try {
      final balances = await _balanceRepository.getAllBalances();
      emit(BalanceLoaded(balances));
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }

  Future<void> _onLoadBalancesForUser(
    LoadBalancesForUser event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceLoading());
    try {
      final balances = await _balanceRepository.getBalancesForUser(
        event.userPublicKey,
      );
      emit(BalanceLoaded(balances));
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }

  Future<void> _onLoadPositiveBalances(
    LoadPositiveBalances event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceLoading());
    try {
      final balances = await _balanceRepository.getPositiveBalances();
      emit(BalanceLoaded(balances));
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }

  Future<void> _onLoadNegativeBalances(
    LoadNegativeBalances event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceLoading());
    try {
      final balances = await _balanceRepository.getNegativeBalances();
      emit(BalanceLoaded(balances));
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }

  Future<void> _onUpsertBalance(
    UpsertBalance event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceLoading());
    try {
      await _balanceRepository.upsertBalance(
        userPublicKey: event.userPublicKey,
        netAmount: event.netAmount,
        currency: event.currency,
        signed: event.signed,
      );
      final balances = await _balanceRepository.getAllBalances();
      emit(BalanceLoaded(balances));
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }

  Future<void> _onDeleteBalance(
    DeleteBalance event,
    Emitter<BalanceState> emit,
  ) async {
    emit(BalanceLoading());
    try {
      await _balanceRepository.deleteByPublicKey(event.userPublicKey);
      final balances = await _balanceRepository.getAllBalances();
      emit(BalanceLoaded(balances));
    } catch (e) {
      emit(BalanceError(e.toString()));
    }
  }
}
