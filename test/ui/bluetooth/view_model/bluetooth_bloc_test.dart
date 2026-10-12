import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/core/services/bluetooth_service.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';

class MockBluetoothTransportService extends Mock
    implements BluetoothTransportService {}

void main() {
  late MockBluetoothTransportService mockService;
  late StreamController<ZplitBtEvent> serviceEvents;

  setUp(() {
    mockService = MockBluetoothTransportService();
    serviceEvents = StreamController<ZplitBtEvent>.broadcast();

    when(() => mockService.events).thenAnswer((_) => serviceEvents.stream);
    when(() => mockService.stopAll()).thenAnswer((_) async {});
    when(() => mockService.dispose()).thenAnswer((_) {});
    when(() => mockService.startAdvertising(any())).thenAnswer((_) async {});
    when(() => mockService.startDiscovery(any())).thenAnswer((_) async {});
    when(
      () => mockService.requestConnection(any(), any()),
    ).thenAnswer((_) async {});
    when(() => mockService.acceptConnection(any())).thenAnswer((_) async {});
    when(() => mockService.rejectConnection(any())).thenAnswer((_) async {});
    when(() => mockService.sendPayload(any(), any())).thenAnswer((_) async {});
    when(() => mockService.disconnect(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await serviceEvents.close();
  });

  BluetoothBloc buildBloc() => BluetoothBloc(service: mockService);

  // NOTE: blocTest closes the bloc *before* it runs `verify`, and
  // BluetoothBloc.close() calls service.stopAll(). So any verify on stopAll()
  // below uses greaterThan(0) rather than an exact count.

  group('BluetoothToggled', () {
    blocTest<BluetoothBloc, BluetoothState>(
      'enables, starts advertising and discovery when permissions granted',
      setUp: () {
        when(
          () => mockService.ensurePermissions(),
        ).thenAnswer((_) async => true);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothToggled(true, 'Alex')),
      expect: () => [
        const BluetoothState(enabled: true, permissionDenied: false),
      ],
      verify: (_) {
        verify(() => mockService.ensurePermissions()).called(1);
        verify(() => mockService.startAdvertising('Alex')).called(1);
        verify(() => mockService.startDiscovery('Alex')).called(1);
      },
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'sets permissionDenied and stays disabled when permissions are refused',
      setUp: () {
        when(
          () => mockService.ensurePermissions(),
        ).thenAnswer((_) async => false);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothToggled(true, 'Alex')),
      expect: () => [
        const BluetoothState(permissionDenied: true, enabled: false),
      ],
      verify: (_) {
        verifyNever(() => mockService.startAdvertising(any()));
        verifyNever(() => mockService.startDiscovery(any()));
      },
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'stops everything and clears endpoints/status when turned off',
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothToggled(false, 'Alex')),
      expect: () => [
        const BluetoothState(
          enabled: false,
          nearbyEndpoints: [],
          connectionStatus: {},
        ),
      ],
      verify: (_) {
        verify(() => mockService.stopAll()).called(greaterThan(0));
      },
    );
  });

  group('BluetoothConnectRequested', () {
    blocTest<BluetoothBloc, BluetoothState>(
      'marks the endpoint as connecting and requests a connection',
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothConnectRequested('e1', 'Alex')),
      expect: () => [
        const BluetoothState(
          connectionStatus: {'e1': BtConnectionStatus.connecting},
        ),
      ],
      verify: (_) {
        verify(() => mockService.requestConnection('Alex', 'e1')).called(1);
      },
    );
  });

  group('BluetoothConnectionAccepted / Rejected', () {
    blocTest<BluetoothBloc, BluetoothState>(
      'accepting delegates to the service',
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothConnectionAccepted('e1')),
      expect: () => <BluetoothState>[],
      verify: (_) {
        verify(() => mockService.acceptConnection('e1')).called(1);
      },
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'rejecting delegates to the service',
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothConnectionRejected('e1')),
      expect: () => <BluetoothState>[],
      verify: (_) {
        verify(() => mockService.rejectConnection('e1')).called(1);
      },
    );
  });

  group('BluetoothSendPayload', () {
    blocTest<BluetoothBloc, BluetoothState>(
      'sends the payload via the service without emitting on success',
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothSendPayload('e1', '{"id":"u1"}')),
      expect: () => <BluetoothState>[],
      verify: (_) {
        verify(() => mockService.sendPayload('e1', '{"id":"u1"}')).called(1);
      },
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'emits an error message when the service throws',
      setUp: () {
        when(
          () => mockService.sendPayload(any(), any()),
        ).thenThrow(Exception('link dropped'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothSendPayload('e1', '{"id":"u1"}')),
      expect: () => [
        isA<BluetoothState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          contains('Send failed'),
        ),
      ],
    );
  });

  group('BluetoothDisconnectRequested', () {
    blocTest<BluetoothBloc, BluetoothState>(
      'delegates to the service',
      build: buildBloc,
      act: (bloc) => bloc.add(const BluetoothDisconnectRequested('e1')),
      expect: () => <BluetoothState>[],
      verify: (_) {
        verify(() => mockService.disconnect('e1')).called(1);
      },
    );
  });

  group('service event stream -> internal state updates', () {
    blocTest<BluetoothBloc, BluetoothState>(
      'BtEndpointFound adds a new endpoint and de-duplicates by id',
      build: buildBloc,
      act: (_) {
        serviceEvents.add(BtEndpointFound(BtEndpoint('e1', 'Alex')));
        serviceEvents.add(BtEndpointFound(BtEndpoint('e1', 'Alex')));
      },
      expect: () => [
        isA<BluetoothState>().having(
          (s) => s.nearbyEndpoints,
          'nearbyEndpoints',
          hasLength(1),
        ),
      ],
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtEndpointLost removes the endpoint',
      build: buildBloc,
      act: (_) async {
        serviceEvents.add(BtEndpointFound(BtEndpoint('e1', 'Alex')));
        await pumpEventQueue();
        serviceEvents.add(BtEndpointLost('e1'));
      },
      skip: 1, // ignore the BtEndpointFound emission
      expect: () => [
        isA<BluetoothState>().having(
          (s) => s.nearbyEndpoints,
          'nearbyEndpoints',
          isEmpty,
        ),
      ],
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtConnectionInitiated marks pending and auto-accepts',
      build: buildBloc,
      act: (_) =>
          serviceEvents.add(BtConnectionInitiated('e1', 'Alex', 'token-123')),
      // Matcher form: at least one emitted state has e1 == pending.
      expect: () => contains(
        isA<BluetoothState>().having(
          (s) => s.connectionStatus['e1'],
          'connectionStatus[e1]',
          BtConnectionStatus.pending,
        ),
      ),
      verify: (_) {
        verify(() => mockService.acceptConnection('e1')).called(1);
      },
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtConnected marks the endpoint connected and clears any error',
      build: buildBloc,
      act: (_) => serviceEvents.add(BtConnected('e1')),
      expect: () => [
        isA<BluetoothState>()
            .having(
              (s) => s.connectionStatus['e1'],
              'connectionStatus[e1]',
              BtConnectionStatus.connected,
            )
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtConnectionRejected resets status to none',
      build: buildBloc,
      act: (_) async {
        serviceEvents.add(BtConnectionInitiated('e1', 'Alex', 'token-123'));
        await pumpEventQueue();
        serviceEvents.add(BtConnectionRejected('e1'));
      },
      // Only the final state matters here, so check `.last` via a predicate.
      expect: () => predicate<List<BluetoothState>>(
        (states) =>
            states.last.connectionStatus['e1'] == BtConnectionStatus.none,
        'last state has e1 == none',
      ),
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtConnectionError sets status to none for that endpoint and surfaces the message',
      build: buildBloc,
      act: (_) => serviceEvents.add(BtConnectionError('e1', 'link busy')),
      expect: () => [
        isA<BluetoothState>()
            .having(
              (s) => s.connectionStatus['e1'],
              'connectionStatus[e1]',
              BtConnectionStatus.none,
            )
            .having((s) => s.errorMessage, 'errorMessage', 'link busy'),
      ],
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtConnectionError with an empty endpointId leaves connectionStatus untouched',
      build: buildBloc,
      act: (_) => serviceEvents.add(BtConnectionError('', 'discovery failed')),
      expect: () => [
        isA<BluetoothState>()
            .having((s) => s.connectionStatus, 'connectionStatus', isEmpty)
            .having((s) => s.errorMessage, 'errorMessage', 'discovery failed'),
      ],
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtDisconnected marks disconnected, clears progress, and surfaces a reconnect hint',
      build: buildBloc,
      act: (_) async {
        serviceEvents.add(BtConnected('e1'));
        await pumpEventQueue();
        serviceEvents.add(BtTransferProgress('e1', 0.5));
        await pumpEventQueue();
        serviceEvents.add(BtDisconnected('e1'));
      },
      skip: 2, // ignore BtConnected and BtTransferProgress emissions
      expect: () => [
        isA<BluetoothState>()
            .having(
              (s) => s.connectionStatus['e1'],
              'connectionStatus[e1]',
              BtConnectionStatus.disconnected,
            )
            .having(
              (s) => s.transferProgress.containsKey('e1'),
              'transferProgress has e1',
              isFalse,
            )
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Connection lost — you can reconnect and resend',
            ),
      ],
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtPayloadReceived surfaces the payload and sender',
      build: buildBloc,
      act: (_) => serviceEvents.add(BtPayloadReceived('e1', '{"id":"u1"}')),
      expect: () => [
        isA<BluetoothState>()
            .having(
              (s) => s.lastReceivedPayload,
              'lastReceivedPayload',
              '{"id":"u1"}',
            )
            .having(
              (s) => s.lastReceivedFromEndpointId,
              'lastReceivedFromEndpointId',
              'e1',
            ),
      ],
    );

    blocTest<BluetoothBloc, BluetoothState>(
      'BtTransferProgress updates progress for that endpoint only',
      build: buildBloc,
      act: (_) async {
        serviceEvents.add(BtTransferProgress('e2', 0.1));
        await pumpEventQueue();
        serviceEvents.add(BtTransferProgress('e1', 0.42));
      },
      skip: 1, // ignore the first progress emission
      expect: () => [
        isA<BluetoothState>().having(
          (s) => s.transferProgress,
          'transferProgress',
          {'e2': 0.1, 'e1': 0.42},
        ),
      ],
    );
  });

  group('clearReceivedPayload', () {
    blocTest<BluetoothBloc, BluetoothState>(
      'clears lastReceivedPayload and lastReceivedFromEndpointId',
      build: buildBloc,
      act: (bloc) async {
        serviceEvents.add(BtPayloadReceived('e1', '{"id":"u1"}'));
        await pumpEventQueue();
        bloc.clearReceivedPayload();
      },
      skip: 1, // ignore the BtPayloadReceived emission
      expect: () => [
        isA<BluetoothState>()
            .having((s) => s.lastReceivedPayload, 'lastReceivedPayload', isNull)
            .having(
              (s) => s.lastReceivedFromEndpointId,
              'lastReceivedFromEndpointId',
              isNull,
            ),
      ],
    );
  });

  group('close', () {
    // blocTest closes the bloc itself, so this one stays a plain test.
    test(
      'stops the service, disposes it, and cancels the subscription',
      () async {
        final bloc = buildBloc();
        await bloc.close();

        verify(() => mockService.stopAll()).called(1);
        verify(() => mockService.dispose()).called(1);
      },
    );
  });
}
