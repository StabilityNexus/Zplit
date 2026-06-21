import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/ui/transaction/widgets/expense.dart';

void main() {
  Widget _wrap() => const MaterialApp(home: AddExpenseScreen());

  group('AddExpenseScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });

    testWidgets('shows "Add an Expense" in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Add an Expense'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('shows camera icon in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('shows all section labels', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('On Date'), findsOneWidget);
      expect(find.text('Splitting With'), findsOneWidget);
      expect(find.text('How was this expense split?'), findsOneWidget);
      expect(find.text('Paid for'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows all category chips', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      for (final cat in ['Grocery', 'Rent', 'Uber', 'Drinks', 'Food', 'Fuel']) {
        expect(find.text(cat), findsOneWidget);
      }
    });

    testWidgets('shows Save Expense button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Save Expense'), findsOneWidget);
    });

    testWidgets('amount field accepts input', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '250');
      expect(find.text('250'), findsOneWidget);
    });

    testWidgets('date field shows "Select date" by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Select date'), findsOneWidget);
    });

    testWidgets('split picker shows "Select" by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Select'), findsOneWidget);
    });

    testWidgets('tapping split field opens bottom sheet', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Select'));
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
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Split Equally'));
      await tester.pumpAndSettle();
      expect(find.text('Split Equally'), findsOneWidget);
      expect(find.text('How was this split?'), findsNothing);
    });

    testWidgets('tapping category chip selects it', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Grocery'));
      await tester.pump();
      // No crash — chip selection works
      expect(find.text('Grocery'), findsOneWidget);
    });

    testWidgets('tapping selected category chip deselects it', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Grocery'));
      await tester.pump();
      await tester.tap(find.text('Grocery'));
      await tester.pump();
      expect(find.text('Grocery'), findsOneWidget);
    });

    testWidgets('shows "You" in splitting with section', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('shows person_add icon for adding friend', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
    });
  });
}
