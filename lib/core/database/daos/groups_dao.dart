import 'package:drift/drift.dart';
import 'package:zplit/core/database/tables/groups_table.dart';
import 'package:zplit/core/database/app_database.dart';

part '../../../generated/groups_dao.g.dart';

@DriftAccessor(tables: [GroupsTable])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(super.db);

  Future<List<GroupsTableData>> getAll() {
    return select(groupsTable).get();
  }

  Future<GroupsTableData?> getById(String id) {
    final query = select(groupsTable);
    query.where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(GroupsTableCompanion group) {
    return into(groupsTable).insertOnConflictUpdate(group);
  }

  Future<int> deleteGroup(String id) {
    final query = delete(groupsTable);
    query.where((t) => t.id.equals(id));
    return query.go();
  }
}
