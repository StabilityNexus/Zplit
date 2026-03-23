import 'split.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String payerId;
  final DateTime date;
  final List<Split> splits;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerId,
    required this.date,
    required this.splits,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Expense{id: $id, title: $title, amount: $amount, payerId: $payerId, splits: ${splits.length}}';
  }
}
