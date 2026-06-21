import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/users/widgets/friendlist.dart';

UserModel _user({String key = '0xA', String name = 'Alice'}) => UserModel(
  publicKey: key,
  displayName: name,
  cryptoAddress: key,
  profilePicture: null,
  defaultCurrency: '₹',
);

BalanceModel _balance({
  String key = '0xA',
  int amount = 100,
  DateTime? updatedAt,
}) => BalanceModel(
  userPublicKey: key,
  netAmount: amount,
  currency: '₹',
  updatedAt: updatedAt ?? DateTime(2024, 6, 1),
);

Widget _wrap(Widget child) => MaterialApp(
  onGenerateRoute: AppRouter.onGenerateRoute,
  home: Scaffold(body: child),
);

Widget _friendsList({
  List<UserModel>? users,
  List<BalanceModel>? balances,
  String currentKey = '0xME',
  VoidCallback? onAddFriend,
}) => _wrap(
  FriendsList(
    users: users ?? [],
    balances: balances ?? [],
    currentUserPublicKey: currentKey,
    onAddFriend: onAddFriend ?? () {},
  ),
);

void main() {
  group('FriendsList – rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_friendsList());
      expect(find.byType(FriendsList), findsOneWidget);
    });

    testWidgets('shows "Expenses" header', (tester) async {
      await tester.pumpWidget(_friendsList());
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('shows filter icon', (tester) async {
      await tester.pumpWidget(_friendsList());
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('shows "Add An Expense" button', (tester) async {
      await tester.pumpWidget(_friendsList());
      expect(find.text('Add An Expense'), findsOneWidget);
    });

    testWidgets('calls onAddFriend when button tapped', (tester) async {
      bool called = false;
      await tester.pumpWidget(_friendsList(onAddFriend: () => called = true));
      await tester.tap(find.text('Add An Expense'));
      expect(called, isTrue);
    });

    testWidgets(
      'shows "No results match your filters." when users list is empty',
      (tester) async {
        await tester.pumpWidget(_friendsList());
        expect(find.text('No results match your filters.'), findsOneWidget);
      },
    );

    testWidgets('shows friend names when users provided', (tester) async {
      await tester.pumpWidget(
        _friendsList(
          users: [
            _user(key: '0xA', name: 'Alice'),
            _user(key: '0xB', name: 'Bob'),
          ],
          balances: [
            _balance(key: '0xA', amount: 100),
            _balance(key: '0xB', amount: -50),
          ],
        ),
      );
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows month group header for friends with balance', (
      tester,
    ) async {
      await tester.pumpWidget(
        _friendsList(
          users: [_user()],
          balances: [_balance(updatedAt: DateTime(2024, 6, 1))],
        ),
      );
      expect(find.text('June 2024'), findsOneWidget);
    });

    testWidgets('shows "No activity" group for friends without balance', (
      tester,
    ) async {
      await tester.pumpWidget(
        _friendsList(
          users: [_user()],
          balances: [], // no balance for this user
        ),
      );
      expect(find.text('No activity'), findsOneWidget);
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // Filter sheet – open / close
  // ════════════════════════════════════════════════════════════════════════════

  group('FriendsList – filter sheet open/close', () {
    testWidgets('tapping filter icon opens bottom sheet', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('filter sheet shows Quick Filters section', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Quick Filters'), findsOneWidget);
    });

    testWidgets('filter sheet shows "You owe them" chip', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('You owe them'), findsOneWidget);
    });

    testWidgets('filter sheet shows "They owe you" chip', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('They owe you'), findsOneWidget);
    });

    testWidgets('filter sheet shows Date Range section', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Date Range'), findsOneWidget);
    });

    testWidgets('filter sheet shows date range chips', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Last 14 days'), findsOneWidget);
      expect(find.text('Last 30 days'), findsOneWidget);
      expect(find.text('Last 60 days'), findsOneWidget);
      expect(find.text('Custom date range'), findsOneWidget);
    });

    testWidgets('filter sheet shows Amount Range section', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Amount Range'), findsOneWidget);
    });

    testWidgets('filter sheet shows Apply Filters button', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Apply Filters'), findsOneWidget);
    });

    testWidgets('filter sheet shows Clear All button', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('tapping Apply Filters closes the sheet', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsNothing);
    });

    testWidgets('tapping Clear All closes the sheet', (tester) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();
      expect(find.text('Filters'), findsNothing);
    });
  });

  group('FriendsList – quick filter logic', () {
    testWidgets('"You owe them" filter hides friends with positive balance', (
      tester,
    ) async {
      await tester.pumpWidget(
        _friendsList(
          users: [
            _user(key: '0xA', name: 'Alice'), // positive → they owe me
            _user(key: '0xB', name: 'Bob'), // negative → I owe them
          ],
          balances: [
            _balance(key: '0xA', amount: 100),
            _balance(key: '0xB', amount: -100),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('You owe them'));
      await tester.pump();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsNothing);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('"They owe you" filter hides friends with negative balance', (
      tester,
    ) async {
      await tester.pumpWidget(
        _friendsList(
          users: [
            _user(key: '0xA', name: 'Alice'),
            _user(key: '0xB', name: 'Bob'),
          ],
          balances: [
            _balance(key: '0xA', amount: 100),
            _balance(key: '0xB', amount: -100),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('They owe you'));
      await tester.pump();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Bob'), findsNothing);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('Clear All resets filter and shows all friends again', (
      tester,
    ) async {
      await tester.pumpWidget(
        _friendsList(
          users: [
            _user(key: '0xA', name: 'Alice'),
            _user(key: '0xB', name: 'Bob'),
          ],
          balances: [
            _balance(key: '0xA', amount: 100),
            _balance(key: '0xB', amount: -100),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('You owe them'));
      await tester.pump();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsNothing);

      // Now clear
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Both should be visible again
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });
  });

  group('FriendsList – date filter logic', () {
    testWidgets('"Last 14 days" filter hides old balances', (tester) async {
      final oldDate = DateTime.now().subtract(const Duration(days: 30));
      final recentDate = DateTime.now().subtract(const Duration(days: 5));

      await tester.pumpWidget(
        _friendsList(
          users: [
            _user(key: '0xA', name: 'Alice'),
            _user(key: '0xB', name: 'Bob'),
          ],
          balances: [
            _balance(key: '0xA', amount: 100, updatedAt: oldDate),
            _balance(key: '0xB', amount: 100, updatedAt: recentDate),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 14 days'));
      await tester.pump();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsNothing); // old → filtered out
      expect(find.text('Bob'), findsOneWidget); // recent → shown
    });

    testWidgets('"Custom date range" chip shows From/To date pickers', (
      tester,
    ) async {
      await tester.pumpWidget(_friendsList());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom date range'));
      await tester.pumpAndSettle();
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
    });
  });

  group('FriendsList – amount filter logic', () {
    testWidgets('amount range filters out friends outside range', (
      tester,
    ) async {
      await tester.pumpWidget(
        _friendsList(
          users: [
            _user(key: '0xA', name: 'Alice'), // amount 50 — below range
            _user(key: '0xB', name: 'Bob'), // amount 500 — in range
          ],
          balances: [
            _balance(key: '0xA', amount: 50),
            _balance(key: '0xB', amount: 500),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // Set "From" amount to 100
      final fromFields = find.byType(TextField);
      await tester.enterText(fromFields.first, '100');
      await tester.pump();

      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsNothing); // 50 < 100 → filtered
      expect(find.text('Bob'), findsOneWidget); // 500 >= 100 → shown
    });
  });
}
