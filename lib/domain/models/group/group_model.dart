class GroupModel {
  final String id;
  final String name;
  final String? description;
  final List<String> users;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.users,
  });
}
