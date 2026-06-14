import 'package:drift/drift.dart';
import 'package:zplit/core/database/tables/balances_table.dart';
import 'package:zplit/core/database/app_database.dart';

part '../../../generated/balances_dao.g.dart';

@DriftAccessor(tables: [BalancesTable])
class BalancesDao extends DatabaseAccessor<AppDatabase>
    with _$BalancesDaoMixin {
  BalancesDao(super.db);

  Future<List<BalancesTableData>> getAll() {
    return select(balancesTable).get();
  }

  Future<BalancesTableData?> getByPublicKey(String userPublicKey) {
    final query = select(balancesTable);
    query.where((t) => t.userPublicKey.equals(userPublicKey));
    return query.getSingleOrNull();
  }

  // we can just use upsert for update and insert
  Future<void> upsert(BalancesTableCompanion balance) {
    return into(balancesTable).insertOnConflictUpdate(balance);
  }

  Future<int> deleteBalances(String userPublicKey) {
    final query = delete(balancesTable);
    query.where((t) => t.userPublicKey.equals(userPublicKey));
    return query.go();
  }
}
