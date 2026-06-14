import 'package:drift/drift.dart';
import 'package:zplit/core/database/tables/users_table.dart';
import 'package:zplit/core/database/app_database.dart';

part '../../../generated/users_dao.g.dart';

@DriftAccessor(tables: [UsersTable])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<List<UsersTableData>> getAll() {
    return select(usersTable).get();
  }

  Future<UsersTableData?> getByPublicKey(String publicKey) {
    final query = select(usersTable);
    query.where((t) => t.publicKey.equals(publicKey));
    return query.getSingleOrNull();
  }

  Future<void> upsert(UsersTableCompanion user) {
    return into(usersTable).insertOnConflictUpdate(user);
  }

  Future<int> deleteUser(String publicKey) {
    final query = delete(usersTable);
    query.where((t) => t.publicKey.equals(publicKey));
    return query.go();
  }
}
