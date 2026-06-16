import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/features/group/domain/models/group_model.dart';
import 'package:zplit/features/group/domain/repositories/group_repository.dart';
import 'package:zplit/features/group/presentation/group_bloc.dart';
import 'package:zplit/features/group/presentation/group_event.dart';
import 'package:zplit/features/group/presentation/group_state.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository mockRepository;
  late GroupBloc groupBloc;

  final testGroups = [
    GroupModel(
      id: '1',
      name: 'Trip to Goa',
      description: 'Beach trip',
      users: ['alice', 'bob'],
    ),
    GroupModel(
      id: '2',
      name: 'Office Lunch',
      description: null,
      users: ['charlie'],
    ),
  ];

  setUp(() {
    mockRepository = MockGroupRepository();
    groupBloc = GroupBloc(groupRepository: mockRepository);
  });

  tearDown(() {
    groupBloc.close();
  });

  group('LoadAllGroups', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupLoaded] when successful',
      build: () {
        when(
          () => mockRepository.getAllGroups(),
        ).thenAnswer((_) async => testGroups);
        return groupBloc;
      },
      act: (bloc) => bloc.add(LoadAllGroups()),
      expect: () => [isA<GroupLoading>(), isA<GroupLoaded>()],
      verify: (_) {
        verify(() => mockRepository.getAllGroups()).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupError] when repository throws',
      build: () {
        when(
          () => mockRepository.getAllGroups(),
        ).thenThrow(Exception('DB error'));
        return groupBloc;
      },
      act: (bloc) => bloc.add(LoadAllGroups()),
      expect: () => [isA<GroupLoading>(), isA<GroupError>()],
    );
  });

  group('GetGroupById', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupLoaded] with group when found',
      build: () {
        when(
          () => mockRepository.getGroupById('1'),
        ).thenAnswer((_) async => testGroups.first);
        return groupBloc;
      },
      act: (bloc) => bloc.add(GetGroupById('1')),
      expect: () => [isA<GroupLoading>(), isA<GroupLoaded>()],
      verify: (bloc) {
        final state = bloc.state as GroupLoaded;
        expect(state.groups.length, 1);
        expect(state.groups.first.id, '1');
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupLoaded] with empty list when not found',
      build: () {
        when(
          () => mockRepository.getGroupById('999'),
        ).thenAnswer((_) async => null);
        return groupBloc;
      },
      act: (bloc) => bloc.add(GetGroupById('999')),
      expect: () => [isA<GroupLoading>(), isA<GroupLoaded>()],
      verify: (bloc) {
        final state = bloc.state as GroupLoaded;
        expect(state.groups, isEmpty);
      },
    );
  });

  group('UpsertGroup', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupLoaded] after upserting',
      build: () {
        when(
          () => mockRepository.upsertGroup(
            name: 'New Group',
            description: 'desc',
            users: ['alice'],
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getAllGroups(),
        ).thenAnswer((_) async => testGroups);
        return groupBloc;
      },
      act: (bloc) => bloc.add(
        UpsertGroup(name: 'New Group', description: 'desc', users: ['alice']),
      ),
      expect: () => [isA<GroupLoading>(), isA<GroupLoaded>()],
    );
  });

  group('DeleteGroup', () {
    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupLoaded] after deleting',
      build: () {
        when(() => mockRepository.deleteGroup('1')).thenAnswer((_) async => 1);
        when(
          () => mockRepository.getAllGroups(),
        ).thenAnswer((_) async => testGroups);
        return groupBloc;
      },
      act: (bloc) => bloc.add(DeleteGroup('1')),
      expect: () => [isA<GroupLoading>(), isA<GroupLoaded>()],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [GroupLoading, GroupError] when delete throws',
      build: () {
        when(
          () => mockRepository.deleteGroup('1'),
        ).thenThrow(Exception('Delete failed'));
        return groupBloc;
      },
      act: (bloc) => bloc.add(DeleteGroup('1')),
      expect: () => [isA<GroupLoading>(), isA<GroupError>()],
    );
  });
}
