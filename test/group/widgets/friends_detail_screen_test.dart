// Widget tests for FriendDetailScreen.
//
// Amounts (balance.netAmount and tx.amount) are stored in paise and rendered
// in rupees with two decimals. The "who paid" label on each row is derived
// from the sign of tx.amount, not from who created the record:
//   amount > 0 -> fromUser owes toUser -> toUser paid
//   amount < 0 -> toUser owes fromUser -> fromUser paid

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:zplit/core/database/tables/transactions_table.dart';
import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/transaction/transaction_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/group/widgets/friends_Detail.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class FakeTransactionEvent extends Fake implements TransactionEvent {}

void main() {
  late MockTransactionBloc transactionBloc;

  setUpAll(() {
    registerFallbackValue(FakeTransactionEvent());
  });

  setUp(() {
    transactionBloc = MockTransactionBloc();
  });

  // ---- Fixtures ----
  final friend = UserModel(
    publicKey: 'friend_pub_key',
    displayName: 'Aanya Shah',
    profilePicture: null,
    defaultCurrency: '₹',
  );

  const currentUser = 'me_pub_key';

  var txCounter = 0;

  /// [amount] is in paise.
  TransactionModel buildTx({
    required String from,
    required String to,
    required int amount,
    String? description,
    String? tag,
    required DateTime createdAt,
    String currency = '₹',
  }) {
    txCounter++;
    return TransactionModel(
      id: 'tx_$txCounter',
      fromUserPublicKey: from,
      toUserPublicKey: to,
      amount: BigInt.from(amount),
      currency: currency,
      status: TransactionStatus.unsigned,
      description: description,
      tag: tag,
      createdAt: createdAt,
    );
  }

  /// [netAmount] is in paise.
  BalanceModel buildBalance({required int netAmount, String currency = '₹'}) {
    return BalanceModel(
      userPublicKey: friend.publicKey,
      netAmount: netAmount,
      currency: currency,
      updatedAt: DateTime(2026, 6, 20),
    );
  }

  Widget buildSubject({BalanceModel? balance}) {
    return BlocProvider<TransactionBloc>.value(
      value: transactionBloc,
      child: MaterialApp(
        home: FriendDetailScreen(
          friend: friend,
          currentUserPublicKey: currentUser,
          balance: balance,
        ),
      ),
    );
  }

  void stub(TransactionState state) {
    whenListen(
      transactionBloc,
      const Stream<TransactionState>.empty(),
      initialState: state,
    );
  }

  group('initial load', () {
    testWidgets('dispatches LoadAllTransactions on init', (tester) async {
      stub(TransactionLoading());

      await tester.pumpWidget(buildSubject());

      verify(
        () => transactionBloc.add(any(that: isA<LoadAllTransactions>())),
      ).called(1);
    });

    testWidgets('shows a loading indicator while TransactionLoading', (
      tester,
    ) async {
      stub(TransactionLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders the friend name and initial in the top bar', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Aanya Shah'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });
  });

  group('error state', () {
    testWidgets('shows the error message on TransactionError', (tester) async {
      stub(TransactionError('network unreachable'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Error: network unreachable'), findsOneWidget);
    });
  });

  group('balance header', () {
    testWidgets('shows neutral "settled" copy when balance is null', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(buildSubject(balance: null));

      expect(find.text('you are all settled'), findsOneWidget);
      expect(find.text('Settled'), findsOneWidget);
    });

    testWidgets('shows "owes you" copy and amount when balance is positive', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(
        buildSubject(balance: buildBalance(netAmount: 45000)),
      );

      expect(find.text('${friend.displayName} owes you'), findsOneWidget);
      expect(find.text('₹450.00'), findsOneWidget);
    });

    testWidgets('shows "you owe" copy and absolute amount when negative', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(
        buildSubject(balance: buildBalance(netAmount: -12050)),
      );

      expect(find.text('you owe ${friend.displayName}'), findsOneWidget);
      expect(find.text('₹120.50'), findsOneWidget);
    });

    testWidgets('shows "Settled" copy when net amount is exactly zero', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(
        buildSubject(balance: buildBalance(netAmount: 0)),
      );

      expect(find.text('you are all settled'), findsOneWidget);
      expect(find.text('Settled'), findsOneWidget);
    });

    testWidgets('renders the Settle Up / Remind / Export actions', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Settle Up'), findsOneWidget);
      expect(find.text('Remind'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });
  });

  group('transaction list', () {
    testWidgets('shows empty state when there are no shared transactions', (
      tester,
    ) async {
      stub(
        TransactionLoaded([
          buildTx(
            from: currentUser,
            to: 'someone_else',
            amount: 20000,
            createdAt: DateTime(2026, 6, 1),
          ),
        ]),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('No transactions shared yet.'), findsOneWidget);
    });

    testWidgets(
      'only shows transactions between the current user and this friend',
      (tester) async {
        final shared = buildTx(
          from: currentUser,
          to: friend.publicKey,
          amount: 30000,
          description: 'Groceries run',
          createdAt: DateTime(2026, 6, 10),
        );
        final reverse = buildTx(
          from: friend.publicKey,
          to: currentUser,
          amount: 1000,
          description: 'Movie tickets',
          createdAt: DateTime(2026, 6, 9),
        );
        final unrelated = buildTx(
          from: currentUser,
          to: 'stranger_pub_key',
          amount: 99900,
          description: 'Should not show up',
          createdAt: DateTime(2026, 6, 11),
        );

        stub(TransactionLoaded([shared, reverse, unrelated]));

        await tester.pumpWidget(buildSubject());

        expect(find.text('Groceries run'), findsOneWidget);
        expect(find.text('Movie tickets'), findsOneWidget);
        expect(find.text('Should not show up'), findsNothing);
      },
    );

    testWidgets('sorts shared transactions newest first', (tester) async {
      final older = buildTx(
        from: currentUser,
        to: friend.publicKey,
        amount: 10000,
        description: 'Older expense',
        createdAt: DateTime(2026, 5, 1),
      );
      final newer = buildTx(
        from: friend.publicKey,
        to: currentUser,
        amount: 10000,
        description: 'Newer expense',
        createdAt: DateTime(2026, 6, 15),
      );

      stub(TransactionLoaded([older, newer]));

      await tester.pumpWidget(buildSubject());

      final labels = tester
          .widgetList<Text>(find.textContaining('expense'))
          .map((t) => t.data)
          .toList();

      expect(labels, ['Newer expense', 'Older expense']);
    });

    testWidgets('groups transactions under a month/year header', (
      tester,
    ) async {
      stub(
        TransactionLoaded([
          buildTx(
            from: currentUser,
            to: friend.publicKey,
            amount: 5000,
            description: 'Coffee',
            createdAt: DateTime(2026, 6, 5),
          ),
          buildTx(
            from: currentUser,
            to: friend.publicKey,
            amount: 5000,
            description: 'Tea',
            createdAt: DateTime(2026, 5, 20),
          ),
        ]),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('June 2026'), findsOneWidget);
      expect(find.text('May 2026'), findsOneWidget);
      expect(find.text('05 Jun'), findsOneWidget);
      expect(find.text('20 May'), findsOneWidget);
    });

    testWidgets(
      'shows "You paid:" when the amount sign says the current user paid',
      (tester) async {
        // Friend created the record and owes the current user (amount > 0),
        // so the current user (toUser) paid.
        stub(
          TransactionLoaded([
            buildTx(
              from: friend.publicKey,
              to: currentUser,
              amount: 8000,
              description: 'Uber ride',
              createdAt: DateTime(2026, 6, 5),
            ),
          ]),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.text('You paid:'), findsOneWidget);
        expect(find.text('₹80.00'), findsOneWidget);
        expect(find.byIcon(Icons.local_taxi_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'shows "You paid:" with the magnitude when current user created a '
      'negative-amount record',
      (tester) async {
        stub(
          TransactionLoaded([
            buildTx(
              from: currentUser,
              to: friend.publicKey,
              amount: -2500,
              description: 'Fuel top-up',
              createdAt: DateTime(2026, 6, 5),
            ),
          ]),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.text('You paid:'), findsOneWidget);
        expect(find.text('₹25.00'), findsOneWidget);
        expect(find.byIcon(Icons.local_gas_station_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'shows "<friend> paid:" when the amount sign says the friend paid',
      (tester) async {
        // Current user created the record and owes the friend (amount > 0),
        // so the friend (toUser) paid.
        stub(
          TransactionLoaded([
            buildTx(
              from: currentUser,
              to: friend.publicKey,
              amount: 6000,
              description: 'Grocery run',
              createdAt: DateTime(2026, 6, 5),
            ),
          ]),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.text('${friend.displayName} paid:'), findsOneWidget);
        expect(find.text('₹60.00'), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      },
    );

    testWidgets('picks the category icon from the tag as well', (tester) async {
      stub(
        TransactionLoaded([
          buildTx(
            from: currentUser,
            to: friend.publicKey,
            amount: 6000,
            description: 'Dinner',
            tag: 'Food',
            createdAt: DateTime(2026, 6, 5),
          ),
        ]),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Dinner'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
    });

    testWidgets(
      'falls back to default label/icon when description matches no category',
      (tester) async {
        stub(
          TransactionLoaded([
            buildTx(
              from: currentUser,
              to: friend.publicKey,
              amount: 6000,
              description: null,
              createdAt: DateTime(2026, 6, 5),
            ),
          ]),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.text('Expense Split'), findsOneWidget);
        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      },
    );
  });

  group('navigation', () {
    testWidgets('back button pops the screen', (tester) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(
        BlocProvider<TransactionBloc>.value(
          value: transactionBloc,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => FriendDetailScreen(
                          friend: friend,
                          currentUserPublicKey: currentUser,
                        ),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(FriendDetailScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.byType(FriendDetailScreen), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('tapping "Add An Expense" navigates to AppRoutes.addExpense', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      final pushedRoutes = <String>[];

      await tester.pumpWidget(
        BlocProvider<TransactionBloc>.value(
          value: transactionBloc,
          child: MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name != null) pushedRoutes.add(settings.name!);
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Add Expense')),
              );
            },
            home: FriendDetailScreen(
              friend: friend,
              currentUserPublicKey: currentUser,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add An Expense'));
      await tester.pumpAndSettle();

      expect(pushedRoutes, contains(AppRoutes.addExpense));
      expect(find.text('Add Expense'), findsOneWidget);
    });
  });

  group('overflow menu', () {
    testWidgets('shows Remove Friend and Block Friend options', (tester) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Remove Friend'), findsOneWidget);
      expect(find.text('Block Friend'), findsOneWidget);
    });
  });
}
