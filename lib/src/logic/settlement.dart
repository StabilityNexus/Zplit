class Transaction {
  final String fromUserId;
  final String toUserId;
  final double amount;

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
          (amount - other.amount).abs() < 0.01;

  @override
  int get hashCode => fromUserId.hashCode ^ toUserId.hashCode ^ amount.hashCode;
}

class Settlement {
  /// Calculates the minimum transactions required to settle all balances.
  static List<Transaction> calculateSettlement(Map<String, double> balances) {
    List<Transaction> transactions = [];

    // Separate into debtors (negative balance) and creditors (positive balance)
    List<MapEntry<String, double>> debtors = balances.entries
        .where((e) => e.value < -0.01)
        .map((e) => MapEntry(e.key, -e.value)) // make amount positive for easier math
        .toList();
    List<MapEntry<String, double>> creditors = balances.entries
        .where((e) => e.value > 0.01)
        .toList();

    // Sort by largest amounts first for greedy matching
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    int i = 0; // index for debtors
    int j = 0; // index for creditors

    while (i < debtors.length && j < creditors.length) {
      String debtorId = debtors[i].key;
      double debt = debtors[i].value;

      String creditorId = creditors[j].key;
      double credit = creditors[j].value;

      double minAmount = debt < credit ? debt : credit;

      // create a transaction
      transactions.add(Transaction(
        fromUserId: debtorId,
        toUserId: creditorId,
        amount: double.parse(minAmount.toStringAsFixed(2)),
      ));

      // update balances
      debtors[i] = MapEntry(debtorId, debt - minAmount);
      creditors[j] = MapEntry(creditorId, credit - minAmount);

      // move to next if settled
      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return transactions;
  }
}
