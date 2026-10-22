abstract class GroupEvent {}

class LoadAllGroups extends GroupEvent {}

class GetGroupById extends GroupEvent {
  final String id;
  GetGroupById(this.id);
}

/// Creates a group, or updates an existing one when [id] is provided.
/// (Before, there was no id here, so every save created a brand-new group and
/// editing was impossible.)
class UpsertGroup extends GroupEvent {
  final String? id;
  final String name;
  final String? description;
  final List<String> users;

  UpsertGroup({
    this.id,
    required this.name,
    this.description,
    this.users = const [],
  });
}

class DeleteGroup extends GroupEvent {
  final String id;
  DeleteGroup(this.id);
}
