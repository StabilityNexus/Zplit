import '../models/expense.dart';

class CalculationUtils {
  /// Calculates the net balance for each user across all given expenses.
  /// A positive balance means the user is owed money (creditor).
  /// A negative balance means the user owes money (debtor).
  static Map<String, double> calculateBalances(List<Expense> expenses) {
    Map<String, double> balances = {};

    for (var expense in expenses) {
      // The payer gets credited the total amount they paid.
      balances[expense.payerId] = (balances[expense.payerId] ?? 0) + expense.amount;

      // Each person in the split gets debited their share.
      for (var split in expense.splits) {
        balances[split.userId] = (balances[split.userId] ?? 0) - split.amount;
      }
    }

    return balances;
  }
}
