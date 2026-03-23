class Split {
  final String userId;
  final double amount;

  Split({
    required this.userId,
    required this.amount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Split &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          amount == other.amount;

  @override
  int get hashCode => userId.hashCode ^ amount.hashCode;

  @override
  String toString() {
    return 'Split{userId: $userId, amount: $amount}';
  }
}
