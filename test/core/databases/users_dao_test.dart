import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/users_dao.dart';
import 'test_database.dart';

void main() {
  group('UsersDao', () {
    late AppDatabase db;
    late UsersDao dao;

    setUp(() {
      db = createTestDb();
      dao = db.usersDao;
    });

    tearDown(() => db.close());

    test('getAll returns empty list initially', () async {
      final result = await dao.getAll();
      expect(result, isEmpty);
    });

    test('upsert inserts a user', () async {
      await dao.upsert(
        const UsersTableCompanion(
          publicKey: Value('pk_alice'),
          displayName: Value('Alice'),
        ),
      );

      final result = await dao.getAll();
      expect(result.length, 1);
      expect(result.first.publicKey, 'pk_alice');
      expect(result.first.displayName, 'Alice');
    });

    test('getByPublicKey returns correct user', () async {
      await dao.upsert(
        const UsersTableCompanion(
          publicKey: Value('pk_bob'),
          displayName: Value('Bob'),
        ),
      );

      final user = await dao.getByPublicKey('pk_bob');
      expect(user, isA<UsersTableData>());
      expect(user!.displayName, 'Bob');
    });

    test('getByPublicKey returns null for unknown key', () async {
      final user = await dao.getByPublicKey('pk_nobody');
      expect(user == null, true);
    });

    test('upsert updates existing user', () async {
      await dao.upsert(
        const UsersTableCompanion(
          publicKey: Value('pk_alice'),
          displayName: Value('Alice'),
        ),
      );
      await dao.upsert(
        const UsersTableCompanion(
          publicKey: Value('pk_alice'),
          displayName: Value('Alice Updated'),
        ),
      );

      final user = await dao.getByPublicKey('pk_alice');
      expect(user!.displayName, 'Alice Updated');
    });

    test('deleteuser removes the user', () async {
      await dao.upsert(
        const UsersTableCompanion(
          publicKey: Value('pk_alice'),
          displayName: Value('Alice'),
        ),
      );

      await dao.deleteUser('pk_alice');

      final user = await dao.getByPublicKey('pk_alice');
      expect(user == null, true);
    });

    test('deleteuser returns 0 for non-existent user', () async {
      final count = await dao.deleteUser('pk_nobody');
      expect(count, 0);
    });
  });
}
