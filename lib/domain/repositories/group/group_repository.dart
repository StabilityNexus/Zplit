import 'package:zplit/domain/models/group/group_model.dart';

abstract class GroupRepository {
  Future<List<GroupModel>> getAllGroups();
  Future<GroupModel?> getGroupById(String id);

  /// Creates a group, or updates the existing one when [id] is given.
  Future<void> upsertGroup({
    String? id,
    required String name,
    String? description,
    List<String> users,
  });
  Future<int> deleteGroup(String id);
}
