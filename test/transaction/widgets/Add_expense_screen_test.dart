// ignore_for_file: file_names
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:zplit/ui/transaction/widgets/expense.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState>
    implements UserBloc {}

class MockBluetoothBloc extends MockBloc<BluetoothEvent, BluetoothState>
    implements BluetoothBloc {}

void main() {
  late MockTransactionBloc transactionBloc;
  late MockUserBloc userBloc;
  late MockBluetoothBloc bluetoothBloc;

  setUp(() {
    transactionBloc = MockTransactionBloc();
    userBloc = MockUserBloc();
    bluetoothBloc = MockBluetoothBloc();
    when(() => transactionBloc.state).thenReturn(TransactionInitial());
    // UserInitial keeps the friend picker from touching secure storage.
    when(() => userBloc.state).thenReturn(UserInitial());
    when(() => bluetoothBloc.state).thenReturn(const BluetoothState());
  });

  Widget wrap() => MultiBlocProvider(
    providers: [
      BlocProvider<TransactionBloc>.value(value: transactionBloc),
      BlocProvider<UserBloc>.value(value: userBloc),
      BlocProvider<BluetoothBloc>.value(value: bluetoothBloc),
    ],
    child: const MaterialApp(home: AddExpenseScreen()),
  );

  const splitPlaceholder = 'Select (defaults to Split Equally)';

  TextField paidForField(WidgetTester tester) => tester.widget<TextField>(
    find.widgetWithText(TextField, 'e.g. Dinner, Groceries'),
  );

  Future<void> tapChip(WidgetTester tester, String label) async {
    final chip = find.descendant(
      of: find.byType(GestureDetector),
      matching: find.text(label),
    );
    await tester.ensureVisible(chip.first);
    await tester.tap(chip.first);
    await tester.pump();
  }

  group('AddExpenseScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });

    testWidgets('shows "Add an Expense" in app bar', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Add an Expense'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('shows camera icon in app bar', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('shows all section labels', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('On Date'), findsOneWidget);
      expect(find.text('Splitting With'), findsOneWidget);
      expect(find.text('How was this expense split?'), findsOneWidget);
      expect(find.text('Paid for'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows all category chips', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      for (final cat in ['Grocery', 'Rent', 'Uber', 'Drinks', 'Food', 'Fuel']) {
        expect(find.text(cat), findsOneWidget);
      }
    });

    testWidgets('shows Send Expense button', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Send Expense'), findsOneWidget);
    });

    testWidgets('amount field accepts input and shows split preview', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '250');
      await tester.pump();
      expect(find.text('250'), findsOneWidget);
      expect(find.text('Friend owes you ₹125.00'), findsOneWidget);
    });

    testWidgets('date field shows "Select date" by default', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Select date'), findsOneWidget);
    });

    testWidgets('split picker shows default placeholder', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text(splitPlaceholder), findsOneWidget);
    });

    testWidgets('tapping split field opens bottom sheet', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text(splitPlaceholder));
      await tester.pumpAndSettle();
      expect(find.text('How was this split?'), findsOneWidget);
      expect(find.text('Split Equally'), findsOneWidget);
      expect(find.text('You Paid'), findsOneWidget);
      expect(find.text('They Paid'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('selecting a split option updates field and closes sheet', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text(splitPlaceholder));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Split Equally'));
      await tester.pumpAndSettle();
      expect(find.text('Split Equally'), findsOneWidget);
      expect(find.text(splitPlaceholder), findsNothing);
      expect(find.text('How was this split?'), findsNothing);
    });

    testWidgets('tapping category chip selects it and autofills Paid for', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tapChip(tester, 'Grocery');
      expect(paidForField(tester).controller!.text, 'Grocery');
    });

    testWidgets('tapping selected category chip deselects it', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tapChip(tester, 'Grocery');
      await tapChip(tester, 'Grocery');
      expect(paidForField(tester).controller!.text, isEmpty);
      expect(find.text('Grocery'), findsOneWidget);
    });

    testWidgets('shows "You" in splitting with section', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('shows person_add icon for adding friend', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
    });

    testWidgets('Send Expense with no amount shows validation snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.ensureVisible(find.text('Send Expense'));
      await tester.tap(find.text('Send Expense'));
      await tester.pump();
      expect(find.text('Enter a valid amount'), findsOneWidget);
    });

    testWidgets('Send Expense without a friend shows validation snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '100');
      await tester.pump();
      await tester.ensureVisible(find.text('Send Expense'));
      await tester.tap(find.text('Send Expense'));
      await tester.pump();
      expect(find.text('Select a friend to split with'), findsOneWidget);
    });

    testWidgets('shows snackbar when TransactionBloc emits an error', (
      tester,
    ) async {
      whenListen(
        transactionBloc,
        Stream<TransactionState>.fromIterable([TransactionError('boom')]),
        initialState: TransactionInitial(),
      );
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.pump();
      expect(find.text('Transaction error: boom'), findsOneWidget);
    });
  });
}
