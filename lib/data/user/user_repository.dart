import 'package:drift/drift.dart';
import 'package:zplit/core/database/app_database.dart';
import 'package:zplit/core/database/daos/users_dao.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/domain/repositories/user/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UsersDao _usersDao;

  UserRepositoryImpl({required UsersDao usersDao}) : _usersDao = usersDao;

  UserModel _toModel(UsersTableData d) => UserModel(
    publicKey: d.publicKey,
    displayName: d.displayName,
    cryptoAddress: d.cryptoAddress,
    profilePicture: d.profilePicture,
    defaultCurrency: d.defaultCurrency,
  );

  @override
  Future<List<UserModel>> getAllUsers() async {
    final rows = await _usersDao.getAll();
    return rows.map(_toModel).toList();
  }

  @override
  Future<UserModel?> getUserByPublicKey(String publicKey) async {
    final row = await _usersDao.getByPublicKey(publicKey);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> upsertUser({
    required String publicKey,
    required String displayName,
    String? cryptoAddress,
    String? profilePicture,
    required String defaultCurrency,
  }) {
    return _usersDao.upsert(
      UsersTableCompanion(
        publicKey: Value(publicKey),
        displayName: Value(displayName),
        cryptoAddress: Value(cryptoAddress),
        profilePicture: Value(profilePicture),
        defaultCurrency: Value(defaultCurrency),
      ),
    );
  }

  @override
  Future<int> deleteUser(String publicKey) {
    return _usersDao.deleteUser(publicKey);
  }
}
