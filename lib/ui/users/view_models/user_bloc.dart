import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/domain/repositories/user/user_repository.dart';
import 'package:zplit/ui/users/view_models/user_event.dart';
import 'package:zplit/ui/users/view_models/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(UserInitial()) {
    on<LoadAllUsers>(_onLoadAllUsers);
    on<GetUserByPublicKey>(_onGetUserByPublicKey);
    on<UpsertUser>(_onUpsertUser);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final users = await _userRepository.getAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onGetUserByPublicKey(
    GetUserByPublicKey event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getUserByPublicKey(event.publicKey);
      emit(UserLoaded(user == null ? [] : [user]));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpsertUser(UpsertUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.upsertUser(
        publicKey: event.publicKey,
        displayName: event.displayName,
        cryptoAddress: event.cryptoAddress,
        profilePicture: event.profilePicture,
        defaultCurrency: event.defaultCurrency,
      );
      final users = await _userRepository.getAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.deleteUser(event.publicKey);
      final users = await _userRepository.getAllUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
