import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';
import 'package:zplit/ui/nfc/widgets/nfc_link_bridge.dart';

class MockNfcBloc extends MockBloc<NfcEvent, NfcState> implements NfcBloc {}

class MockDeepLinkBloc extends Mock implements DeepLinkBloc {}

void main() {
  late MockNfcBloc mockNfcBloc;
  late MockDeepLinkBloc mockDeepLinkBloc;

  setUpAll(() {
    // Fallback values so mocktail's any()/captureAny() can match these
    // event types in when()/verify() calls below.
    registerFallbackValue(NfcReset());
    registerFallbackValue(NfcInviteReceived(''));
  });

  setUp(() {
    mockNfcBloc = MockNfcBloc();
    mockDeepLinkBloc = MockDeepLinkBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<NfcBloc>.value(value: mockNfcBloc),
            BlocProvider<DeepLinkBloc>.value(value: mockDeepLinkBloc),
          ],
          child: const NfcLinkBridge(child: SizedBox.shrink()),
        ),
      ),
    );
  }

  void emitReceivedPayload(String payload) {
    whenListen(
      mockNfcBloc,
      Stream.fromIterable([NfcState(lastReceivedPayload: payload)]),
      initialState: const NfcState(),
    );
  }

  testWidgets(
    'routes a payload with a "sig" key to NfcTransactionReceived and resets',
    (tester) async {
      const payload = '{"sig":"abc123","amount":500}';
      emitReceivedPayload(payload);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<NfcTransactionReceived>());

      verify(() => mockNfcBloc.add(any(that: isA<NfcReset>()))).called(1);
    },
  );

  testWidgets(
    'routes a payload with an "outcome" key to NfcAckReceived and resets',
    (tester) async {
      const payload = '{"outcome":"accepted","id":"txn-1"}';
      emitReceivedPayload(payload);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<NfcAckReceived>());

      verify(() => mockNfcBloc.add(any(that: isA<NfcReset>()))).called(1);
    },
  );

  testWidgets(
    'routes a payload with neither key to NfcInviteReceived and resets',
    (tester) async {
      const payload = '{"id":"user-1","name":"Alex"}';
      emitReceivedPayload(payload);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<NfcInviteReceived>());

      verify(() => mockNfcBloc.add(any(that: isA<NfcReset>()))).called(1);
    },
  );

  testWidgets(
    'shows a snackbar and does not touch DeepLinkBloc for unreadable JSON',
    (tester) async {
      emitReceivedPayload('not valid json');

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(); // let the SnackBar animate in

      expect(
        find.text('Received an unreadable payload over NFC'),
        findsOneWidget,
      );
      verifyNever(() => mockDeepLinkBloc.add(any()));
      verify(() => mockNfcBloc.add(any(that: isA<NfcReset>()))).called(1);
    },
  );

  testWidgets(
    'shows a snackbar when the payload is valid JSON but not a JSON object',
    (tester) async {
      emitReceivedPayload('[1,2,3]');

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Received an unreadable payload over NFC'),
        findsOneWidget,
      );
      verifyNever(() => mockDeepLinkBloc.add(any()));
      verify(() => mockNfcBloc.add(any(that: isA<NfcReset>()))).called(1);
    },
  );

  testWidgets('does nothing when lastReceivedPayload has not changed', (
    tester,
  ) async {
    const state = NfcState(lastReceivedPayload: 'same-payload');
    whenListen(
      mockNfcBloc,
      Stream.fromIterable([state, state]),
      initialState: state,
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // listenWhen requires curr.payload != prev.payload — an identical
    // repeated payload should not trigger another handlePayload/reset.
    verifyNever(() => mockNfcBloc.add(any(that: isA<NfcReset>())));
  });
}
