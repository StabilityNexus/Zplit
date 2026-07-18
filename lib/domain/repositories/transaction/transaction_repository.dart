import 'package:zplit/domain/models/transaction/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getAllTransactions();

  Future<TransactionModel?> getTransactionById(String id);

  Future<void> createTransaction({
    required String fromUserPublicKey,
    required String toUserPublicKey,
    required BigInt amount,
    required String currency,
    String? description,
    String? tag,
  });

  Future<void> receiveIncoming({
    required String id,
    required String fromUserPublicKey,
    required String toUserPublicKey,
    required BigInt amount,
    required String currency,
    String? description,
    String? tag,
  });

  Future<void> signAsSender({
    required String transactionId,
    required String senderSignature,
  });

  Future<void> acceptTransaction({required String transactionId});

  Future<void> rejectTransaction(String transactionId);

  Future<void> applyRemoteAck({
    required String transactionId,
    required String outcome,
  });
}
