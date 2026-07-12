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
  TransactionReceived({
    required this.txnId,
    required this.fromUserId,
    required this.fromUserName,
    required this.amount,
    required this.desc,
    this.tag,
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
