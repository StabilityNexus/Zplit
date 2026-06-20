class User {
  final String id;
  final String name;
  final String? email;

  User({
    required this.id,
    required this.name,
    this.email,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name}';
  }
}
