import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:zplit/ui/group/widgets/invite_friends.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _wrap({String username = 'alice'}) =>
    MaterialApp(home: InviteFriendsScreen(username: username));

void main() {
  group('InviteFriendsScreen – rendering', () {
    testWidgets('renders the invite link with the username', (tester) async {
      await tester.pumpWidget(_wrap(username: 'alice'));
      await tester.pump();

      expect(find.text('zplit.com/invite/alice'), findsOneWidget);
    });

    testWidgets('renders a QR code', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('Bluetooth and NFC start disabled with hint text', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      expect(
        find.text('Enable Bluetooth to see nearby devices.'),
        findsOneWidget,
      );
      expect(
        find.text('Enable NFC to share with nearby devices.'),
        findsOneWidget,
      );
    });
  });

  group('InviteFriendsScreen – copy link', () {
    testWidgets('copying the link shows a confirmation snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(username: 'alice'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();

      expect(find.text('Link copied to clipboard'), findsOneWidget);
    });

    testWidgets('copying the link writes the full https URL to clipboard', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(username: 'alice'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      expect(data?.text, 'https://zplit.com/invite/alice');
    });
  });

  group('InviteFriendsScreen – Bluetooth pairing', () {
    testWidgets('enabling Bluetooth reveals nearby devices', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byType(Switch).at(0));
      await tester.pump();

      expect(find.text('Nearby Devices'), findsOneWidget);
      expect(find.text("Krishna's Phone"), findsOneWidget);
      expect(find.text('Iphone2'), findsOneWidget);
      expect(find.text("Garima's Iphone"), findsOneWidget);
      expect(
        find.text('Enable Bluetooth to see nearby devices.'),
        findsNothing,
      );
    });

    testWidgets('disabling Bluetooth again restores the hint', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byType(Switch).at(0));
      await tester.pump();
      await tester.tap(find.byType(Switch).at(0));
      await tester.pump();

      expect(
        find.text('Enable Bluetooth to see nearby devices.'),
        findsOneWidget,
      );
    });
  });

  group('InviteFriendsScreen – Proximity sharing', () {
    testWidgets('enabling Proximity reveals filter chip and devices', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Proximity switch is the second Switch in the tree.
      await tester.tap(find.byType(Switch).at(1));
      await tester.pump();

      expect(find.text('Contacts Only'), findsOneWidget);
      expect(find.text('Nearby Devices'), findsOneWidget);
    });

    testWidgets('selecting a different filter updates the chip label', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byType(Switch).at(1));
      await tester.pump();

      await tester.tap(find.text('Contacts Only'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Everyone Nearby').last);
      await tester.pumpAndSettle();

      expect(find.text('Everyone Nearby'), findsOneWidget);
      expect(find.text('Contacts Only'), findsNothing);
    });
  });

  group('InviteFriendsScreen – NFC', () {
    testWidgets('enabling NFC reveals the instructional content', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byType(Switch).at(2));
      await tester.pump();

      expect(
        find.text(
          'Hold your device near another\nNFC-enabled phone to connect.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Enable NFC to share with nearby devices.'),
        findsNothing,
      );
    });
  });

  group('InviteFriendsScreen – navigation', () {
    testWidgets('back chevron pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const InviteFriendsScreen(username: 'alice'),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(InviteFriendsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(InviteFriendsScreen), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
