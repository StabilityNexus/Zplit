import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeTabSelected>((event, emit) {
      emit(state.copyWith(
        previousIndex: state.selectedIndex,
        selectedIndex: event.index,
      ));
    });
  }
}
