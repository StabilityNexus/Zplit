import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/core/services/wifi_direct_Service.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';

import 'package:zplit/ui/wifi/view_model/Wifi_direct_bloc.dart';
import 'package:zplit/ui/wifi/wifi_link_bridge.dart';

class MockWifiDirectTransportService extends Mock
    implements WifiDirectTransportService {}

class MockDeepLinkBloc extends MockBloc<DeepLinkEvent, DeepLinkState>
    implements DeepLinkBloc {}

void main() {
  late MockWifiDirectTransportService mockService;
  late StreamController<ZplitWifiEvent> serviceEvents;
  late WifiBloc wifiBloc;
  late MockDeepLinkBloc mockDeepLinkBloc;

  setUpAll(() {
    registerFallbackValue(WifiInviteReceived(''));
  });

  setUp(() {
    mockService = MockWifiDirectTransportService();
    serviceEvents = StreamController<ZplitWifiEvent>.broadcast();
    when(() => mockService.events).thenAnswer((_) => serviceEvents.stream);
    when(() => mockService.disable()).thenAnswer((_) async {});
    when(() => mockService.dispose()).thenAnswer((_) {});

    wifiBloc = WifiBloc(service: mockService);
    mockDeepLinkBloc = MockDeepLinkBloc();
  });

  tearDown(() async {
    await wifiBloc.close();
    await serviceEvents.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<WifiBloc>.value(value: wifiBloc),
            BlocProvider<DeepLinkBloc>.value(value: mockDeepLinkBloc),
          ],
          child: const WifiLinkBridge(child: SizedBox.shrink()),
        ),
      ),
    );
  }

  testWidgets(
    'routes a payload with a "sig" key to WifiTransactionReceived and resets',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      serviceEvents.add(
        WifiPayloadReceived('host', '{"sig":"abc123","amount":500}'),
      );
      await tester.pump();
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<WifiTransactionReceived>());

      // WifiReset was dispatched and processed by the real bloc.
      expect(wifiBloc.state.lastReceivedPayload, isNull);
    },
  );

  testWidgets(
    'routes a payload with an "outcome" key to WifiAckReceived and resets',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      serviceEvents.add(
        WifiPayloadReceived('host', '{"outcome":"accepted","id":"txn-1"}'),
      );
      await tester.pump();
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<WifiAckReceived>());

      expect(wifiBloc.state.lastReceivedPayload, isNull);
    },
  );

  testWidgets(
    'routes a payload with neither key to WifiInviteReceived and resets',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      serviceEvents.add(
        WifiPayloadReceived('host', '{"id":"user-1","name":"Alex"}'),
      );
      await tester.pump();
      await tester.pump();

      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      expect(captured.single, isA<WifiInviteReceived>());

      expect(wifiBloc.state.lastReceivedPayload, isNull);
    },
  );

  testWidgets(
    'shows a snackbar and does not touch DeepLinkBloc for unreadable JSON',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      serviceEvents.add(WifiPayloadReceived('host', 'not valid json'));
      await tester.pump();
      await tester.pump(); // let the SnackBar animate in

      expect(
        find.text('Received an unreadable payload over WiFi Direct'),
        findsOneWidget,
      );
      verifyNever(() => mockDeepLinkBloc.add(any()));
      expect(wifiBloc.state.lastReceivedPayload, isNull);
    },
  );

  testWidgets(
    'shows a snackbar when the payload is valid JSON but not a JSON object',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      serviceEvents.add(WifiPayloadReceived('host', '[1,2,3]'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Received an unreadable payload over WiFi Direct'),
        findsOneWidget,
      );
      verifyNever(() => mockDeepLinkBloc.add(any()));
      expect(wifiBloc.state.lastReceivedPayload, isNull);
    },
  );

  testWidgets(
    'handles two distinct payloads in sequence, each triggering its own dispatch',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      serviceEvents.add(WifiPayloadReceived('host', '{"id":"user-1"}'));
      await tester.pump();
      await tester.pump();

      serviceEvents.add(WifiPayloadReceived('host', '{"id":"user-2"}'));
      await tester.pump();
      await tester.pump();

      // WifiReset clears lastReceivedPayload to null after each handled
      // payload, so every subsequent WifiPayloadReceived is a genuine
      // null -> value transition from listenWhen's point of view. Two
      // payloads in a row, even with different content, therefore dispatch
      // twice.
      final captured = verify(
        () => mockDeepLinkBloc.add(captureAny()),
      ).captured;
      expect(captured, hasLength(2));
      expect(captured.every((e) => e is WifiInviteReceived), isTrue);
      expect(wifiBloc.state.lastReceivedPayload, isNull);
    },
  );
}
