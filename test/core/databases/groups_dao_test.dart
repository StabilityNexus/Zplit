import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/groups_dao.dart';
import 'test_database.dart';

void main() {
  group('GroupsDao', () {
    late AppDatabase db;
    late GroupsDao dao;

    setUp(() {
      db = createTestDb();
      dao = db.groupsDao;
    });

    tearDown(() => db.close());

    test('getAll returns empty list initially', () async {
      final result = await dao.getAll();
      expect(result, isEmpty);
    });

    test('upsert inserts a group', () async {
      await dao.upsert(
        const GroupsTableCompanion(
          id: Value('group_1'),
          name: Value('Weekend Trip'),
        ),
      );

      final result = await dao.getAll();
      expect(result.length, 1);
      expect(result.first.name, 'Weekend Trip');
    });

    test('getById returns correct group', () async {
      await dao.upsert(
        const GroupsTableCompanion(
          id: Value('group_1'),
          name: Value('Weekend Trip'),
        ),
      );

      final group = await dao.getById('group_1');
      expect(group, isA<GroupsTableData>());
      expect(group!.name, 'Weekend Trip');
    });

    test('getById returns null for unknown id', () async {
      final group = await dao.getById('group_nobody');
      expect(group == null, true);
    });

    test('upsert updates existing group', () async {
      await dao.upsert(
        const GroupsTableCompanion(
          id: Value('group_1'),
          name: Value('Weekend Trip'),
        ),
      );
      await dao.upsert(
        const GroupsTableCompanion(
          id: Value('group_1'),
          name: Value('Europe Trip'),
        ),
      );

      final group = await dao.getById('group_1');
      expect(group!.name, 'Europe Trip');
    });

    test('deletegroup removes the group', () async {
      await dao.upsert(
        const GroupsTableCompanion(
          id: Value('group_1'),
          name: Value('Weekend Trip'),
        ),
      );

      await dao.deleteGroup('group_1');

      final group = await dao.getById('group_1');
      expect(group == null, true);
    });

    test('deletegroup returns 0 for non-existent group', () async {
      final count = await dao.deleteGroup('group_nobody');
      expect(count, 0);
    });
  });
}
