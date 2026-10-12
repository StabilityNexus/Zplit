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

class ReceiveIncomingTransaction extends TransactionEvent {
  final String id;
  final String fromUserPublicKey;
  final String toUserPublicKey;
  final BigInt amount;
  final String currency;
  final String? description;
  final String? tag;

  ReceiveIncomingTransaction({
    required this.id,
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
  AcceptTransaction({required this.transactionId});
}

class RejectTransaction extends TransactionEvent {
  final String transactionId;
  RejectTransaction(this.transactionId);
}
