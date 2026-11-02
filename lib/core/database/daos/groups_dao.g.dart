// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_dao.dart';

// ignore_for_file: type=lint
mixin _$GroupsDaoMixin on DatabaseAccessor<AppDatabase> {
  $GroupsTableTable get groupsTable => attachedDatabase.groupsTable;
  GroupsDaoManager get managers => GroupsDaoManager(this);
}

class GroupsDaoManager {
  final _$GroupsDaoMixin _db;
  GroupsDaoManager(this._db);
  $$GroupsTableTableTableManager get groupsTable =>
      $$GroupsTableTableTableManager(_db.attachedDatabase, _db.groupsTable);
}
