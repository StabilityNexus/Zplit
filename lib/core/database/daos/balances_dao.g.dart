// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balances_dao.dart';

// ignore_for_file: type=lint
mixin _$BalancesDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  $BalancesTableTable get balancesTable => attachedDatabase.balancesTable;
  BalancesDaoManager get managers => BalancesDaoManager(this);
}

class BalancesDaoManager {
  final _$BalancesDaoMixin _db;
  BalancesDaoManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
  $$BalancesTableTableTableManager get balancesTable =>
      $$BalancesTableTableTableManager(_db.attachedDatabase, _db.balancesTable);
}
