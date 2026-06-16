import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/features/users/domain/models/user_model.dart';
import 'package:zplit/features/users/domain/repositories/user_repository.dart';
import 'package:zplit/features/users/presentation/user_bloc.dart';
import 'package:zplit/features/users/presentation/user_event.dart';
import 'package:zplit/features/users/presentation/user_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late UserBloc userBloc;

  final tUser1 = UserModel(
    publicKey: 'pk_001',
    displayName: 'Alice',
    cryptoAddress: '0xABC',
    profilePicture: null,
    defaultCurrency: 'USD',
  );

  final tUser2 = UserModel(
    publicKey: 'pk_002',
    displayName: 'Bob',
    cryptoAddress: null,
    profilePicture: null,
    defaultCurrency: 'INR',
  );

  final tUsers = [tUser1, tUser2];

  setUp(() {
    mockUserRepository = MockUserRepository();
    userBloc = UserBloc(userRepository: mockUserRepository);
  });

  tearDown(() {
    userBloc.close();
  });

  test('initial state is UserInitial', () {
    expect(userBloc.state, isA<UserInitial>());
  });

  group('LoadAllUsers', () {
    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when getAllUsers succeeds',
      build: () {
        when(
          () => mockUserRepository.getAllUsers(),
        ).thenAnswer((_) async => tUsers);
        return userBloc;
      },
      act: (bloc) => bloc.add(LoadAllUsers()),
      expect: () => [isA<UserLoading>(), isA<UserLoaded>()],
      verify: (_) {
        verify(() => mockUserRepository.getAllUsers()).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] with correct users list',
      build: () {
        when(
          () => mockUserRepository.getAllUsers(),
        ).thenAnswer((_) async => tUsers);
        return userBloc;
      },
      act: (bloc) => bloc.add(LoadAllUsers()),
      expect: () => [
        isA<UserLoading>(),
        predicate<UserState>(
          (s) => s is UserLoaded && s.users.length == 2,
          'UserLoaded with 2 users',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] with empty list when no users exist',
      build: () {
        when(
          () => mockUserRepository.getAllUsers(),
        ).thenAnswer((_) async => []);
        return userBloc;
      },
      act: (bloc) => bloc.add(LoadAllUsers()),
      expect: () => [
        isA<UserLoading>(),
        predicate<UserState>(
          (s) => s is UserLoaded && s.users.isEmpty,
          'UserLoaded with empty list',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when getAllUsers throws',
      build: () {
        when(
          () => mockUserRepository.getAllUsers(),
        ).thenThrow(Exception('DB error'));
        return userBloc;
      },
      act: (bloc) => bloc.add(LoadAllUsers()),
      expect: () => [isA<UserLoading>(), isA<UserError>()],
    );
  });

  group('GetUserByPublicKey', () {
    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] with single user when found',
      build: () {
        when(
          () => mockUserRepository.getUserByPublicKey('pk_001'),
        ).thenAnswer((_) async => tUser1);
        return userBloc;
      },
      act: (bloc) => bloc.add(GetUserByPublicKey('pk_001')),
      expect: () => [
        isA<UserLoading>(),
        predicate<UserState>(
          (s) =>
              s is UserLoaded &&
              s.users.length == 1 &&
              s.users.first.publicKey == 'pk_001',
          'UserLoaded with tUser1',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] with empty list when user not found',
      build: () {
        when(
          () => mockUserRepository.getUserByPublicKey('unknown'),
        ).thenAnswer((_) async => null);
        return userBloc;
      },
      act: (bloc) => bloc.add(GetUserByPublicKey('unknown')),
      expect: () => [
        isA<UserLoading>(),
        predicate<UserState>(
          (s) => s is UserLoaded && s.users.isEmpty,
          'UserLoaded with empty list',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when getUserByPublicKey throws',
      build: () {
        when(
          () => mockUserRepository.getUserByPublicKey(any()),
        ).thenThrow(Exception('Not found'));
        return userBloc;
      },
      act: (bloc) => bloc.add(GetUserByPublicKey('pk_001')),
      expect: () => [isA<UserLoading>(), isA<UserError>()],
    );
  });

  group('UpsertUser', () {
    final tUpsertEvent = UpsertUser(
      publicKey: 'pk_001',
      displayName: 'Alice Updated',
      cryptoAddress: '0xABC',
      profilePicture: null,
      defaultCurrency: 'USD',
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] after successful upsert',
      build: () {
        when(
          () => mockUserRepository.upsertUser(
            publicKey: any(named: 'publicKey'),
            displayName: any(named: 'displayName'),
            cryptoAddress: any(named: 'cryptoAddress'),
            profilePicture: any(named: 'profilePicture'),
            defaultCurrency: any(named: 'defaultCurrency'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockUserRepository.getAllUsers(),
        ).thenAnswer((_) async => tUsers);
        return userBloc;
      },
      act: (bloc) => bloc.add(tUpsertEvent),
      expect: () => [isA<UserLoading>(), isA<UserLoaded>()],
      verify: (_) {
        verify(
          () => mockUserRepository.upsertUser(
            publicKey: 'pk_001',
            displayName: 'Alice Updated',
            cryptoAddress: '0xABC',
            profilePicture: null,
            defaultCurrency: 'USD',
          ),
        ).called(1);
        verify(() => mockUserRepository.getAllUsers()).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when upsert throws',
      build: () {
        when(
          () => mockUserRepository.upsertUser(
            publicKey: any(named: 'publicKey'),
            displayName: any(named: 'displayName'),
            cryptoAddress: any(named: 'cryptoAddress'),
            profilePicture: any(named: 'profilePicture'),
            defaultCurrency: any(named: 'defaultCurrency'),
          ),
        ).thenThrow(Exception('Upsert failed'));
        return userBloc;
      },
      act: (bloc) => bloc.add(tUpsertEvent),
      expect: () => [isA<UserLoading>(), isA<UserError>()],
    );
  });

  group('DeleteUser', () {
    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] after successful delete',
      build: () {
        when(
          () => mockUserRepository.deleteUser('pk_001'),
        ).thenAnswer((_) async => 1);
        when(
          () => mockUserRepository.getAllUsers(),
        ).thenAnswer((_) async => [tUser2]); // only tUser2 remains
        return userBloc;
      },
      act: (bloc) => bloc.add(DeleteUser('pk_001')),
      expect: () => [
        isA<UserLoading>(),
        predicate<UserState>(
          (s) => s is UserLoaded && s.users.length == 1,
          'UserLoaded with 1 remaining user',
        ),
      ],
      verify: (_) {
        verify(() => mockUserRepository.deleteUser('pk_001')).called(1);
        verify(() => mockUserRepository.getAllUsers()).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError] when delete throws',
      build: () {
        when(
          () => mockUserRepository.deleteUser(any()),
        ).thenThrow(Exception('Delete failed'));
        return userBloc;
      },
      act: (bloc) => bloc.add(DeleteUser('pk_001')),
      expect: () => [isA<UserLoading>(), isA<UserError>()],
    );
  });
}
