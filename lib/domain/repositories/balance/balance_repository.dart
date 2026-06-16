import 'package:zplit/domain/models/balance/balance_model.dart';

abstract class BalanceRepository {
  Future<List<BalanceModel>> getAllBalances();
  Future<List<BalanceModel>> getBalancesForUser(String userPublicKey);
  Future<BalanceModel?> getBalanceForUserAndCurrency(
    String userPublicKey,
    String currency,
  );
  Future<List<BalanceModel>> getPositiveBalances();
  Future<List<BalanceModel>> getNegativeBalances();
  Future<void> upsertBalance({
    required String userPublicKey,
    required int netAmount,
    required String currency,
    String? signed,
  });
  Future<int> deleteByPublicKey(String userPublicKey);
}
