import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/src/models/expense.dart';
import 'package:zplit/src/models/split.dart';
import 'package:zplit/src/utils/validation_utils.dart';

void main() {
  test('Valid expense returns no errors', () {
    final expense = Expense(
      id: '1', title: 'Food', amount: 100.0, payerId: 'u1', date: DateTime.now(),
      splits: [Split(userId: 'u1', amount: 40.0), Split(userId: 'u2', amount: 60.0)],
    );
    final errors = ValidationUtils.validateExpense(expense);
    expect(errors, isEmpty);
  });

  test('Invalid expense amount returns error', () {
    final expense = Expense(
      id: '2', title: 'Food', amount: -10.0, payerId: 'u1', date: DateTime.now(),
      splits: [Split(userId: 'u1', amount: 40.0)],
    );
    final errors = ValidationUtils.validateExpense(expense);
    expect(errors, contains('Expense amount must be greater than zero.'));
  });

  test('Missing splits returns error', () {
    final expense = Expense(
      id: '3', title: 'Food', amount: 100.0, payerId: 'u1', date: DateTime.now(),
      splits: [],
    );
    final errors = ValidationUtils.validateExpense(expense);
    expect(errors, contains('An expense must have at least one split.'));
  });

  test('Mismatched split sums returns error', () {
    final expense = Expense(
      id: '4', title: 'Food', amount: 100.0, payerId: 'u1', date: DateTime.now(),
      splits: [Split(userId: 'u1', amount: 50.0), Split(userId: 'u2', amount: 40.0)],
    );
    final errors = ValidationUtils.validateExpense(expense);
    expect(errors, contains(matches(RegExp(r'The sum of splits .* does not match the total expense amount .*'))));
  });
}
