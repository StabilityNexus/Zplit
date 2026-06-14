import 'package:drift/drift.dart';
import 'package:zplit/core/database/tables/transactions_table.dart';
import 'package:zplit/core/database/app_database.dart';

part '../../../generated/transactions_dao.g.dart';

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

  Future<int> insert(TransactionsTableCompanion transaction) {
    return into(transactionsTable).insert(transaction);
  }
}
