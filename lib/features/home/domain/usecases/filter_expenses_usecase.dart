import '../entities/expense_filter.dart';
import '../../data/models/expense_model.dart';

class FilterExpensesUseCase {
  const FilterExpensesUseCase();

  Map<String, List<ExpenseModel>> call(
    Map<String, List<ExpenseModel>> expenses,
    ExpenseFilter filter,
  ) {
    if (!filter.isActive) return expenses;

    final result = <String, List<ExpenseModel>>{};
    for (final entry in expenses.entries) {
      final filtered = entry.value.where((e) => _matches(e, filter)).toList();
      if (filtered.isNotEmpty) result[entry.key] = filtered;
    }
    return result;
  }

  bool _matches(ExpenseModel e, ExpenseFilter f) {
    if (f.owesYou != null && e.owesYou != f.owesYou) return false;
    if (f.minAmount != null && e.amount < f.minAmount!) return false;
    if (f.maxAmount != null && e.amount > f.maxAmount!) return false;
    if (f.fromDate != null && e.date.isBefore(f.fromDate!)) return false;
    if (f.toDate != null && e.date.isAfter(f.toDate!)) return false;
    return true;
  }
}
