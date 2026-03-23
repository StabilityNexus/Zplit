import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/src/logic/settlement.dart';

void main() {
  test('Calculates minimum transactions correctly', () {
    // u1 is owed 80, u2 owes 40, u3 owes 40
    Map<String, double> balances = {
      'u1': 80.0,
      'u2': -40.0,
      'u3': -40.0,
    };

    final transactions = Settlement.calculateSettlement(balances);
    
    expect(transactions.length, 2);
    
    // check that u2 and u3 both pay u1
    final payFromU2 = transactions.firstWhere((t) => t.fromUserId == 'u2');
    expect(payFromU2.toUserId, 'u1');
    expect(payFromU2.amount, 40.0);

    final payFromU3 = transactions.firstWhere((t) => t.fromUserId == 'u3');
    expect(payFromU3.toUserId, 'u1');
    expect(payFromU3.amount, 40.0);
  });
}
