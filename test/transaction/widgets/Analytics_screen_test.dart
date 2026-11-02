// ignore_for_file: file_names
import 'package:bloc_test/bloc_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/core/database/tables/transactions_table.dart';
import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/transaction/transaction_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_event.dart';
import 'package:zplit/ui/balance/view_model/balance_state.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:zplit/ui/transaction/widgets/analytics_screen.dart';
import 'package:zplit/ui/transaction/widgets/Owe-toggle.dart';
import 'package:zplit/ui/transaction/widgets/balance_card.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class MockBalanceBloc extends MockBloc<BalanceEvent, BalanceState>
    implements BalanceBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState>
    implements UserBloc {}

// ---- Fixtures (amounts in paise) ----

const _me = '0xME';
const _alice = '0xALICE';
const _bob = '0xBOB';

const _users = [
  UserModel(publicKey: _me, displayName: 'Me Myself', defaultCurrency: 'INR'),
  UserModel(publicKey: _alice, displayName: 'Alice', defaultCurrency: 'INR'),
  UserModel(publicKey: _bob, displayName: 'Bob', defaultCurrency: 'INR'),
];

TransactionModel _tx(
  String id, {
  required String from,
  required String to,
  required int paise,
  String? tag,
  TransactionStatus status = TransactionStatus.signed,
  int daysAgo = 0,
}) {
  final now = DateTime.now();
  return TransactionModel(
    id: id,
    fromUserPublicKey: from,
    toUserPublicKey: to,
    amount: BigInt.from(paise),
    currency: 'INR',
    status: status,
    tag: tag,
    createdAt: DateTime(now.year, now.month, now.day - daysAgo, 12),
  );
}

/// What the screen counts (signed and involving me):
///   Food   = 500 + 200 = 700 (70%)
///   Travel = 300             (30%)
///   Total  = 1000
List<TransactionModel> _transactions() => [
  _tx('t1', from: _me, to: _alice, paise: 50000, tag: 'Food', daysAgo: 1),
  _tx('t2', from: _bob, to: _me, paise: 30000, tag: 'Travel'),
  _tx('t3', from: _alice, to: _me, paise: 20000, tag: 'Food'),
  // Ignored: not fully signed.
  _tx(
    't4',
    from: _me,
    to: _alice,
    paise: 99900,
    status: TransactionStatus.unsigned,
  ),
  // Ignored: does not involve me.
  _tx('t5', from: _alice, to: _bob, paise: 77700),
];

/// Owed to me: 150 + 50 = 200. I owe: 400.
List<BalanceModel> _balances() => [
  BalanceModel(
    userPublicKey: _alice,
    netAmount: 15000,
    currency: 'INR',
    updatedAt: DateTime(2026, 1, 1),
  ),
  BalanceModel(
    userPublicKey: _bob,
    netAmount: -40000,
    currency: 'INR',
    updatedAt: DateTime(2026, 1, 1),
  ),
  BalanceModel(
    userPublicKey: '0xCAROL',
    netAmount: 5000,
    currency: 'INR',
    updatedAt: DateTime(2026, 1, 1),
  ),
];

