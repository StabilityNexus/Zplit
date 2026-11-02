import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class GroupsTable extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  // storing member public keys as a set (comma separated string)
  TextColumn get users => text().withDefault(const Constant(''))();
  TextColumn get description => text().nullable()();

  @override
  String get tableName => 'groups';

  @override
  Set<Column> get primaryKey => {id};
}
