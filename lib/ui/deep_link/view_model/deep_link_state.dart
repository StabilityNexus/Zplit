part of 'deep_link_bloc.dart';

abstract class DeepLinkState {}

class DeepLinkInitial extends DeepLinkState {}

class DeepLinkLoading extends DeepLinkState {}

class InviteHandled extends DeepLinkState {
  final String displayName;
  InviteHandled(this.displayName);
}

class TransactionReceived extends DeepLinkState {
  final String txnId;
  final String fromUserId;
  final String fromUserName;
  final double amount;
  final String desc;
  final String? tag;

  /// Which transport this transaction arrived over — 'bluetooth',
  /// 'nfc', 'wifi', or null for QR/deep-link (no reply channel).
  /// Used by home_screen._sendAck to route the accept/reject
  /// response back the same way it came in.
  final String? viaTransport;

  TransactionReceived({
    required this.txnId,
    required this.fromUserId,
    required this.fromUserName,
    required this.amount,
    required this.desc,
    this.tag,
    this.viaTransport,
  });
}

class DeepLinkUnknownSender extends DeepLinkState {
  final String senderId;
  DeepLinkUnknownSender(this.senderId);
}

class DeepLinkError extends DeepLinkState {
  final String message;
  DeepLinkError(this.message);
}

class TransactionAckReceived extends DeepLinkState {
  final String txnId;
  final String outcome; // 'rejected' | 'accepted'
  TransactionAckReceived({required this.txnId, required this.outcome});
}
