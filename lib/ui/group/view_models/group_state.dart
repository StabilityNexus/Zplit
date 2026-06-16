import 'package:zplit/domain/models/group/group_model.dart';

abstract class GroupState {}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupLoaded extends GroupState {
  final List<GroupModel> groups;
  GroupLoaded(this.groups);
}

class GroupError extends GroupState {
  final String message;
  GroupError(this.message);
}
