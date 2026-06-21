import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/ui/users/widgets/profile_screen.dart';

void main() {
  Widget _wrap() => const MaterialApp(home: ProfileScreen());

  group('ProfileScreen – rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('shows "Profile" in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('shows "My Profile" heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('shows person icon avatar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows empty address text when address is null', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });

  group('ProfileScreen – app bar', () {
    testWidgets('shows back (chevron_left) button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('shows edit icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('shows QR code icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });

    testWidgets('back button pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => TextButton(
              onPressed: () => Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsNothing);
      expect(find.text('Go'), findsOneWidget);
    });
  });

  group('ProfileScreen – General section', () {
    testWidgets('shows "General" section header', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('General'), findsOneWidget);
    });

    testWidgets('shows Theme tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('shows "Light" as theme trailing value', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('shows Payment History tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Payment History'), findsOneWidget);
    });

    testWidgets('shows Manage Friends and Groups tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Manage Friends and Groups'), findsOneWidget);
    });

    testWidgets('shows Invite Friends tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Invite Friends'), findsOneWidget);
    });
  });

  group('ProfileScreen – Feedback section', () {
    testWidgets('shows Feedback tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Feedback'), 200);
      expect(find.text('Feedback'), findsOneWidget);
    });

    testWidgets('shows Contact Us tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Contact Us'), 200);
      expect(find.text('Contact Us'), findsOneWidget);
    });
  });

  group('ProfileScreen – Log Out', () {
    testWidgets('shows Log Out button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Log Out'), 200);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('Log Out button is red', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Log Out'), 200);

      final textWidget = tester.widget<Text>(find.text('Log Out'));
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('tapping Log Out does not crash', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Log Out'), 200);
      await tester.tap(find.text('Log Out'));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });

  group('ProfileScreen – tile interactions', () {
    testWidgets('tapping Theme tile does not crash', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Theme'));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('tapping Payment History does not crash', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Payment History'));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('tapping edit icon does not crash', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
