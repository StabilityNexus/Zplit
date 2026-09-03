class WifiState {
  final bool enabled;
  final bool permissionDenied;
  final bool isSearching;
  final bool isConnected;
  final String? peerName;
  final String? peerId;
  final String? lastReceivedPayload;
  final String? errorMessage;

  const WifiState({
    this.enabled = false,
    this.permissionDenied = false,
    this.isSearching = false,
    this.isConnected = false,
    this.peerName,
    this.peerId,
    this.lastReceivedPayload,
    this.errorMessage,
  });

  WifiState copyWith({
    bool? enabled,
    bool? permissionDenied,
    bool? isSearching,
    bool? isConnected,
    String? peerName,
    String? peerId,
    String? lastReceivedPayload,
    String? errorMessage,
    bool clearError = false,
    bool clearReceived = false,
    bool clearPeer = false,
  }) {
    return WifiState(
      enabled: enabled ?? this.enabled,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      isSearching: isSearching ?? this.isSearching,
      isConnected: isConnected ?? this.isConnected,
      peerName: clearPeer ? null : (peerName ?? this.peerName),
      peerId: clearPeer ? null : (peerId ?? this.peerId),
      lastReceivedPayload: clearReceived
          ? null
          : (lastReceivedPayload ?? this.lastReceivedPayload),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
