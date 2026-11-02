// Smoke test for the Zplit app.
//
// Pumps the first screen a new user sees (OnboardingScreen) inside a plain
// MaterialApp, so it needs no database, secure storage or other platform
// plugins, and checks that the key onboarding content renders.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zplit/ui/onboarding/widgets/Onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Effortless Splitting'), findsOneWidget);
    expect(find.text('skip'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
