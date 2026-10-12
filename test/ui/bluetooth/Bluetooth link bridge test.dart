import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/ui/bluetooth/bluetooth_link_bridge.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';

class MockDeepLinkBloc extends MockBloc<DeepLinkEvent, DeepLinkState>
    implements DeepLinkBloc {}

class MockBluetoothBloc extends MockBloc<BluetoothEvent, BluetoothState>
    implements BluetoothBloc {}

void main() {
  late MockBluetoothBloc mockBluetoothBloc;
  late MockDeepLinkBloc mockDeepLinkBloc;
  late StreamController<BluetoothState> stateController;

  setUpAll(() {
    registerFallbackValue(BluetoothInviteReceived(''));
  });

  setUp(() {
    mockBluetoothBloc = MockBluetoothBloc();
    mockDeepLinkBloc = MockDeepLinkBloc();
    stateController = StreamController<BluetoothState>.broadcast();

    whenListen(
      mockBluetoothBloc,
      stateController.stream,
      initialState: const BluetoothState(),
    );
  });

  tearDown(() async {
    await stateController.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<BluetoothBloc>.value(value: mockBluetoothBloc),
            BlocProvider<DeepLinkBloc>.value(value: mockDeepLinkBloc),
          ],
          child: const BluetoothLinkBridge(child: SizedBox.shrink()),
        ),
      ),
    );
  }

  testWidgets(
    'routes a payload with a "sig" key to BluetoothTransactionReceived and clears it',
    (tester) async {
      const payload = '{"sig":"abc123","amount":500}';

      await tester.pumpWidget(buildSubject());
      stateController.add(const BluetoothState(lastReceivedPayload: payload));
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<BluetoothTransactionReceived>());
      verify(() => mockBluetoothBloc.clearReceivedPayload()).called(1);
    },
  );

  testWidgets(
    'routes a payload with an "outcome" key to BluetoothAckReceived and clears it',
    (tester) async {
      const payload = '{"outcome":"accepted","id":"txn-1"}';

      await tester.pumpWidget(buildSubject());
      stateController.add(const BluetoothState(lastReceivedPayload: payload));
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<BluetoothAckReceived>());
      verify(() => mockBluetoothBloc.clearReceivedPayload()).called(1);
    },
  );

  testWidgets(
    'routes a payload with neither key to BluetoothInviteReceived and clears it',
    (tester) async {
      const payload = '{"id":"user-1","name":"Alex"}';

      await tester.pumpWidget(buildSubject());
      stateController.add(const BluetoothState(lastReceivedPayload: payload));
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<BluetoothInviteReceived>());
      verify(() => mockBluetoothBloc.clearReceivedPayload()).called(1);
    },
  );

  testWidgets(
    'shows a snackbar and does not touch DeepLinkBloc for unreadable JSON',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      stateController.add(
        const BluetoothState(lastReceivedPayload: 'not valid json'),
      );
      await tester.pump();
      await tester.pump(); // let the SnackBar animate in

      expect(
        find.text('Received an unreadable payload over Bluetooth'),
        findsOneWidget,
      );
      verifyNever(() => mockDeepLinkBloc.add(any()));
      verify(() => mockBluetoothBloc.clearReceivedPayload()).called(1);
    },
  );

  testWidgets(
    'shows a snackbar when the payload is valid JSON but not a JSON object',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      stateController.add(const BluetoothState(lastReceivedPayload: '[1,2,3]'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Received an unreadable payload over Bluetooth'),
        findsOneWidget,
      );
      verifyNever(() => mockDeepLinkBloc.add(any()));
      verify(() => mockBluetoothBloc.clearReceivedPayload()).called(1);
    },
  );

  testWidgets(
    'does nothing when lastReceivedPayload has not changed between emissions',
    (tester) async {
      const state = BluetoothState(lastReceivedPayload: 'same-payload');

      // Start the bloc already holding this payload.
      whenListen(
        mockBluetoothBloc,
        stateController.stream,
        initialState: state,
      );

      await tester.pumpWidget(buildSubject());
      // Emit the exact same payload again — listenWhen requires
      // curr.lastReceivedPayload != prev, so this should be a no-op.
      stateController.add(state);
      await tester.pump();

      verifyNever(() => mockBluetoothBloc.clearReceivedPayload());
      verifyNever(() => mockDeepLinkBloc.add(any()));
    },
  );
}
