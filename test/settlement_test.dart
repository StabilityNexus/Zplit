import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/src/logic/settlement.dart';

void main() {
  test('Calculates minimum transactions correctly', () {
    // u1 is owed 8000, u2 owes 4000, u3 owes 4000
    Map<String, int> balances = {
      'u1': 8000,
      'u2': -4000,
      'u3': -4000,
    };

    final transactions = Settlement.calculateSettlement(balances);
    
    expect(transactions.length, 2);
    
    // check that u2 and u3 both pay u1
    final payFromU2 = transactions.firstWhere((t) => t.fromUserId == 'u2');
    expect(payFromU2.toUserId, 'u1');
    expect(payFromU2.amount, 4000);

    final payFromU3 = transactions.firstWhere((t) => t.fromUserId == 'u3');
    expect(payFromU3.toUserId, 'u1');
    expect(payFromU3.amount, 4000);
  });
}
