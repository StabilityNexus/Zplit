import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';

void main() {
  group('NfcState defaults', () {
    test('default constructor has expected initial values', () {
      const state = NfcState();
      expect(state.enabled, isFalse);
      expect(state.isBusy, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.lastReceivedPayload, isNull);
    });
  });

  group('NfcState.copyWith', () {
    test('overrides enabled and isBusy independently', () {
      const state = NfcState();
      final next = state.copyWith(enabled: true, isBusy: true);

      expect(next.enabled, isTrue);
      expect(next.isBusy, isTrue);
    });

    test('preserves fields that are not passed', () {
      const state = NfcState(enabled: true, isBusy: true);
      final next = state.copyWith();

      expect(next.enabled, isTrue);
      expect(next.isBusy, isTrue);
    });

    test(
      'clearError:true clears errorMessage even if a new one is not given',
      () {
        const state = NfcState(errorMessage: 'boom');
        final next = state.copyWith(clearError: true);

        expect(next.errorMessage, isNull);
      },
    );

    test(
      'errorMessage is replaced when both a new value and no clear flag are given',
      () {
        const state = NfcState(errorMessage: 'old');
        final next = state.copyWith(errorMessage: 'new');

        expect(next.errorMessage, 'new');
      },
    );

    test('passing errorMessage: null without clearError does NOT clear it '
        '(copyWith falls back to the existing value via ??)', () {
      const state = NfcState(errorMessage: 'still here');
      // ignore: avoid_redundant_argument_values
      final next = state.copyWith(errorMessage: null);

      expect(next.errorMessage, 'still here');
    });

    test('clearReceived:true clears lastReceivedPayload', () {
      const state = NfcState(lastReceivedPayload: 'payload');
      final next = state.copyWith(clearReceived: true);

      expect(next.lastReceivedPayload, isNull);
    });

    test('clearError and clearReceived can be combined in one call', () {
      const state = NfcState(
        errorMessage: 'boom',
        lastReceivedPayload: 'payload',
      );
      final next = state.copyWith(clearError: true, clearReceived: true);

      expect(next.errorMessage, isNull);
      expect(next.lastReceivedPayload, isNull);
    });
  });
}
