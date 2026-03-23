import '../models/expense.dart';

class CalculationUtils {
  /// Calculates the net balance for each user across all given expenses.
  /// A positive balance means the user is owed money (creditor).
  /// A negative balance means the user owes money (debtor).
  static Map<String, int> calculateBalances(List<Expense> expenses) {
    Map<String, int> balances = {};

    for (var expense in expenses) {
      balances[expense.payerId] = (balances[expense.payerId] ?? 0) + expense.amount;

      for (var split in expense.splits) {
        balances[split.userId] = (balances[split.userId] ?? 0) - split.amount;
      }
    }

    return balances;
  }
}
