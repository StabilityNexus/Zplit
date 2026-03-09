part of 'groups_bloc.dart';

sealed class GroupsState {}

final class GroupsInitial extends GroupsState {}

final class GroupsSuccess extends GroupsState {
  final List<GroupModel> groups;
  GroupsSuccess(this.groups);
}
