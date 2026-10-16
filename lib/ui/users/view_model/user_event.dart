abstract class UserEvent {}

class LoadAllUsers extends UserEvent {}

class GetUserByPublicKey extends UserEvent {
  final String publicKey;
  GetUserByPublicKey(this.publicKey);
}

class UpsertUser extends UserEvent {
  final String publicKey;
  final String displayName;
  final String? cryptoAddress;
  final String? profilePicture;
  final String defaultCurrency;

  UpsertUser({
    required this.publicKey,
    required this.displayName,
    this.cryptoAddress,
    this.profilePicture,
    required this.defaultCurrency,
  });
}

class DeleteUser extends UserEvent {
  final String publicKey;
  DeleteUser(this.publicKey);
}
