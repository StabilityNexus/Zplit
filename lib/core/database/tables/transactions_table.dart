import 'package:drift/drift.dart';
import 'package:zplit/core/database/tables/users_table.dart';

enum TransactionStatus { unsigned, partiallySigned, signed }

class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get fromUserPublicKey =>
      text().references(UsersTable, #publicKey)();
  TextColumn get toUserPublicKey => text().references(UsersTable, #publicKey)();
  Int64Column get amount => int64()();
  TextColumn get description => text().nullable()();
  TextColumn get tag => text().nullable()();
  TextColumn get status => textEnum<TransactionStatus>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get senderSignature => text().nullable()();
  TextColumn get receiverSignature => text().nullable()();
  TextColumn get currency => text()();

  @override
  String get tableName => 'transactions';

  @override
  Set<Column> get primaryKey => {id};
}
