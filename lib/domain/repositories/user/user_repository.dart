import 'package:zplit/domain/models/user/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> getAllUsers();
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> getUserByPublicKey(String publicKey);
  Future<void> upsertUser({
    required String publicKey,
    required String displayName,
    String? cryptoAddress,
    String? profilePicture,
    required String defaultCurrency,
  });
  Future<int> deleteUser(String publicKey);
}
