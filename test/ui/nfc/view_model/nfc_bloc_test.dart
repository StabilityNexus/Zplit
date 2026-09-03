import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/core/services/nfc_service.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';

class MockNfcService extends Mock implements NfcService {}

// Predicate helper since NfcState does not override == / hashCode,
// so identity-based equals() won't match distinct instances with
// equal fields — bloc_test's expect() needs a Matcher, not `equals`.
Matcher isNfcState({
  bool? enabled,
  bool? isBusy,
  Object? errorMessage = _unset,
  Object? lastReceivedPayload = _unset,
}) {
  return predicate<NfcState>(
    (s) {
      if (enabled != null && s.enabled != enabled) return false;
      if (isBusy != null && s.isBusy != isBusy) return false;
      if (!identical(errorMessage, _unset) && s.errorMessage != errorMessage) {
        return false;
      }
      if (!identical(lastReceivedPayload, _unset) &&
          s.lastReceivedPayload != lastReceivedPayload) {
        return false;
      }
      return true;
    },
    'NfcState(enabled: $enabled, isBusy: $isBusy, '
    'errorMessage: ${identical(errorMessage, _unset) ? '<any>' : errorMessage}, '
    'lastReceivedPayload: ${identical(lastReceivedPayload, _unset) ? '<any>' : lastReceivedPayload})',
  );
}

const _unset = Object();

void main() {
  late MockNfcService mockNfcService;

  setUp(() {
    mockNfcService = MockNfcService();
  });

  group('NfcToggled', () {
    blocTest<NfcBloc, NfcState>(
      'emits enabled:true, no error, when NFC is available',
      setUp: () {
        when(() => mockNfcService.isAvailable()).thenAnswer((_) async => true);
      },
      build: () => NfcBloc(nfcService: mockNfcService),
      act: (bloc) => bloc.add(NfcToggled(true)),
      expect: () => [isNfcState(enabled: true, errorMessage: null)],
      verify: (_) {
        verify(() => mockNfcService.isAvailable()).called(1);
      },
    );

    blocTest<NfcBloc, NfcState>(
      'emits enabled:false with an error message when NFC is unavailable',
      setUp: () {
        when(() => mockNfcService.isAvailable()).thenAnswer((_) async => false);
      },
      build: () => NfcBloc(nfcService: mockNfcService),
      act: (bloc) => bloc.add(NfcToggled(true)),
      expect: () => [
        isNfcState(
          enabled: false,
          errorMessage: 'NFC not available on this device',
        ),
      ],
    );

    blocTest<NfcBloc, NfcState>(
      'disabling does not check availability and clears any prior error',
      build: () => NfcBloc(nfcService: mockNfcService),
      act: (bloc) => bloc.add(NfcToggled(false)),
      expect: () => [isNfcState(enabled: false, errorMessage: null)],
      verify: (_) {
        verifyNever(() => mockNfcService.isAvailable());
      },
    );
  });

  group('NfcSendPayload', () {
    blocTest<NfcBloc, NfcState>(
      'emits busy then not-busy on a successful send',
      setUp: () {
        when(() => mockNfcService.shareViaNfc(any())).thenAnswer((_) async {});
      },
      build: () => NfcBloc(nfcService: mockNfcService),
      act: (bloc) => bloc.add(NfcSendPayload('{"id":1}')),
      expect: () => [
        isNfcState(isBusy: true, errorMessage: null),
        isNfcState(isBusy: false, errorMessage: null),
      ],
      verify: (_) {
        verify(() => mockNfcService.shareViaNfc('{"id":1}')).called(1);
      },
    );

    blocTest<NfcBloc, NfcState>(
      'emits busy then an error message when the send throws',
      setUp: () {
        when(
          () => mockNfcService.shareViaNfc(any()),
        ).thenThrow(Exception('write failed'));
      },
      build: () => NfcBloc(nfcService: mockNfcService),
      act: (bloc) => bloc.add(NfcSendPayload('{"id":1}')),
      expect: () => [
        isNfcState(isBusy: true, errorMessage: null),
        predicate<NfcState>(
          (s) =>
              !s.isBusy &&
              (s.errorMessage ?? '').startsWith('NFC send failed:'),
        ),
      ],
    );
  });

  group('NfcStartListening', () {
    blocTest<NfcBloc, NfcState>(
      'emits busy then the received payload on success',
      setUp: () {
        when(
          () => mockNfcService.receiveViaNfc(),
        ).thenAnswer((_) async => '{"sig":"abc"}');
      },
      build: () => NfcBloc(nfcService: mockNfcService),
      act: (bloc) => bloc.add(NfcStartListening()),
      expect: () => [
        isNfcState(isBusy: true, errorMessage: null),
        isNfcState(isBusy: false, lastReceivedPayload: '{"sig":"abc"}'),
      ],
    );

    blocTest<NfcBloc, NfcState>(
      'emits busy then an error when no readable payload is found',
      setUp: () {
        when(
          () => mockNfcService.receiveViaNfc(),
        ).thenAnswer((_) async => null);
      },
      build: () => NfcBloc(nfcService: mockNfcService),
      act: (bloc) => bloc.add(NfcStartListening()),
      expect: () => [
        isNfcState(isBusy: true, errorMessage: null),
        isNfcState(
          isBusy: false,
          errorMessage: 'No readable data found on tap',
        ),
      ],
    );

    blocTest<NfcBloc, NfcState>(
      'emits busy then an error message when the read throws',
      setUp: () {
        when(
          () => mockNfcService.receiveViaNfc(),
        ).thenThrow(Exception('timeout'));
      },
      build: () => NfcBloc(nfcService: mockNfcService),
      act: (bloc) => bloc.add(NfcStartListening()),
      expect: () => [
        isNfcState(isBusy: true, errorMessage: null),
        predicate<NfcState>(
          (s) =>
              !s.isBusy &&
              (s.errorMessage ?? '').startsWith('NFC receive failed:'),
        ),
      ],
    );
  });

  group('NfcReset', () {
    blocTest<NfcBloc, NfcState>(
      'clears error and last received payload without touching enabled/isBusy',
      build: () => NfcBloc(nfcService: mockNfcService),
      seed: () => const NfcState(
        enabled: true,
        isBusy: false,
        errorMessage: 'boom',
        lastReceivedPayload: 'stale-payload',
      ),
      act: (bloc) => bloc.add(NfcReset()),
      expect: () => [
        isNfcState(
          enabled: true,
          errorMessage: null,
          lastReceivedPayload: null,
        ),
      ],
    );
  });
}
