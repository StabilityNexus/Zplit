part of 'home_bloc.dart';

sealed class HomeEvent {}

final class HomeTabSelected extends HomeEvent {
  final int index;
  HomeTabSelected(this.index);
}
