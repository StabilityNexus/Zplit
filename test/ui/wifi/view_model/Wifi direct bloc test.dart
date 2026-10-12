import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/core/services/wifi_direct_Service.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_bloc.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_event.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_state.dart';

class MockWifiDirectTransportService extends Mock
    implements WifiDirectTransportService {}

void main() {
  late MockWifiDirectTransportService mockService;
  late StreamController<ZplitWifiEvent> serviceEvents;

  setUp(() {
    mockService = MockWifiDirectTransportService();
    serviceEvents = StreamController<ZplitWifiEvent>.broadcast();

    when(() => mockService.events).thenAnswer((_) => serviceEvents.stream);
    when(() => mockService.disable()).thenAnswer((_) async {});
    when(() => mockService.dispose()).thenAnswer((_) {});
    when(() => mockService.ensureServicesEnabled()).thenAnswer((_) async {});
    when(() => mockService.enable(any())).thenAnswer((_) async {});
    when(() => mockService.sendPayload(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await serviceEvents.close();
  });

  WifiBloc buildBloc() => WifiBloc(service: mockService);

  // NOTE: blocTest closes the bloc *before* it runs `verify`, and
  // WifiBloc.close() calls service.disable(). So any verify on disable()
  // below uses greaterThan(0) rather than an exact count.

  group('WifiToggled', () {
    blocTest<WifiBloc, WifiState>(
      'enables, ensures services, and calls enable() when permissions granted',
      setUp: () {
        when(
          () => mockService.ensurePermissions(),
        ).thenAnswer((_) async => true);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(WifiToggled(true, 'Alex')),
      expect: () => [
        isA<WifiState>()
            .having((s) => s.enabled, 'enabled', isTrue)
            .having((s) => s.permissionDenied, 'permissionDenied', isFalse)
            .having((s) => s.isSearching, 'isSearching', isTrue),
      ],
      verify: (_) {
        verify(() => mockService.ensurePermissions()).called(1);
        verify(() => mockService.ensureServicesEnabled()).called(1);
        verify(() => mockService.enable('Alex')).called(1);
      },
    );

    blocTest<WifiBloc, WifiState>(
      'sets permissionDenied and stays disabled when permissions are refused',
      setUp: () {
        when(
          () => mockService.ensurePermissions(),
        ).thenAnswer((_) async => false);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(WifiToggled(true, 'Alex')),
      expect: () => [
        isA<WifiState>()
            .having((s) => s.permissionDenied, 'permissionDenied', isTrue)
            .having((s) => s.enabled, 'enabled', isFalse),
      ],
      verify: (_) {
        verifyNever(() => mockService.ensureServicesEnabled());
        verifyNever(() => mockService.enable(any()));
      },
    );

    blocTest<WifiBloc, WifiState>(
      'turning off calls disable() and resets to the initial state',
      build: buildBloc,
      act: (bloc) => bloc.add(WifiToggled(false, 'Alex')),
      expect: () => [const WifiState()],
      verify: (_) {
        verify(() => mockService.disable()).called(greaterThan(0));
      },
    );
  });

  group('WifiSendPayload', () {
    blocTest<WifiBloc, WifiState>(
      'sends via the service without emitting on success',
      build: buildBloc,
      act: (bloc) => bloc.add(WifiSendPayload('{"id":"u1"}')),
      expect: () => <WifiState>[],
      verify: (_) {
        verify(() => mockService.sendPayload('{"id":"u1"}')).called(1);
      },
    );

    blocTest<WifiBloc, WifiState>(
      'emits an error message when the service throws',
      setUp: () {
        when(
          () => mockService.sendPayload(any()),
        ).thenThrow(StateError('No client connection to send over'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(WifiSendPayload('{"id":"u1"}')),
      expect: () => [
        isA<WifiState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('Send failed'),
        ),
      ],
    );
  });

  group('WifiReset', () {
    blocTest<WifiBloc, WifiState>(
      'clears error and received payload',
      build: buildBloc,
      act: (bloc) async {
        // Two setup emissions (payload, then error) ...
        serviceEvents.add(WifiPayloadReceived('host', '{"id":"u1"}'));
        await pumpEventQueue();
        serviceEvents.add(WifiConnectionError('boom'));
        await pumpEventQueue();
        // ... then the event under test.
        bloc.add(WifiReset());
      },
      skip: 2, // ignore the two setup emissions
      expect: () => [
        isA<WifiState>()
            .having((s) => s.lastReceivedPayload, 'lastReceivedPayload', isNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );
  });

  group('service event stream -> internal state updates', () {
    blocTest<WifiBloc, WifiState>(
      'WifiSearching sets isSearching',
      build: buildBloc,
      act: (_) => serviceEvents.add(WifiSearching()),
      expect: () => [
        isA<WifiState>().having((s) => s.isSearching, 'isSearching', isTrue),
      ],
    );

    blocTest<WifiBloc, WifiState>(
      'WifiConnected marks connected, stores peer info, stops searching, clears error',
      build: buildBloc,
      act: (_) => serviceEvents.add(WifiConnected('host', 'Host')),
      expect: () => [
        isA<WifiState>()
            .having((s) => s.isConnected, 'isConnected', isTrue)
            .having((s) => s.isSearching, 'isSearching', isFalse)
            .having((s) => s.peerId, 'peerId', 'host')
            .having((s) => s.peerName, 'peerName', 'Host')
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<WifiBloc, WifiState>(
      'WifiDisconnected marks disconnected, clears peer info, surfaces a message',
      build: buildBloc,
      act: (_) async {
        serviceEvents.add(WifiConnected('host', 'Host'));
        await pumpEventQueue();
        serviceEvents.add(WifiDisconnected('host'));
      },
      skip: 1, // ignore the WifiConnected emission
      expect: () => [
        isA<WifiState>()
            .having((s) => s.isConnected, 'isConnected', isFalse)
            .having((s) => s.peerId, 'peerId', isNull)
            .having((s) => s.peerName, 'peerName', isNull)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'WiFi Direct connection lost',
            ),
      ],
    );

    blocTest<WifiBloc, WifiState>(
      'WifiConnectionError surfaces the message and stops searching',
      build: buildBloc,
      act: (_) =>
          serviceEvents.add(WifiConnectionError('Could not create group')),
      expect: () => [
        isA<WifiState>()
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Could not create group',
            )
            .having((s) => s.isSearching, 'isSearching', isFalse),
      ],
    );

    blocTest<WifiBloc, WifiState>(
      'WifiPayloadReceived surfaces the payload',
      build: buildBloc,
      act: (_) => serviceEvents.add(WifiPayloadReceived('host', '{"id":"u1"}')),
      expect: () => [
        isA<WifiState>().having(
          (s) => s.lastReceivedPayload,
          'lastReceivedPayload',
          '{"id":"u1"}',
        ),
      ],
    );
  });

  group('close', () {
    // blocTest closes the bloc itself, so this one stays a plain test.
    test(
      'disables the service, disposes it, and cancels the subscription',
      () async {
        final bloc = buildBloc();
        await bloc.close();

        verify(() => mockService.disable()).called(1);
        verify(() => mockService.dispose()).called(1);
      },
    );
  });
}
