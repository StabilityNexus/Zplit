import 'package:drift/native.dart';
import 'package:zplit/core/database/app_database.dart';

AppDatabase createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
