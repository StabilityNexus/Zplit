import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/transactions_dao.dart';
import 'package:zplit/core/database/daos/balances_dao.dart';
import 'package:zplit/core/database/tables/transactions_table.dart';
import 'package:zplit/core/services/crypto_service.dart';
import 'package:zplit/domain/models/transaction/transaction_model.dart';
import 'package:zplit/domain/repositories/transaction/transaction_repository.dart';

const _uuid = Uuid();

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionsDao _transactionsDao;
  final BalancesDao _balancesDao;

  TransactionRepositoryImpl({
    required TransactionsDao transactionsDao,
    required BalancesDao balancesDao,
  }) : _transactionsDao = transactionsDao,
       _balancesDao = balancesDao;

  TransactionModel _toModel(TransactionsTableData d) => TransactionModel(
    id: d.id,
    fromUserPublicKey: d.fromUserPublicKey,
    toUserPublicKey: d.toUserPublicKey,
    amount: d.amount,
    currency: d.currency,
    status: d.status,
    description: d.description,
    tag: d.tag,
    createdAt: d.createdAt,
    senderSignature: d.senderSignature,
    receiverSignature: d.receiverSignature,
  );

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final rows = await _transactionsDao.getAll();
    return rows.map(_toModel).toList();
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    final row = await _transactionsDao.getById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> createTransaction({
    required String fromUserPublicKey,
    required String toUserPublicKey,
    required BigInt amount,
    required String currency,
    String? description,
    String? tag,
  }) {
    return _transactionsDao.insert(
      TransactionsTableCompanion.insert(
        id: _uuid.v4(),
        fromUserPublicKey: fromUserPublicKey,
        toUserPublicKey: toUserPublicKey,
        amount: amount,
        currency: currency,
        status: TransactionStatus.unsigned,
        description: Value(description),
        tag: Value(tag),
      ),
    );
  }

  @override
  Future<void> receiveIncoming({
    required String id,
    required String fromUserPublicKey,
    required String toUserPublicKey,
    required BigInt amount,
    required String currency,
    String? description,
    String? tag,
  }) {
    return _transactionsDao.insertOrIgnore(
      TransactionsTableCompanion.insert(
        id: id,
        fromUserPublicKey: fromUserPublicKey,
        toUserPublicKey: toUserPublicKey,
        amount: amount,
        currency: currency,
        status: TransactionStatus.unsigned,
        description: Value(description),
        tag: Value(tag),
      ),
    );
  }

  @override
  Future<void> signAsSender({
    required String transactionId,
    required String senderSignature,
  }) async {
    await _transactionsDao.updateSenderSignature(
      transactionId,
      senderSignature,
    );
  }

  @override
  Future<void> acceptTransaction({required String transactionId}) async {
    final existing = await _transactionsDao.getById(transactionId);
    if (existing == null) throw Exception('Transaction not found');

    final counterpartyKey = existing.fromUserPublicKey;

    final currentBalance = await _balancesDao.getByPublicKeyAndCurrency(
      counterpartyKey,
      existing.currency,
    );
    final currentNet = BigInt.from(currentBalance?.netAmount ?? 0);

    final newNet = currentNet + existing.amount;

    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final receiverSignature = await CryptoService.signBalance(
      fromPublicKey: counterpartyKey,
      toPublicKey: existing.toUserPublicKey,
      netAmount: newNet,
      currency: existing.currency,
    );
    final signedBalancePayload = CryptoService.buildBalancePayload(
      fromPublicKey: counterpartyKey,
      toPublicKey: existing.toUserPublicKey,
      netAmount: newNet,
      currency: existing.currency,
      timestamp: ts,
    );

    await _transactionsDao.updateStatus(
      transactionId,
      TransactionStatus.signed,
      receiverSignature: receiverSignature,
    );

    await _balancesDao.upsert(
      BalancesTableCompanion(
        userPublicKey: Value(counterpartyKey),
        currency: Value(existing.currency),
        netAmount: Value(newNet.toInt()),
        signed: Value(signedBalancePayload),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> rejectTransaction(String transactionId) async {
    await _transactionsDao.deleteById(transactionId);
  }
}
