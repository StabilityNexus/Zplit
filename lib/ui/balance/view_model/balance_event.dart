abstract class BalanceEvent {}

class LoadAllBalances extends BalanceEvent {}

class LoadBalancesForUser extends BalanceEvent {
  final String userPublicKey;
  LoadBalancesForUser(this.userPublicKey);
}

class LoadPositiveBalances extends BalanceEvent {}

class LoadNegativeBalances extends BalanceEvent {}

class UpsertBalance extends BalanceEvent {
  final String userPublicKey;
  final int netAmount;
  final String currency;
  final String? signed;

  UpsertBalance({
    required this.userPublicKey,
    required this.netAmount,
    required this.currency,
    this.signed,
  });
}

class DeleteBalance extends BalanceEvent {
  final String userPublicKey;
  DeleteBalance(this.userPublicKey);
}
