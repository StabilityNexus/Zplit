import 'package:drift/drift.dart';

class UsersTable extends Table {
  TextColumn get publicKey => text()();
  TextColumn get displayName => text()();
  TextColumn get cryptoAddress => text().nullable()();
  TextColumn get profilePicture => text().nullable()();
  TextColumn get defaultCurrency => text()();

  @override
  String get tableName => 'users';

  @override
  Set<Column> get primaryKey => {publicKey};
}
