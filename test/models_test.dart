import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/src/models/user.dart';
import 'package:zplit/src/models/split.dart';
import 'package:zplit/src/models/expense.dart';

void main() {
  test('User model instantiates correctly', () {
    final user = User(id: 'u1', name: 'Alice');
    expect(user.id, 'u1');
    expect(user.name, 'Alice');
  });

  test('Split model instantiates correctly', () {
    final split = Split(userId: 'u1', amount: 50.0);
    expect(split.userId, 'u1');
    expect(split.amount, 50.0);
  });

  test('Expense model instantiates correctly', () {
    final split = Split(userId: 'u2', amount: 100.0);
    final expense = Expense(
      id: 'e1',
      title: 'Dinner',
      amount: 100.0,
      payerId: 'u1',
      date: DateTime(2023, 1, 1),
      splits: [split],
    );
    expect(expense.id, 'e1');
    expect(expense.title, 'Dinner');
    expect(expense.splits.length, 1);
  });
}
