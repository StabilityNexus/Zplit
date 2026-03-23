import '../models/expense.dart';

class ValidationUtils {
  /// Validates if an expense is configured correctly.
  /// Returns a list of error messages. Empty list means valid.
  static List<String> validateExpense(Expense expense) {
    List<String> errors = [];

    if (expense.amount <= 0) {
      errors.add('Expense amount must be greater than zero.');
    }

    if (expense.splits.isEmpty) {
      errors.add('An expense must have at least one split.');
    } else {
      double totalSplitAmount = 0;
      for (var split in expense.splits) {
        if (split.amount < 0) {
          errors.add('Split amount for user ${split.userId} cannot be negative.');
        }
        totalSplitAmount += split.amount;
      }

      // Check for floating point inaccuracies
      if ((totalSplitAmount - expense.amount).abs() > 0.01) {
        errors.add('The sum of splits ($totalSplitAmount) does not match the total expense amount (${expense.amount}).');
      }
    }

    return errors;
  }
}
