// lib/ui/bluetooth/view_model/bluetooth_state.dart
import 'package:equatable/equatable.dart';
import 'package:zplit/core/services/bluetooth_service.dart' show BtEndpoint;

enum BtConnectionStatus { none, pending, connecting, connected, disconnected }

class BluetoothState extends Equatable {
  final bool enabled;
  final bool permissionDenied;
  final List<BtEndpoint> nearbyEndpoints;

  final Map<String, BtConnectionStatus> connectionStatus;

  /// endpointId -> 0.0-1.0, drives a progress indicator during transfer.
  final Map<String, double> transferProgress;

  final String? lastReceivedPayload;
  final String? lastReceivedFromEndpointId;

  final String? errorMessage;

  const BluetoothState({
    this.enabled = false,
    this.permissionDenied = false,
    this.nearbyEndpoints = const [],
    this.connectionStatus = const {},
    this.transferProgress = const {},
    this.lastReceivedPayload,
    this.lastReceivedFromEndpointId,
    this.errorMessage,
  });

  BluetoothState copyWith({
    bool? enabled,
    bool? permissionDenied,
    List<BtEndpoint>? nearbyEndpoints,
    Map<String, BtConnectionStatus>? connectionStatus,
    Map<String, double>? transferProgress,
    String? lastReceivedPayload,
    String? lastReceivedFromEndpointId,
    String? errorMessage,
    bool clearError = false,
    bool clearReceived = false,
  }) {
    return BluetoothState(
      enabled: enabled ?? this.enabled,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      nearbyEndpoints: nearbyEndpoints ?? this.nearbyEndpoints,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      transferProgress: transferProgress ?? this.transferProgress,
      lastReceivedPayload: clearReceived
          ? null
          : (lastReceivedPayload ?? this.lastReceivedPayload),
      lastReceivedFromEndpointId: clearReceived
          ? null
          : (lastReceivedFromEndpointId ?? this.lastReceivedFromEndpointId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    permissionDenied,
    nearbyEndpoints,
    connectionStatus,
    transferProgress,
    lastReceivedPayload,
    lastReceivedFromEndpointId,
    errorMessage,
  ];
}
