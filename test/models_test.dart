import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/src/models/user.dart';
import 'package:zplit/src/models/split.dart';
import 'package:zplit/src/models/expense.dart';

void main() {
  group('Instantiation', () {
    test('User model instantiates correctly', () {
      final user = User(id: 'u1', name: 'Alice');
      expect(user.id, 'u1');
      expect(user.name, 'Alice');
    });

    test('Split model instantiates correctly', () {
      final split = Split(userId: 'u1', amount: 5000);
      expect(split.userId, 'u1');
      expect(split.amount, 5000);
    });

    test('Expense model instantiates correctly', () {
      final split = Split(userId: 'u2', amount: 10000);
      final expense = Expense(
        id: 'e1',
        title: 'Dinner',
        amount: 10000,
        payerId: 'u1',
        date: DateTime(2023, 1, 1),
        splits: [split],
      );
      expect(expense.id, 'e1');
      expect(expense.title, 'Dinner');
      expect(expense.splits.length, 1);
    });
  });

  group('Value Semantics', () {
    test('User value semantics', () {
      final u1 = User(id: '1', name: 'Alice', email: 'a@a.com');
      final u2 = User(id: '1', name: 'Alice', email: 'a@a.com');
      final u3 = User(id: '2', name: 'Bob');

      expect(u1 == u2, isTrue);
      expect(u1.hashCode == u2.hashCode, isTrue);
      expect(u1 == u3, isFalse);
    });

    test('Split value semantics', () {
      final s1 = Split(userId: 'u1', amount: 5000);
      final s2 = Split(userId: 'u1', amount: 5000);
      final s3 = Split(userId: 'u2', amount: 5000);
      final s4 = Split(userId: 'u1', amount: 4000);

      expect(s1 == s2, isTrue);
      expect(s1.hashCode == s2.hashCode, isTrue);
      expect(s1 == s3, isFalse);
      expect(s1 == s4, isFalse);
    });

    test('Expense value semantics', () {
      final date = DateTime(2023, 1, 1);
      final e1 = Expense(
        id: 'e1', title: 'Food', amount: 10000, payerId: 'u1', date: date,
        splits: [Split(userId: 'u1', amount: 5000), Split(userId: 'u2', amount: 5000)],
      );
      final e2 = Expense(
        id: 'e1', title: 'Food', amount: 10000, payerId: 'u1', date: date,
        splits: [Split(userId: 'u1', amount: 5000), Split(userId: 'u2', amount: 5000)],
      );
      final e3 = Expense(
        id: 'e2', title: 'Food', amount: 10000, payerId: 'u1', date: date,
        splits: [Split(userId: 'u1', amount: 5000), Split(userId: 'u2', amount: 5000)],
      );

      expect(e1 == e2, isTrue);
      expect(e1.hashCode == e2.hashCode, isTrue);
      expect(e1 == e3, isFalse);
    });
  });
}
