// lib/ui/bluetooth/view_model/bluetooth_event.dart
import 'package:equatable/equatable.dart';

sealed class BluetoothEvent extends Equatable {
  const BluetoothEvent();
  @override
  List<Object?> get props => [];
}

/// Kicks off permission checks then starts both advertising (so others
/// can find you) and discovery (so you can find others) at once — this
/// is what your UI's Bluetooth toggle should fire onChanged(true).
class BluetoothToggled extends BluetoothEvent {
  final bool enabled;
  final String myDisplayName;
  const BluetoothToggled(this.enabled, this.myDisplayName);
  @override
  List<Object?> get props => [enabled, myDisplayName];
}

class BluetoothConnectRequested extends BluetoothEvent {
  final String endpointId;
  final String myDisplayName;
  const BluetoothConnectRequested(this.endpointId, this.myDisplayName);
  @override
  List<Object?> get props => [endpointId, myDisplayName];
}

class BluetoothConnectionAccepted extends BluetoothEvent {
  final String endpointId;
  const BluetoothConnectionAccepted(this.endpointId);
  @override
  List<Object?> get props => [endpointId];
}

class BluetoothConnectionRejected extends BluetoothEvent {
  final String endpointId;
  const BluetoothConnectionRejected(this.endpointId);
  @override
  List<Object?> get props => [endpointId];
}

/// Sends a transaction/invite payload to an already-connected endpoint.
/// [jsonPayload] should be built the exact same way you build the QR /
/// deep-link payload (same signed schema) — see integration notes.
class BluetoothSendPayload extends BluetoothEvent {
  final String endpointId;
  final String jsonPayload;
  const BluetoothSendPayload(this.endpointId, this.jsonPayload);
  @override
  List<Object?> get props => [endpointId, jsonPayload];
}

class BluetoothDisconnectRequested extends BluetoothEvent {
  final String endpointId;
  const BluetoothDisconnectRequested(this.endpointId);
  @override
  List<Object?> get props => [endpointId];
}

// Internal events — fed by the service's event stream, not called
// directly from the UI.
class BluetoothInternalEvent extends BluetoothEvent {
  final Object rawEvent;
  const BluetoothInternalEvent(this.rawEvent);
  @override
  List<Object?> get props => [rawEvent];
}
