import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/src/models/expense.dart';
import 'package:zplit/src/models/split.dart';
import 'package:zplit/src/utils/calculation_utils.dart';

void main() {
  test('Calculates balances correctly for a single expense', () {
    final expense = Expense(
      id: '1', title: 'Food', amount: 120.0, payerId: 'u1', date: DateTime.now(),
      splits: [
        Split(userId: 'u1', amount: 40.0),
        Split(userId: 'u2', amount: 40.0),
        Split(userId: 'u3', amount: 40.0),
      ],
    );

    final balances = CalculationUtils.calculateBalances([expense]);
    
    // u1 paid 120, owes 40 => +80
    // u2 paid 0, owes 40 => -40
    // u3 paid 0, owes 40 => -40
    expect(balances['u1'], 80.0);
    expect(balances['u2'], -40.0);
    expect(balances['u3'], -40.0);
  });
}
