part of 'expenses_bloc.dart';

sealed class ExpensesEvent {}

final class ExpensesStarted extends ExpensesEvent {}

final class ExpensesFilterApplied extends ExpensesEvent {
  final ExpenseFilter filter;
  ExpensesFilterApplied(this.filter);
}
