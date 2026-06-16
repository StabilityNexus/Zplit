class BalanceModel {
  final String userPublicKey;
  final int netAmount;
  final String currency;
  final String? signed;
  final DateTime updatedAt;

  const BalanceModel({
    required this.userPublicKey,
    required this.netAmount,
    required this.currency,
    this.signed,
    required this.updatedAt,
  });
}
