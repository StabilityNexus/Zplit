import 'package:zplit/domain/models/balance/balance_model.dart';

abstract class BalanceState {}

class BalanceInitial extends BalanceState {}

class BalanceLoading extends BalanceState {}

class BalanceLoaded extends BalanceState {
  final List<BalanceModel> balances;
  BalanceLoaded(this.balances);
}

class BalanceError extends BalanceState {
  final String message;
  BalanceError(this.message);
}
