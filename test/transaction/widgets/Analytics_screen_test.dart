// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/ui/transaction/widgets/analytics_screen.dart';
import 'package:zplit/ui/transaction/widgets/Owe-toggle.dart';
import 'package:zplit/ui/transaction/widgets/balance_card.dart';

void main() {
  Widget wrap() => const MaterialApp(home: AnalyticsScreen());

  group('AnalyticsScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('shows "Analytics" title', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    });

    testWidgets('shows OweToggle widget', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byType(OweToggle), findsOneWidget);
    });

    testWidgets('shows "Owes me" selected by default', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('Owes me'), findsOneWidget);
    });

    testWidgets('shows "I owe" toggle option', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('I owe'), findsOneWidget);
    });

    testWidgets('shows ₹0 amount by default', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.text('₹0'), findsOneWidget);
    });

    testWidgets('shows up arrow icon', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('tapping "I owe" switches toggle', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('I owe'));
      await tester.pump();
      // No crash, amount still shows ₹0
      expect(find.text('₹0'), findsOneWidget);
    });

    testWidgets('back button pops screen', (tester) async {
      await tester.pumpWidget(
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
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Go'), findsOneWidget);
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
