import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/group_model.dart';
import '../../../domain/repositories/home_repository.dart';

part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  GroupsBloc(this._repository) : super(GroupsInitial()) {
    on<GroupsStarted>((event, emit) {
      emit(GroupsSuccess(_repository.getGroups()));
    });
  }

  final HomeRepository _repository;
}
