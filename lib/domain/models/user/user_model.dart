class UserModel {
  final String publicKey;
  final String displayName;
  final String? cryptoAddress;
  final String? profilePicture;
  final String defaultCurrency;

  const UserModel({
    required this.publicKey,
    required this.displayName,
    this.cryptoAddress,
    this.profilePicture,
    required this.defaultCurrency,
  });
}