void main() {
  group('AnalyticsScreen', () {
    late MockTransactionBloc transactionBloc;
    late MockBalanceBloc balanceBloc;
    late MockUserBloc userBloc;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({'evm_address': _me});
      transactionBloc = MockTransactionBloc();
      balanceBloc = MockBalanceBloc();
      userBloc = MockUserBloc();
    });

    void stubEmpty() {
      when(() => transactionBloc.state).thenReturn(TransactionLoaded(const []));
      when(() => balanceBloc.state).thenReturn(BalanceLoaded(const []));
      when(() => userBloc.state).thenReturn(UserLoaded(_users));
    }

    void stubData() {
      when(
        () => transactionBloc.state,
      ).thenReturn(TransactionLoaded(_transactions()));
      when(() => balanceBloc.state).thenReturn(BalanceLoaded(_balances()));
      when(() => userBloc.state).thenReturn(UserLoaded(_users));
    }

    /// Phone-width but tall surface so every card in the ListView is built.
    void useTallSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(412, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    // Providers sit above MaterialApp so pushed routes and sheets see them.
    Widget providers(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>.value(value: transactionBloc),
        BlocProvider<BalanceBloc>.value(value: balanceBloc),
        BlocProvider<UserBloc>.value(value: userBloc),
      ],
      child: child,
    );

    Future<void> pumpScreen(WidgetTester tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(
        providers(const MaterialApp(home: AnalyticsScreen())),
      );
      // Let the secure-storage read resolve and chart animations finish.
      await tester.pumpAndSettle();
    }

    testWidgets('renders without crashing with no data', (tester) async {
      stubEmpty();
      await pumpScreen(tester);
      expect(find.byType(AnalyticsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without crashing with data', (tester) async {
      stubData();
      await pumpScreen(tester);
      expect(find.byType(AnalyticsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders before blocs have loaded (initial states)', (
      tester,
    ) async {
      when(() => transactionBloc.state).thenReturn(TransactionInitial());
      when(() => balanceBloc.state).thenReturn(BalanceInitial());
      when(() => userBloc.state).thenReturn(UserInitial());
      await pumpScreen(tester);
      expect(find.text('₹0'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('shows "Analytics" title and back button', (tester) async {
      stubEmpty();
      await pumpScreen(tester);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    });

    testWidgets('back button pops screen', (tester) async {
      stubEmpty();
      useTallSurface(tester);
      await tester.pumpWidget(
        providers(
          MaterialApp(
            home: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.byType(AnalyticsScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(AnalyticsScreen), findsNothing);
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('shows OweToggle with "Owes me" selected by default', (
      tester,
    ) async {
      stubEmpty();
      await pumpScreen(tester);
      expect(find.byType(OweToggle), findsOneWidget);
      expect(find.text('I owe'), findsOneWidget);
      expect(find.text('Owes me'), findsOneWidget);
      final toggle = tester.widget<OweToggle>(find.byType(OweToggle));
      expect(toggle.showOwedToMe, isTrue);
    });

    testWidgets('empty state shows ₹0 with no arrow, default filter chips '
        'and placeholder messages instead of charts', (tester) async {
      stubEmpty();
      await pumpScreen(tester);
      expect(find.text('₹0'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);

      expect(find.text('All friends'), findsOneWidget);
      expect(find.text('All categories'), findsOneWidget);
      expect(find.text('All time'), findsOneWidget);
      expect(find.text('Clear'), findsNothing);

      expect(find.text('Your Expenses'), findsOneWidget);
      expect(find.text('No expenses in this period yet'), findsOneWidget);
      expect(find.text('Monthly Spending'), findsOneWidget);
      expect(find.text('No expenses recorded yet'), findsOneWidget);
      expect(find.text('Balance Trend'), findsOneWidget);
      expect(find.textContaining('Select a friend above'), findsOneWidget);
      expect(find.text('What you spent on'), findsOneWidget);
      expect(find.text('No spending to show yet'), findsOneWidget);

      expect(find.byType(LineChart), findsNothing);
      expect(find.byType(BarChart), findsNothing);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('shows amount owed to me with up arrow from balances', (
      tester,
    ) async {
      stubData();
      await pumpScreen(tester);
      expect(find.text('₹200'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('tapping "I owe" switches to amount I owe with down arrow', (
      tester,
    ) async {
      stubData();
      await pumpScreen(tester);
      await tester.tap(find.text('I owe'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<OweToggle>(find.byType(OweToggle)).showOwedToMe,
        isFalse,
      );
      expect(find.text('₹400'), findsOneWidget);
      expect(find.text('₹200'), findsNothing);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);

      await tester.tap(find.text('Owes me'));
      await tester.pumpAndSettle();
      expect(find.text('₹200'), findsOneWidget);
    });

    testWidgets('shows fractional rupee amounts with two decimals', (
      tester,
    ) async {
      when(() => transactionBloc.state).thenReturn(TransactionLoaded(const []));
      when(() => balanceBloc.state).thenReturn(
        BalanceLoaded([
          BalanceModel(
            userPublicKey: _alice,
            netAmount: 12345,
            currency: 'INR',
            updatedAt: DateTime(2026, 1, 1),
          ),
        ]),
      );
      when(() => userBloc.state).thenReturn(UserLoaded(_users));
      await pumpScreen(tester);
      expect(find.text('₹123.45'), findsOneWidget);
    });

    testWidgets('renders expense line, monthly bar and category pie charts '
        'when there is data', (tester) async {
      stubData();
      await pumpScreen(tester);
      // Balance trend stays a placeholder until a friend is selected.
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('No expenses in this period yet'), findsNothing);
      expect(find.text('No expenses recorded yet'), findsNothing);
      expect(find.text('No spending to show yet'), findsNothing);
    });

    testWidgets('category breakdown shows total and percentages computed '
        'from signed transactions involving me only', (tester) async {
      stubData();
      await pumpScreen(tester);
      expect(find.text('Total'), findsOneWidget);
      // 500 + 300 + 200; unsigned t4 and third-party t5 are excluded.
      expect(find.text('₹1000'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('period tabs switch the expense chart period', (tester) async {
      stubData();
      await pumpScreen(tester);
      for (final label in ['Daily', 'Weekly', 'Monthly', 'Yearly']) {
        expect(find.text(label), findsOneWidget);
      }
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('friend filter sheet lists "All friends" and friends '
        'excluding me', (tester) async {
      stubData();
      await pumpScreen(tester);
      await tester.tap(find.text('All friends'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by friend'), findsOneWidget);
      // Chip label + sheet entry.
      expect(find.text('All friends'), findsNWidgets(2));
      expect(find.widgetWithText(ListTile, 'Alice'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Bob'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Me Myself'), findsNothing);
    });

    testWidgets('selecting a friend filters data, shows balance trend chart '
        'and Clear resets', (tester) async {
      stubData();
      await pumpScreen(tester);
      await tester.tap(find.text('All friends'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Alice'));
      await tester.pumpAndSettle();

      expect(find.text('Filter by friend'), findsNothing);
      expect(find.text('Alice'), findsOneWidget); // chip label
      expect(find.text('Balance Trend with Alice'), findsOneWidget);
      // Expense trend + per-friend balance trend.
      expect(find.byType(LineChart), findsNWidgets(2));
      // Only t1 (500) and t3 (200) involve Alice.
      expect(find.text('₹700'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Travel'), findsNothing);

      // "Clear" sits at the end of the horizontally scrolling filter row.
      await tester.ensureVisible(find.text('Clear'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(find.text('All friends'), findsOneWidget);
      expect(find.text('Clear'), findsNothing);
      expect(find.text('₹1000'), findsOneWidget);
    });

    testWidgets('category filter sheet lists "All categories" and tags', (
      tester,
    ) async {
      stubData();
      await pumpScreen(tester);
      await tester.tap(find.text('All categories'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by category'), findsOneWidget);
      expect(find.text('All categories'), findsNWidgets(2));
      expect(find.widgetWithText(ListTile, 'Food'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Travel'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Travel'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by category'), findsNothing);
      // Only t2 (300, Travel) remains.
      expect(find.text('₹300'), findsOneWidget);
      expect(find.text('Food'), findsNothing);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('filter sheets do not open before data is loaded', (
      tester,
    ) async {
      when(() => transactionBloc.state).thenReturn(TransactionLoading());
      when(() => balanceBloc.state).thenReturn(BalanceLoading());
      when(() => userBloc.state).thenReturn(UserLoading());
      await pumpScreen(tester);
      await tester.tap(find.text('All friends'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by friend'), findsNothing);
      await tester.tap(find.text('All categories'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by category'), findsNothing);
    });

    testWidgets('shows no transaction data when evm_address is missing', (
      tester,
    ) async {
      FlutterSecureStorage.setMockInitialValues({});
      stubData();
      await pumpScreen(tester);
      expect(find.byType(PieChart), findsNothing);
      expect(find.text('No spending to show yet'), findsOneWidget);
      // The owe amount comes from BalanceBloc and is unaffected.
      expect(find.text('₹200'), findsOneWidget);
    });
  });

  group('OweToggle', () {
    testWidgets('renders both segments', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OweToggle(showOwedToMe: true, onChanged: (_) {}),
          ),
        ),
      );
      expect(find.text('I owe'), findsOneWidget);
      expect(find.text('Owes me'), findsOneWidget);
    });

    testWidgets('calls onChanged(false) when "I owe" tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OweToggle(
              showOwedToMe: true,
              onChanged: (val) => result = val,
            ),
          ),
        ),
      );
      await tester.tap(find.text('I owe'));
      expect(result, false);
    });

    testWidgets('calls onChanged(true) when "Owes me" tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OweToggle(
              showOwedToMe: false,
              onChanged: (val) => result = val,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Owes me'));
      expect(result, true);
    });
  });

  group('BalanceSummaryCard', () {
    testWidgets('shows "Total" and ₹0.00 with no arrow when total is 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceSummaryCard(
              total: 0,
              showAnalyticsButton: false,
              onAnalyticsTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('₹0.00'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    });

    testWidgets('shows "You are owed" and up arrow when total is positive', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceSummaryCard(
              total: 50000,
              showAnalyticsButton: false,
              onAnalyticsTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('You are owed'), findsOneWidget);
      expect(find.text('₹500.00'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('shows "You owe" and down arrow when total is negative', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceSummaryCard(
              total: -30000,
              showAnalyticsButton: false,
              onAnalyticsTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('You owe'), findsOneWidget);
      expect(find.text('₹300.00'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });

    testWidgets('formats minor units with Indian digit grouping', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceSummaryCard(
              total: 12345678,
              showAnalyticsButton: false,
              onAnalyticsTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('₹1,23,456.78'), findsOneWidget);
    });

    testWidgets('shows analytics icon when showAnalyticsButton is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceSummaryCard(
              total: 100,
              showAnalyticsButton: true,
              onAnalyticsTap: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    });

    testWidgets('hides analytics icon when showAnalyticsButton is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceSummaryCard(
              total: 100,
              showAnalyticsButton: false,
              onAnalyticsTap: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.bar_chart_rounded), findsNothing);
    });

    testWidgets('calls onAnalyticsTap when analytics icon tapped', (
      tester,
    ) async {
      bool called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceSummaryCard(
              total: 100,
              showAnalyticsButton: true,
              onAnalyticsTap: () => called = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.bar_chart_rounded));
      expect(called, isTrue);
    });
  });
}
