part of 'deep_link_bloc.dart';

sealed class DeepLinkEvent {
  const DeepLinkEvent();
}

class DeepLinkReceived extends DeepLinkEvent {
  final Uri uri;
  const DeepLinkReceived(this.uri);
}

class BluetoothInviteReceived extends DeepLinkEvent {
  final String jsonPayload;
  const BluetoothInviteReceived(this.jsonPayload);
}

class BluetoothAckReceived extends DeepLinkEvent {
  final String jsonPayload;
  const BluetoothAckReceived(this.jsonPayload);
}

class BluetoothTransactionReceived extends DeepLinkEvent {
  final String jsonPayload;
  const BluetoothTransactionReceived(this.jsonPayload);
}

class NfcInviteReceived extends DeepLinkEvent {
  final String jsonPayload;
  const NfcInviteReceived(this.jsonPayload);
}

class NfcAckReceived extends DeepLinkEvent {
  final String jsonPayload;
  const NfcAckReceived(this.jsonPayload);
}

class NfcTransactionReceived extends DeepLinkEvent {
  final String jsonPayload;
  const NfcTransactionReceived(this.jsonPayload);
}
