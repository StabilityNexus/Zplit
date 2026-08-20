abstract class WifiEvent {}

class WifiToggled extends WifiEvent {
  final bool enabled;
  final String myDisplayName;
  WifiToggled(this.enabled, this.myDisplayName);
}

class WifiSendPayload extends WifiEvent {
  final String jsonPayload;
  WifiSendPayload(this.jsonPayload);
}

class WifiReset extends WifiEvent {}

class WifiInternalEvent extends WifiEvent {
  final dynamic rawEvent; // ZplitWifiEvent, kept dynamic to avoid a
  // circular import between event/service files.
  WifiInternalEvent(this.rawEvent);
}
