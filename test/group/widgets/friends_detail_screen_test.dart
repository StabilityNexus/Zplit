// Widget tests for FriendDetailScreen.
//
// ASSUMPTIONS — please verify against your real code:
//   1. Import path for FriendDetailScreen below is a guess based on your
//      ui/<feature>/view_model + widgets convention. Fix it.
//   2. TransactionBloc states are assumed to be TransactionLoading(),
//      TransactionError(String message), TransactionLoaded(List<TransactionModel>)
//      — all with POSITIONAL constructor args (confirmed for TransactionLoaded
//      from a build error; TransactionError is still an assumption, fix if wrong).
//   3. LoadAllTransactions is assumed to take no constructor args.
//   4. TransactionStatus is an enum from transactions_table.dart — since I
//      don't know your member names, fixtures default to
//      TransactionStatus.values.first. Swap in a specific value
//      (e.g. TransactionStatus.confirmed) if a test needs to care about it.
//
// Dev dependencies needed in pubspec.yaml:
//   dev_dependencies:
//     flutter_test:
//       sdk: flutter
//     bloc_test: ^9.1.7
//     mocktail: ^1.0.4

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

  TransactionModel buildTx({
    required String from,
    required String to,
    required int amount,
    String? description,
    String? tag,
    required DateTime createdAt,
    String currency = '₹',
    TransactionStatus? status,
  }) {
    txCounter++;
    return TransactionModel(
      id: 'tx_$txCounter',
      fromUserPublicKey: from,
      toUserPublicKey: to,
      amount: BigInt.from(amount),
      currency: currency,
      status: status ?? TransactionStatus.values.first,
      description: description,
      tag: tag,
      createdAt: createdAt,
    );
  }

  BalanceModel buildBalance({required int netAmount, String currency = '₹'}) {
    return BalanceModel(
      userPublicKey: friend.publicKey,
      netAmount: netAmount,
      currency: currency,
      updatedAt: DateTime(2026, 6, 20),
    );
  }

  Widget buildSubject({BalanceModel? balance}) {
    return MaterialApp(
      home: BlocProvider<TransactionBloc>.value(
        value: transactionBloc,
        child: FriendDetailScreen(
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
        buildSubject(balance: buildBalance(netAmount: 450)),
      );

      expect(find.text('${friend.displayName} owes you:'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
    });

    testWidgets('shows "you owe" copy and absolute amount when negative', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      await tester.pumpWidget(
        buildSubject(balance: buildBalance(netAmount: -120)),
      );

      expect(find.text('you owe:'), findsOneWidget);
      expect(find.text('₹120'), findsOneWidget);
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
            amount: 200,
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
          amount: 300,
          description: 'Groceries run',
          createdAt: DateTime(2026, 6, 10),
        );
        final unrelated = buildTx(
          from: currentUser,
          to: 'stranger_pub_key',
          amount: 999,
          description: 'Should not show up',
          createdAt: DateTime(2026, 6, 11),
        );

        stub(TransactionLoaded([shared, unrelated]));

        await tester.pumpWidget(buildSubject());

        expect(find.text('Groceries run'), findsOneWidget);
        expect(find.text('Should not show up'), findsNothing);
      },
    );

    testWidgets('sorts shared transactions newest first', (tester) async {
      final older = buildTx(
        from: currentUser,
        to: friend.publicKey,
        amount: 100,
        description: 'Older expense',
        createdAt: DateTime(2026, 5, 1),
      );
      final newer = buildTx(
        from: friend.publicKey,
        to: currentUser,
        amount: 100,
        description: 'Newer expense',
        createdAt: DateTime(2026, 6, 15),
      );

      stub(TransactionLoaded([older, newer]));

      await tester.pumpWidget(buildSubject());

      final labels = tester
          .widgetList<Text>(find.textContaining('expense'))
          .map((t) => t.data)
          .toList();

      expect(
        labels.indexOf('Newer expense') < labels.indexOf('Older expense'),
        isTrue,
      );
    });

    testWidgets('groups transactions under a month/year header', (
      tester,
    ) async {
      stub(
        TransactionLoaded([
          buildTx(
            from: currentUser,
            to: friend.publicKey,
            amount: 50,
            description: 'Coffee',
            createdAt: DateTime(2026, 6, 5),
          ),
        ]),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('June 2026'), findsOneWidget);
    });

    testWidgets(
      'shows "You paid:" and the right icon when current user sent it',
      (tester) async {
        stub(
          TransactionLoaded([
            buildTx(
              from: currentUser,
              to: friend.publicKey,
              amount: 80,
              description: 'Uber ride',
              createdAt: DateTime(2026, 6, 5),
            ),
          ]),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.text('You paid:'), findsOneWidget);
        expect(find.byIcon(Icons.local_taxi_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'shows "<friend> paid:" and the right icon when friend sent it',
      (tester) async {
        stub(
          TransactionLoaded([
            buildTx(
              from: friend.publicKey,
              to: currentUser,
              amount: 60,
              description: 'Grocery run',
              createdAt: DateTime(2026, 6, 5),
            ),
          ]),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.text('${friend.displayName} paid:'), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'falls back to default label/icon when description matches no category',
      (tester) async {
        stub(
          TransactionLoaded([
            buildTx(
              from: currentUser,
              to: friend.publicKey,
              amount: 60,
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
        MaterialApp(
          home: BlocProvider<TransactionBloc>.value(
            value: transactionBloc,
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
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
      expect(find.text('Open'), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('tapping "Add An Expense" navigates to AppRoutes.addExpense', (
      tester,
    ) async {
      stub(TransactionLoaded([]));

      final pushedRoutes = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name != null) pushedRoutes.add(settings.name!);
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Add Expense')),
            );
          },
          home: BlocProvider<TransactionBloc>.value(
            value: transactionBloc,
            child: FriendDetailScreen(
              friend: friend,
              currentUserPublicKey: currentUser,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add An Expense'));
      await tester.pumpAndSettle();

      expect(pushedRoutes, contains(AppRoutes.addExpense));
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
