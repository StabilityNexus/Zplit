import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/tables/transactions_table.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [TransactionsTable])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<List<TransactionsTableData>> getAll() {
    return select(transactionsTable).get();
  }

  Future<TransactionsTableData?> getById(String id) {
    final query = select(transactionsTable);
    query.where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<int> deleteById(String id) {
    return (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateSenderSignature(String id, String signature) {
    return (update(transactionsTable)..where((t) => t.id.equals(id))).write(
      TransactionsTableCompanion(senderSignature: Value(signature)),
    );
  }

  Stream<List<TransactionsTableData>> watchByPublicKey(String publicKey) =>
      (select(transactionsTable)
            ..where(
              (t) =>
                  t.fromUserPublicKey.equals(publicKey) |
                  t.toUserPublicKey.equals(publicKey),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<int> insert(TransactionsTableCompanion transaction) {
    return into(transactionsTable).insert(transaction);
  }

  Future<void> insertOrIgnore(TransactionsTableCompanion companion) {
    return into(transactionsTable).insertOnConflictUpdate(companion);
  }

  Future<void> updateStatus(
    String id,
    TransactionStatus status, {
    String? receiverSignature,
  }) => (update(transactionsTable)..where((t) => t.id.equals(id))).write(
    TransactionsTableCompanion(
      status: Value(status),
      receiverSignature: Value(receiverSignature),
    ),
  );
}
