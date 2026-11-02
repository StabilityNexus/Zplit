abstract class TransactionEvent {}

class LoadAllTransactions extends TransactionEvent {}

class GetTransactionById extends TransactionEvent {
  final String id;
  GetTransactionById(this.id);
}

class CreateTransaction extends TransactionEvent {
  final String fromUserPublicKey;
  final String toUserPublicKey;
  final BigInt amount;
  final String currency;
  final String? description;
  final String? tag;

  CreateTransaction({
    required this.fromUserPublicKey,
    required this.toUserPublicKey,
    required this.amount,
    required this.currency,
    this.description,
    this.tag,
  });
}

class SignAsSender extends TransactionEvent {
  final String transactionId;
  final String senderSignature;
  SignAsSender({required this.transactionId, required this.senderSignature});
}

class AcceptTransaction extends TransactionEvent {
  final String transactionId;
  final String receiverSignature;
  final String signedBalancePayload;
  AcceptTransaction({
    required this.transactionId,
    required this.receiverSignature,
    required this.signedBalancePayload,
  });
}

class RejectTransaction extends TransactionEvent {
  final String transactionId;
  RejectTransaction(this.transactionId);
}
