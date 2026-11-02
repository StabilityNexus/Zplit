class NfcState {
  final bool enabled;
  final bool isBusy;
  final String? errorMessage;
  final String? lastReceivedPayload;

  const NfcState({
    this.enabled = false,
    this.isBusy = false,
    this.errorMessage,
    this.lastReceivedPayload,
  });

  NfcState copyWith({
    bool? enabled,
    bool? isBusy,
    String? errorMessage,
    String? lastReceivedPayload,
    bool clearError = false,
    bool clearReceived = false,
  }) {
    return NfcState(
      enabled: enabled ?? this.enabled,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastReceivedPayload: clearReceived
          ? null
          : (lastReceivedPayload ?? this.lastReceivedPayload),
    );
  }
}
