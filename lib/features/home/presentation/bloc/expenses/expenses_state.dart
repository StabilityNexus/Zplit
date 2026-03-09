part of 'expenses_bloc.dart';

sealed class ExpensesState {}

final class ExpensesInitial extends ExpensesState {}

final class ExpensesSuccess extends ExpensesState {
  final Map<String, List<ExpenseModel>> expenses;
  final double totalBalance;
  final ExpenseFilter activeFilter;

  ExpensesSuccess({
    required this.expenses,
    required this.totalBalance,
    this.activeFilter = ExpenseFilter.empty,
  });
}
