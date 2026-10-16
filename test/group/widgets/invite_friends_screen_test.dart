// Widget tests for InviteFriendsScreen.
//
// The screen reads UserBloc (own profile picture), BluetoothBloc (pairing
// section) and NfcBloc (NFC section) from context. All three are mocked so no
// real platform plugin (nearby connections, NFC) is touched. Clipboard and
// share_plus are exercised through mocked method channels.

import 'dart:async';
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:zplit/core/services/bluetooth_service.dart' show BtEndpoint;
import 'package:zplit/core/theme/app_theme.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';
import 'package:zplit/ui/group/widgets/invite_friends.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockBluetoothBloc extends MockBloc<BluetoothEvent, BluetoothState>
    implements BluetoothBloc {}

class MockNfcBloc extends MockBloc<NfcEvent, NfcState> implements NfcBloc {}

class FakeUserEvent extends Fake implements UserEvent {}

class FakeNfcEvent extends Fake implements NfcEvent {}

// ─── Fixtures ────────────────────────────────────────────────────────────────

const _userId = '0xALICE_PUB';
const _name = 'Alice';
const _address = '0xALICE_ADDR';
const _deepLinkPrefix = 'https://zplit.aossie.org/invite?d=';
const _shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

Map<String, dynamic> _decodeDeepLink(String link) {
  expect(link, startsWith(_deepLinkPrefix));
  final encoded = link.substring(_deepLinkPrefix.length);
  return jsonDecode(utf8.decode(base64Url.decode(encoded)))
      as Map<String, dynamic>;
}

