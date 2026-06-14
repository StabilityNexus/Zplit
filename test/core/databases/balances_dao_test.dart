import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/balances_dao.dart';
import 'test_database.dart';

void main() {
  group('BalancesDao', () {
    late AppDatabase db;
    late BalancesDao dao;

    setUp(() async {
      db = createTestDb();
      dao = db.balancesDao;
      // balances references users so we need a user first
      await db.usersDao.upsert(
        const UsersTableCompanion(
          publicKey: Value('pk_alice'),
          displayName: Value('Alice'),
        ),
      );
    });

    tearDown(() => db.close());

    test('getAll returns empty list initially', () async {
      final result = await dao.getAll();
      expect(result, isEmpty);
    });

    test('upsert inserts a balance', () async {
      await dao.upsert(
        const BalancesTableCompanion(
          userPublicKey: Value('pk_alice'),
          netAmount: Value(100),
        ),
      );

      final result = await dao.getAll();
      expect(result.length, 1);
      expect(result.first.netAmount, 100);
    });

    test('getByPublicKey returns correct balance', () async {
      await dao.upsert(
        const BalancesTableCompanion(
          userPublicKey: Value('pk_alice'),
          netAmount: Value(50),
        ),
      );

      final balance = await dao.getByPublicKey('pk_alice');
      expect(balance, isA<BalancesTableData>());
      expect(balance!.netAmount, 50);
    });

    test('getByPublicKey returns null for unknown key', () async {
      final balance = await dao.getByPublicKey('pk_nobody');
      expect(balance == null, true);
    });

    test('upsert updates existing balance', () async {
      await dao.upsert(
        const BalancesTableCompanion(
          userPublicKey: Value('pk_alice'),
          netAmount: Value(100),
        ),
      );
      await dao.upsert(
        const BalancesTableCompanion(
          userPublicKey: Value('pk_alice'),
          netAmount: Value(200),
        ),
      );

      final balance = await dao.getByPublicKey('pk_alice');
      expect(balance!.netAmount, 200);
    });

    test('deletebalaces removes the balance', () async {
      await dao.upsert(
        const BalancesTableCompanion(
          userPublicKey: Value('pk_alice'),
          netAmount: Value(100),
        ),
      );

      await dao.deleteBalances('pk_alice');

      final balance = await dao.getByPublicKey('pk_alice');
      expect(balance == null, true);
    });
  });
}
