import 'package:zplit/core/database/tables/transactions_table.dart';

class TransactionModel {
  final String id;
  final String fromUserPublicKey;
  final String toUserPublicKey;
  final BigInt amount;
  final String currency;
  final TransactionStatus status;
  final String? description;
  final String? tag;
  final DateTime createdAt;
  final String? senderSignature;
  final String? receiverSignature;

  const TransactionModel({
    required this.id,
    required this.fromUserPublicKey,
    required this.toUserPublicKey,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    this.tag,
    required this.createdAt,
    this.senderSignature,
    this.receiverSignature,
  });
}