void main() {
  late MockUserBloc userBloc;
  late MockBluetoothBloc bluetoothBloc;
  late MockNfcBloc nfcBloc;

  String? clipboardText;
  final shareCalls = <MethodCall>[];

  setUpAll(() {
    registerFallbackValue(FakeUserEvent());
    // BluetoothEvent is sealed, so a real event serves as the fallback.
    registerFallbackValue(const BluetoothDisconnectRequested('fallback'));
    registerFallbackValue(FakeNfcEvent());
  });

  setUp(() {
    userBloc = MockUserBloc();
    bluetoothBloc = MockBluetoothBloc();
    nfcBloc = MockNfcBloc();

    when(() => userBloc.state).thenReturn(
      UserLoaded([
        UserModel(
          publicKey: _userId,
          displayName: _name,
          cryptoAddress: _address,
          profilePicture: null,
          defaultCurrency: '₹',
        ),
      ]),
    );
    when(() => bluetoothBloc.state).thenReturn(const BluetoothState());
    when(() => nfcBloc.state).thenReturn(const NfcState());

    clipboardText = null;
    shareCalls.clear();

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      switch (call.method) {
        case 'Clipboard.setData':
          clipboardText =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
          return null;
        case 'Clipboard.getData':
          return <String, Object?>{'text': clipboardText};
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_shareChannel, (call) async {
      shareCalls.add(call);
      return 'dev.fluttercommunity.plus/share/unavailable';
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    messenger.setMockMethodCallHandler(_shareChannel, null);
  });

  Widget withBlocs(Widget app) => MultiBlocProvider(
    providers: [
      BlocProvider<UserBloc>.value(value: userBloc),
      BlocProvider<BluetoothBloc>.value(value: bluetoothBloc),
      BlocProvider<NfcBloc>.value(value: nfcBloc),
    ],
    child: app,
  );

  Widget wrap() => withBlocs(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: const InviteFriendsScreen(
        userId: _userId,
        name: _name,
        address: _address,
      ),
    ),
  );

  Finder switchAt(int index) => find.byType(Switch).at(index);

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  group('InviteFriendsScreen – rendering', () {
    testWidgets('renders the title and the invite display link', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('Invite Friends'), findsOneWidget);
      expect(find.text('Invite via Link'), findsOneWidget);
      expect(find.text('zplit.aossie.org/invite'), findsOneWidget);
    });

    testWidgets('renders a QR code with a Share button', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('Share QR Code'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('Bluetooth, Proximity and NFC start disabled with hint text', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(
        find.text('Enable Bluetooth to see nearby devices.'),
        findsOneWidget,
      );
      expect(
        find.text('Enable Proximity Sharing to find nearby contacts.'),
        findsOneWidget,
      );
      expect(
        find.text('Enable NFC to share with nearby devices.'),
        findsOneWidget,
      );
      expect(tester.widget<Switch>(switchAt(0)).value, isFalse);
      expect(tester.widget<Switch>(switchAt(1)).value, isFalse);
      expect(tester.widget<Switch>(switchAt(2)).value, isFalse);
    });
  });

  group('InviteFriendsScreen – copy / share link', () {
    testWidgets('copying the link shows a confirmation snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();

      expect(find.text('Invite link copied!'), findsOneWidget);
    });

    testWidgets('copying the link writes the signed deep link to clipboard', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final payload = _decodeDeepLink(data!.text!);
      expect(payload['id'], _userId);
      expect(payload['name'], _name);
      expect(payload['addr'], _address);
      expect(payload['ts'], isA<int>());
    });

    testWidgets('tapping Share sends the deep link to the share sheet', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, find.text('Share'));

      expect(shareCalls, hasLength(1));
      expect(shareCalls.single.method, 'share');
      final args = shareCalls.single.arguments as Map<Object?, Object?>;
      expect(args['subject'], 'Join me on Zplit!');
      final payload = _decodeDeepLink(args['text']! as String);
      expect(payload['id'], _userId);
    });
  });

  group('InviteFriendsScreen – Bluetooth pairing', () {
    testWidgets('toggling Bluetooth on dispatches BluetoothToggled', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, switchAt(0));

      verify(
        () => bluetoothBloc.add(const BluetoothToggled(true, _name)),
      ).called(1);
    });

    testWidgets('toggling Bluetooth off dispatches BluetoothToggled(false)', (
      tester,
    ) async {
      when(
        () => bluetoothBloc.state,
      ).thenReturn(const BluetoothState(enabled: true));

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, switchAt(0));

      verify(
        () => bluetoothBloc.add(const BluetoothToggled(false, _name)),
      ).called(1);
    });

    testWidgets('enabled with no endpoints shows the searching indicator', (
      tester,
    ) async {
      when(
        () => bluetoothBloc.state,
      ).thenReturn(const BluetoothState(enabled: true));

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('Nearby Devices'), findsOneWidget);
      expect(find.text('Searching for nearby Zplit users...'), findsOneWidget);
      expect(
        find.text('Enable Bluetooth to see nearby devices.'),
        findsNothing,
      );
    });

    testWidgets('permission denied shows the permissions hint', (tester) async {
      when(() => bluetoothBloc.state).thenReturn(
        const BluetoothState(enabled: false, permissionDenied: true),
      );

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(
        find.textContaining('nearby-device permissions are required'),
        findsOneWidget,
      );
      expect(
        find.text('Enable Bluetooth to see nearby devices.'),
        findsNothing,
      );
    });

    testWidgets('lists nearby endpoints with a trailing action per status', (
      tester,
    ) async {
      when(() => bluetoothBloc.state).thenReturn(
        BluetoothState(
          enabled: true,
          nearbyEndpoints: [
            BtEndpoint('e1', "Krishna's Phone"),
            BtEndpoint('e2', 'Iphone2'),
            BtEndpoint('e3', "Garima's Iphone"),
            BtEndpoint('e4', 'Pixel'),
          ],
          connectionStatus: const {
            'e2': BtConnectionStatus.connected,
            'e3': BtConnectionStatus.disconnected,
            'e4': BtConnectionStatus.connecting,
          },
        ),
      );

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text("Krishna's Phone"), findsOneWidget);
      expect(find.text('Iphone2'), findsOneWidget);
      expect(find.text("Garima's Iphone"), findsOneWidget);
      expect(find.text('Pixel'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Searching for nearby Zplit users...'), findsNothing);
    });

    testWidgets('tapping Connect dispatches BluetoothConnectRequested', (
      tester,
    ) async {
      when(() => bluetoothBloc.state).thenReturn(
        BluetoothState(
          enabled: true,
          nearbyEndpoints: [BtEndpoint('e1', "Krishna's Phone")],
        ),
      );

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, find.text('Connect'));

      verify(
        () => bluetoothBloc.add(const BluetoothConnectRequested('e1', _name)),
      ).called(1);
    });

    testWidgets('tapping Send dispatches the invite payload and confirms', (
      tester,
    ) async {
      when(() => bluetoothBloc.state).thenReturn(
        BluetoothState(
          enabled: true,
          nearbyEndpoints: [BtEndpoint('e1', "Krishna's Phone")],
          connectionStatus: const {'e1': BtConnectionStatus.connected},
        ),
      );

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, find.text('Send'));

      final sent =
          verify(
                () => bluetoothBloc.add(
                  captureAny(that: isA<BluetoothSendPayload>()),
                ),
              ).captured.single
              as BluetoothSendPayload;
      expect(sent.endpointId, 'e1');
      final payload = jsonDecode(sent.jsonPayload) as Map<String, dynamic>;
      expect(payload['id'], _userId);
      expect(payload['name'], _name);
      expect(payload['addr'], _address);
      expect(payload['pic'], isNull);
      expect(find.text("Invite sent to Krishna's Phone"), findsOneWidget);
    });

    testWidgets('auto-sends the profile once an endpoint becomes connected', (
      tester,
    ) async {
      final controller = StreamController<BluetoothState>();
      addTearDown(controller.close);
      final endpoints = [BtEndpoint('e1', "Krishna's Phone")];
      whenListen(
        bluetoothBloc,
        controller.stream,
        initialState: BluetoothState(enabled: true, nearbyEndpoints: endpoints),
      );

      await tester.pumpWidget(wrap());
      await tester.pump();

      final connected = BluetoothState(
        enabled: true,
        nearbyEndpoints: endpoints,
        connectionStatus: const {'e1': BtConnectionStatus.connected},
      );
      controller.add(connected);
      await tester.pump();
      // Same status again must not trigger a second auto-send.
      controller.add(connected.copyWith(errorMessage: 'transient'));
      await tester.pump();

      final captured = verify(
        () => bluetoothBloc.add(captureAny(that: isA<BluetoothSendPayload>())),
      ).captured;
      expect(captured, hasLength(1));
      expect((captured.single as BluetoothSendPayload).endpointId, 'e1');
    });

    testWidgets('shows a snackbar when the bloc reports an error', (
      tester,
    ) async {
      final controller = StreamController<BluetoothState>();
      addTearDown(controller.close);
      whenListen(
        bluetoothBloc,
        controller.stream,
        initialState: const BluetoothState(),
      );

      await tester.pumpWidget(wrap());
      await tester.pump();

      controller.add(const BluetoothState(errorMessage: 'Bluetooth is off'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Bluetooth is off'), findsOneWidget);
    });
  });

  group('InviteFriendsScreen – Proximity sharing', () {
    testWidgets('enabling Proximity reveals the filter chip', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, switchAt(1));

      expect(find.text('Contacts Only'), findsOneWidget);
      expect(
        find.text('Enable Proximity Sharing to find nearby contacts.'),
        findsNothing,
      );
      expect(
        find.textContaining('reuse the Bluetooth transport'),
        findsOneWidget,
      );
    });

    testWidgets('selecting a different filter updates the chip label', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, switchAt(1));

      await tester.tap(find.text('Contacts Only'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Everyone Nearby').last);
      await tester.pumpAndSettle();

      expect(find.text('Everyone Nearby'), findsOneWidget);
      expect(find.text('Contacts Only'), findsNothing);
    });
  });

  group('InviteFriendsScreen – NFC', () {
    testWidgets('toggling NFC on dispatches NfcToggled(true)', (tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, switchAt(2));

      final event =
          verify(
                () => nfcBloc.add(captureAny(that: isA<NfcToggled>())),
              ).captured.single
              as NfcToggled;
      expect(event.enabled, isTrue);
    });

    testWidgets('enabled NFC shows the instructional content', (tester) async {
      when(() => nfcBloc.state).thenReturn(const NfcState(enabled: true));

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(
        find.text(
          'Hold your device near another\nNFC-enabled phone to connect.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tap to Share Invite'), findsOneWidget);
      expect(
        find.text('Enable NFC to share with nearby devices.'),
        findsNothing,
      );
    });

    testWidgets('tapping "Tap to Share Invite" dispatches NfcSendPayload', (
      tester,
    ) async {
      when(() => nfcBloc.state).thenReturn(const NfcState(enabled: true));

      await tester.pumpWidget(wrap());
      await tester.pump();

      await tapVisible(tester, find.text('Tap to Share Invite'));

      final event =
          verify(
                () => nfcBloc.add(captureAny(that: isA<NfcSendPayload>())),
              ).captured.single
              as NfcSendPayload;
      final payload = jsonDecode(event.payload) as Map<String, dynamic>;
      expect(payload['id'], _userId);
      expect(payload['name'], _name);
      expect(payload['addr'], _address);
    });

    testWidgets('busy NFC shows the waiting copy and disables sharing', (
      tester,
    ) async {
      when(
        () => nfcBloc.state,
      ).thenReturn(const NfcState(enabled: true, isBusy: true));

      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('Hold devices together...'), findsOneWidget);
      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Tap to Share Invite'),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('NFC errors show a snackbar and reset the bloc', (
      tester,
    ) async {
      final controller = StreamController<NfcState>();
      addTearDown(controller.close);
      whenListen(nfcBloc, controller.stream, initialState: const NfcState());

      await tester.pumpWidget(wrap());
      await tester.pump();

      controller.add(
        const NfcState(errorMessage: 'NFC not available on this device'),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('NFC not available on this device'), findsOneWidget);
      verify(() => nfcBloc.add(any(that: isA<NfcReset>()))).called(1);
    });
  });

  group('InviteFriendsScreen – navigation', () {
    testWidgets('back chevron pops the screen', (tester) async {
      await tester.pumpWidget(
        withBlocs(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const InviteFriendsScreen(
                          userId: _userId,
                          name: _name,
                          address: _address,
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
      expect(find.byType(InviteFriendsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(InviteFriendsScreen), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
