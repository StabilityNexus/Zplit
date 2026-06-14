import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:zplit/core/database/daos/balances_dao.dart';

import 'package:zplit/core/database/daos/groups_dao.dart';
import 'package:zplit/core/database/daos/transactions_dao.dart';
import 'package:zplit/core/database/daos/users_dao.dart';

import 'package:zplit/core/database/tables/groups_table.dart';

import 'tables/users_table.dart';
import 'tables/transactions_table.dart';
import 'tables/balances_table.dart';

import 'package:uuid/uuid.dart';

part '../../generated/app_database.g.dart';

const _uuid = Uuid();

@DriftDatabase(
  tables: [UsersTable, TransactionsTable, BalancesTable, GroupsTable],
  daos: [TransactionsDao, GroupsDao, UsersDao, BalancesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(balancesTable, balancesTable.currency);
        await m.addColumn(transactionsTable, transactionsTable.currency);
      }
      if (from < 3) {
        await m.addColumn(usersTable, usersTable.defaultCurrency);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'zplit.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
