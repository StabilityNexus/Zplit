import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/transactions_dao.dart';
import 'package:zplit/core/database/tables/transactions_table.dart';
import 'test_database.dart';

void main() {
  group('TransactionsDao', () {
    late AppDatabase db;
    late TransactionsDao dao;

    setUp(() async {
      db = createTestDb();
      dao = db.transactionsDao;
      // transactions references users
      await db.usersDao.upsert(
        const UsersTableCompanion(
          publicKey: Value('pk_alice'),
          displayName: Value('Alice'),
        ),
      );
      await db.usersDao.upsert(
        const UsersTableCompanion(
          publicKey: Value('pk_bob'),
          displayName: Value('Bob'),
        ),
      );
    });

    tearDown(() => db.close());

    test('getAll returns empty list initially', () async {
      final result = await dao.getAll();
      expect(result, isEmpty);
    });

    test('insert adds a transaction', () async {
      await dao.insert(
        TransactionsTableCompanion(
          id: Value('tx_1'),
          fromUserPublicKey: Value('pk_alice'),
          toUserPublicKey: Value('pk_bob'),
          amount: Value(BigInt.from(30)),
          status: Value(TransactionStatus.unsigned),
        ),
      );

      final result = await dao.getAll();
      expect(result.length, 1);
      expect(result.first.amount, BigInt.from(30));
    });

    test('getById returns correct transaction', () async {
      await dao.insert(
        TransactionsTableCompanion(
          id: Value('tx_1'),
          fromUserPublicKey: Value('pk_alice'),
          toUserPublicKey: Value('pk_bob'),
          amount: Value(BigInt.from(15)),
          status: Value(TransactionStatus.unsigned),
        ),
      );

      final tx = await dao.getById('tx_1');
      expect(tx, isA<TransactionsTableData>());
      expect(tx!.fromUserPublicKey, 'pk_alice');
    });

    test('getById returns null for unknown id', () async {
      final tx = await dao.getById('tx_nobody');
      expect(tx == null, true);
    });

    test('insert multiple transactions', () async {
      await dao.insert(
        TransactionsTableCompanion(
          id: Value('tx_1'),
          fromUserPublicKey: Value('pk_alice'),
          toUserPublicKey: Value('pk_bob'),
          amount: Value(BigInt.from(15)),
          status: Value(TransactionStatus.unsigned),
        ),
      );
      await dao.insert(
        TransactionsTableCompanion(
          id: Value('tx_2'),
          fromUserPublicKey: Value('pk_bob'),
          toUserPublicKey: Value('pk_alice'),
          amount: Value(BigInt.from(15)),
          status: Value(TransactionStatus.signed),
        ),
      );

      final result = await dao.getAll();
      expect(result.length, 2);
    });

    test('transaction status is persisted correctly', () async {
      await dao.insert(
        TransactionsTableCompanion(
          id: Value('tx_1'),
          fromUserPublicKey: Value('pk_alice'),
          toUserPublicKey: Value('pk_bob'),
          amount: Value(BigInt.from(15)),
          status: Value(TransactionStatus.partiallySigned),
        ),
      );

      final tx = await dao.getById('tx_1');
      expect(tx!.status, TransactionStatus.partiallySigned);
    });
  });
}
