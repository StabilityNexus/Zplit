import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/balances_dao.dart';
import 'package:zplit/core/database/tables/balances_table.dart';
import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/repositories/balance/balance_repository.dart';

class BalanceRepositoryImpl implements BalanceRepository {
  final BalancesDao _balancesDao;

  BalanceRepositoryImpl({required BalancesDao balancesDao})
    : _balancesDao = balancesDao;

  BalanceModel _toModel(BalancesTableData d) => BalanceModel(
    userPublicKey: d.userPublicKey,
    netAmount: d.netAmount,
    currency: d.currency,
    signed: d.signed,
    updatedAt: d.updatedAt,
  );

  @override
  Future<List<BalanceModel>> getAllBalances() async {
    final rows = await _balancesDao.getAll();
    return rows.map(_toModel).toList();
  }

  @override
  Future<List<BalanceModel>> getBalancesForUser(String userPublicKey) async {
    final all = await _balancesDao.getAll();
    return all
        .where((b) => b.userPublicKey == userPublicKey)
        .map(_toModel)
        .toList();
  }

  @override
  Future<BalanceModel?> getBalanceForUserAndCurrency(
    String userPublicKey,
    String currency,
  ) async {
    final row = await _balancesDao.getByPublicKeyAndCurrency(
      userPublicKey,
      currency,
    );
    return row == null ? null : _toModel(row);
  }

  @override
  Future<List<BalanceModel>> getPositiveBalances() async {
    final all = await _balancesDao.getAll();
    return all.where((b) => b.netAmount > 0).map(_toModel).toList();
  }

  @override
  Future<List<BalanceModel>> getNegativeBalances() async {
    final all = await _balancesDao.getAll();
    return all.where((b) => b.netAmount < 0).map(_toModel).toList();
  }

  @override
  Future<void> upsertBalance({
    required String userPublicKey,
    required int netAmount,
    required String currency,
    String? signed,
  }) {
    return _balancesDao.upsert(
      BalancesTableCompanion(
        userPublicKey: Value(userPublicKey),
        netAmount: Value(netAmount),
        currency: Value(currency),
        signed: Value(signed),
      ),
    );
  }

  @override
  Future<int> deleteByPublicKey(String userPublicKey) {
    return _balancesDao.deleteBalances(userPublicKey);
  }
}
