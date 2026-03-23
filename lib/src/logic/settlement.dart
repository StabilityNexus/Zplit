class Transaction {
  final String fromUserId;
  final String toUserId;
  final int amount;

  Transaction({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  @override
  String toString() {
    return 'Transaction(from: $fromUserId, to: $toUserId, amount: $amount)';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          fromUserId == other.fromUserId &&
          toUserId == other.toUserId &&
          amount == other.amount;

  @override
  int get hashCode => fromUserId.hashCode ^ toUserId.hashCode ^ amount.hashCode;
}

class Settlement {
  /// Calculates the minimum transactions required to settle all balances.
  static List<Transaction> calculateSettlement(Map<String, int> balances) {
    List<Transaction> transactions = [];

    // Separate into debtors (negative balance) and creditors (positive balance)
    List<MapEntry<String, int>> debtors = balances.entries
        .where((e) => e.value < 0)
        .map((e) => MapEntry(e.key, -e.value)) // make amount positive
        .toList();
    List<MapEntry<String, int>> creditors = balances.entries
        .where((e) => e.value > 0)
        .toList();

    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    int i = 0; // index for debtors
    int j = 0; // index for creditors

    while (i < debtors.length && j < creditors.length) {
      String debtorId = debtors[i].key;
      int debt = debtors[i].value;

      String creditorId = creditors[j].key;
      int credit = creditors[j].value;

      int minAmount = debt < credit ? debt : credit;

      transactions.add(Transaction(
        fromUserId: debtorId,
        toUserId: creditorId,
        amount: minAmount,
      ));

      debtors[i] = MapEntry(debtorId, debt - minAmount);
      creditors[j] = MapEntry(creditorId, credit - minAmount);

      if (debtors[i].value < 1) i++;
      if (creditors[j].value < 1) j++;
    }

    return transactions;
  }
}
