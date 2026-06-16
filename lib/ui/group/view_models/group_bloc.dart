import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/domain/repositories/group/group_repository.dart';
import 'package:zplit/ui/group/view_models/group_event.dart';
import 'package:zplit/ui/group/view_models/group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository _groupRepository;

  GroupBloc({required GroupRepository groupRepository})
    : _groupRepository = groupRepository,
      super(GroupInitial()) {
    on<LoadAllGroups>(_onLoadAllGroups);
    on<GetGroupById>(_onGetGroupById);
    on<UpsertGroup>(_onUpsertGroup);
    on<DeleteGroup>(_onDeleteGroup);
  }

  Future<void> _onLoadAllGroups(
    LoadAllGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    try {
      final groups = await _groupRepository.getAllGroups();
      emit(GroupLoaded(groups));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onGetGroupById(
    GetGroupById event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    try {
      final group = await _groupRepository.getGroupById(event.id);
      emit(GroupLoaded(group == null ? [] : [group]));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onUpsertGroup(
    UpsertGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    try {
      await _groupRepository.upsertGroup(
        name: event.name,
        description: event.description,
        users: event.users,
      );
      final groups = await _groupRepository.getAllGroups();
      emit(GroupLoaded(groups));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onDeleteGroup(
    DeleteGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(GroupLoading());
    try {
      await _groupRepository.deleteGroup(event.id);
      final groups = await _groupRepository.getAllGroups();
      emit(GroupLoaded(groups));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }
}
