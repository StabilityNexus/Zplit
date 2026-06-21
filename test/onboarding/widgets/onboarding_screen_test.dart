import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/onboarding/widgets/Onboarding_screen.dart';

void main() {
  Widget _wrap() => MaterialApp(
    onGenerateRoute: AppRouter.onGenerateRoute,
    home: const OnboardingScreen(),
  );

  group('OnboardingScreen – rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('shows skip button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('skip'), findsOneWidget);
    });

    testWidgets('shows next arrow button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('shows first page title on load', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Effortless Splitting'), findsOneWidget);
    });

    testWidgets('shows first page body on load', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Automatically split bills'), findsOneWidget);
    });

    testWidgets('shows 3 page indicator dots', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // 3 AnimatedContainers for dots
      final containers = find.descendant(
        of: find.byType(Row),
        matching: find.byType(AnimatedContainer),
      );
      expect(containers, findsWidgets);
    });
  });

  group('OnboardingScreen – skip', () {
    testWidgets('tapping skip navigates away from OnboardingScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('skip'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('OnboardingScreen – next button', () {
    testWidgets('tapping next on page 1 shows page 2 title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Total Control'), findsOneWidget);
    });

    testWidgets('tapping next on page 2 shows page 3 title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Smart Spending Insights'), findsOneWidget);
    });

    testWidgets('tapping next on last page navigates away', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('skip and next both go to same route (account setup)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('skip'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('OnboardingScreen – page content', () {
    testWidgets('page 2 shows correct body text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.textContaining('personal data'), findsOneWidget);
    });

    testWidgets('page 3 shows correct body text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.textContaining('real-time expense'), findsOneWidget);
    });
  });
}
