abstract class GroupEvent {}

class LoadAllGroups extends GroupEvent {}

class GetGroupById extends GroupEvent {
  final String id;
  GetGroupById(this.id);
}

class UpsertGroup extends GroupEvent {
  final String name;
  final String? description;
  final List<String> users;

  UpsertGroup({required this.name, this.description, this.users = const []});
}

class DeleteGroup extends GroupEvent {
  final String id;
  DeleteGroup(this.id);
}
