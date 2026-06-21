import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/users/widgets/friendtile.dart';

UserModel _user({
  String key = '0xABC',
  String name = 'Alice',
  String? picture,
}) => UserModel(
  publicKey: key,
  displayName: name,
  cryptoAddress: key,
  profilePicture: picture,
  defaultCurrency: '₹',
);

BalanceModel _balance({
  String key = '0xABC',
  int amount = 100,
  String currency = '₹',
}) => BalanceModel(
  userPublicKey: key,
  netAmount: amount,
  currency: currency,
  updatedAt: DateTime(2024, 6, 15),
);

Widget _wrap(Widget child) => MaterialApp(
  onGenerateRoute: AppRouter.onGenerateRoute,
  home: Scaffold(body: child),
);

void main() {
  group('FriendTile – rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.byType(FriendTile), findsOneWidget);
    });

    testWidgets('shows display name', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(name: 'Bob'),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows first letter of name as avatar when no picture', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(name: 'Charlie'),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('shows "?" as avatar when display name is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(name: ''),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('shows formatted date when balance is present', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(), // updatedAt: 2024-06-15
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('15 Jun'), findsOneWidget);
    });

    testWidgets('hides date when balance is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );

      expect(find.text('15 Jun'), findsNothing);
    });
  });

  group('FriendTile – amount labels', () {
    testWidgets('shows "Settled up" when netAmount is 0', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 0),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('Settled up'), findsOneWidget);
    });

    testWidgets('shows "Settled up" when balance is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: null,
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('Settled up'), findsOneWidget);
    });

    testWidgets('shows "Owes you:" when netAmount is positive', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 500),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('Owes you:'), findsOneWidget);
    });

    testWidgets('shows correct amount when positive', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 500),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('₹500'), findsOneWidget);
    });

    testWidgets('shows "You owe:" when netAmount is negative', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: -200),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('You owe:'), findsOneWidget);
    });

    testWidgets('shows absolute amount when negative', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: -200),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      // Shows 200, not -200
      expect(find.text('₹200'), findsOneWidget);
      expect(find.text('₹-200'), findsNothing);
    });

    testWidgets('hides amount text when settled', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 0),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('₹0'), findsNothing);
    });

    testWidgets('shows correct currency symbol from balance', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 300, currency: '\$'),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      expect(find.text('\$300'), findsOneWidget);
    });
  });

  group('FriendTile – navigation', () {
    testWidgets('tapping tile does not crash', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FriendTile(
            user: _user(),
            balance: _balance(amount: 100),
            currentUserPublicKey: '0xME',
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();
      // No crash — navigation attempted
    });
  });
}
