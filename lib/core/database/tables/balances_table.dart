import 'package:drift/drift.dart';
import 'package:zplit/core/database/tables/users_table.dart';

class BalancesTable extends Table {
  TextColumn get userPublicKey => text().references(UsersTable, #publicKey)();
  IntColumn get netAmount => integer()();
  TextColumn get signed => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get currency => text()();
  @override
  String get tableName => 'balances';

  @override
  Set<Column> get primaryKey => {userPublicKey, currency};
}
