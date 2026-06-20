import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/src/models/expense.dart';
import 'package:zplit/src/models/split.dart';
import 'package:zplit/src/utils/calculation_utils.dart';

void main() {
  test('Calculates balances correctly for a single expense', () {
    final expense = Expense(
      id: '1', title: 'Food', amount: 12000, payerId: 'u1', date: DateTime.now(),
      splits: [
        Split(userId: 'u1', amount: 4000),
        Split(userId: 'u2', amount: 4000),
        Split(userId: 'u3', amount: 4000),
      ],
    );

    final balances = CalculationUtils.calculateBalances([expense]);
    
    // u1 paid 12000, owes 4000 => +8000
    // u2 paid 0, owes 4000 => -4000
    // u3 paid 0, owes 4000 => -4000
    expect(balances['u1'], 8000);
    expect(balances['u2'], -4000);
    expect(balances['u3'], -4000);
  });
}
