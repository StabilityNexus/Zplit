abstract class NfcEvent {}

/// User flips the NFC switch on/off in InviteFriendsScreen (or anywhere
/// else NFC is exposed).
class NfcToggled extends NfcEvent {
  final bool enabled;
  NfcToggled(this.enabled);
}

/// User taps "Tap to Share" — waits for a tap, then writes [payload]
/// to the other device.
class NfcSendPayload extends NfcEvent {
  final String payload;
  NfcSendPayload(this.payload);
}

/// User taps "Tap to Receive" — waits for a tap, reads whatever is
/// written there, and (if valid) surfaces it as lastReceivedPayload.
class NfcStartListening extends NfcEvent {}

/// Clears any previous received payload / error, e.g. after the
/// listener has consumed it and dispatched it onward to DeepLinkBloc.
class NfcReset extends NfcEvent {}
