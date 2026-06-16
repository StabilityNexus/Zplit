import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/groups_dao.dart';

import 'package:zplit/domain/models/group/group_model.dart';
import 'package:zplit/domain/repositories/group/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupsDao _groupsDao;

  GroupRepositoryImpl({required GroupsDao groupsDao}) : _groupsDao = groupsDao;

  GroupModel _toModel(GroupsTableData d) => GroupModel(
    id: d.id,
    name: d.name,
    description: d.description,
    users: d.users.isEmpty
        ? []
        : d.users.split(',').map((e) => e.trim()).toList(),
  );

  @override
  Future<List<GroupModel>> getAllGroups() async {
    final rows = await _groupsDao.getAll();
    return rows.map(_toModel).toList();
  }

  @override
  Future<GroupModel?> getGroupById(String id) async {
    final row = await _groupsDao.getById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> upsertGroup({
    required String name,
    String? description,
    List<String> users = const [],
  }) {
    return _groupsDao.upsert(
      GroupsTableCompanion(
        name: Value(name),
        description: Value(description),
        users: Value(users.join(',')),
      ),
    );
  }

  @override
  Future<int> deleteGroup(String id) {
    return _groupsDao.deleteGroup(id);
  }
}
