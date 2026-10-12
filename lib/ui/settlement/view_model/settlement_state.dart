abstract class SettlementState {}

class SettlementInitial extends SettlementState {}

class SettlementLaunching extends SettlementState {}

class SettlementLaunched extends SettlementState {}

class SettlementNoWalletFound extends SettlementState {}

class SettlementError extends SettlementState {
  final String message;
  SettlementError(this.message);
}
