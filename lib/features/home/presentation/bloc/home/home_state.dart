part of 'home_bloc.dart';

final class HomeState {
  final int selectedIndex;
  final int previousIndex;

  const HomeState({this.selectedIndex = 0, this.previousIndex = 0});

  HomeState copyWith({int? selectedIndex, int? previousIndex}) => HomeState(
    selectedIndex: selectedIndex ?? this.selectedIndex,
    previousIndex: previousIndex ?? this.previousIndex,
  );
}
