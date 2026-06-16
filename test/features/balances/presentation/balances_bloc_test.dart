import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/features/balance/domain/models/balance_model.dart';
import 'package:zplit/features/balance/domain/repositories/balance_repository.dart';
import 'package:zplit/features/balance/presentation/balance_bloc.dart';
import 'package:zplit/features/balance/presentation/balance_event.dart';
import 'package:zplit/features/balance/presentation/balance_state.dart';

class MockBalanceRepository extends Mock implements BalanceRepository {}

void main() {
  late MockBalanceRepository repository;

  final balance1 = BalanceModel(
    userPublicKey: 'user1',
    netAmount: 100,
    currency: 'USD',
    signed: 'sig1',
    updatedAt: DateTime(2024, 1, 1),
  );

  final balance2 = BalanceModel(
    userPublicKey: 'user2',
    netAmount: -50,
    currency: 'USD',
    signed: 'sig2',
    updatedAt: DateTime(2024, 1, 2),
  );

  final allBalances = [balance1, balance2];

  setUp(() {
    repository = MockBalanceRepository();
  });

  group('BalanceBloc', () {
    test('initial state is BalanceInitial', () {
      final bloc = BalanceBloc(balanceRepository: repository);
      expect(bloc.state, isA<BalanceInitial>());
    });

    group('LoadAllBalances', () {
      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceLoaded] when successful',
        setUp: () {
          when(
            () => repository.getAllBalances(),
          ).thenAnswer((_) async => allBalances);
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(LoadAllBalances()),
        expect: () => [
          isA<BalanceLoading>(),
          isA<BalanceLoaded>().having(
            (s) => s.balances,
            'balances',
            allBalances,
          ),
        ],
        verify: (_) {
          verify(() => repository.getAllBalances()).called(1);
        },
      );

      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceError] when repository throws',
        setUp: () {
          when(
            () => repository.getAllBalances(),
          ).thenThrow(Exception('failed'));
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(LoadAllBalances()),
        expect: () => [
          isA<BalanceLoading>(),
          isA<BalanceError>().having(
            (s) => s.message,
            'message',
            contains('failed'),
          ),
        ],
      );
    });

    group('LoadBalancesForUser', () {
      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceLoaded] with user balances',
        setUp: () {
          when(
            () => repository.getBalancesForUser('user1'),
          ).thenAnswer((_) async => [balance1]);
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(LoadBalancesForUser('user1')),
        expect: () => [
          isA<BalanceLoading>(),
          isA<BalanceLoaded>().having((s) => s.balances, 'balances', [
            balance1,
          ]),
        ],
        verify: (_) {
          verify(() => repository.getBalancesForUser('user1')).called(1);
        },
      );

      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceError] when repository throws',
        setUp: () {
          when(
            () => repository.getBalancesForUser(any()),
          ).thenThrow(Exception('failed'));
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(LoadBalancesForUser('user1')),
        expect: () => [isA<BalanceLoading>(), isA<BalanceError>()],
      );
    });

    group('LoadPositiveBalances', () {
      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceLoaded] with positive balances',
        setUp: () {
          when(
            () => repository.getPositiveBalances(),
          ).thenAnswer((_) async => [balance1]);
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(LoadPositiveBalances()),
        expect: () => [
          isA<BalanceLoading>(),
          isA<BalanceLoaded>().having((s) => s.balances, 'balances', [
            balance1,
          ]),
        ],
        verify: (_) {
          verify(() => repository.getPositiveBalances()).called(1);
        },
      );

      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceError] when repository throws',
        setUp: () {
          when(
            () => repository.getPositiveBalances(),
          ).thenThrow(Exception('failed'));
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(LoadPositiveBalances()),
        expect: () => [isA<BalanceLoading>(), isA<BalanceError>()],
      );
    });

    group('LoadNegativeBalances', () {
      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceLoaded] with negative balances',
        setUp: () {
          when(
            () => repository.getNegativeBalances(),
          ).thenAnswer((_) async => [balance2]);
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(LoadNegativeBalances()),
        expect: () => [
          isA<BalanceLoading>(),
          isA<BalanceLoaded>().having((s) => s.balances, 'balances', [
            balance2,
          ]),
        ],
        verify: (_) {
          verify(() => repository.getNegativeBalances()).called(1);
        },
      );

      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceError] when repository throws',
        setUp: () {
          when(
            () => repository.getNegativeBalances(),
          ).thenThrow(Exception('failed'));
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(LoadNegativeBalances()),
        expect: () => [isA<BalanceLoading>(), isA<BalanceError>()],
      );
    });

    group('UpsertBalance', () {
      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceLoaded] after upsert and reload',
        setUp: () {
          when(
            () => repository.upsertBalance(
              userPublicKey: any(named: 'userPublicKey'),
              netAmount: any(named: 'netAmount'),
              currency: any(named: 'currency'),
              signed: any(named: 'signed'),
            ),
          ).thenAnswer((_) async {});
          when(
            () => repository.getAllBalances(),
          ).thenAnswer((_) async => allBalances);
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(
          UpsertBalance(
            userPublicKey: 'user1',
            netAmount: 100,
            currency: 'USD',
            signed: 'sig1',
          ),
        ),
        expect: () => [
          isA<BalanceLoading>(),
          isA<BalanceLoaded>().having(
            (s) => s.balances,
            'balances',
            allBalances,
          ),
        ],
        verify: (_) {
          verify(
            () => repository.upsertBalance(
              userPublicKey: 'user1',
              netAmount: 100,
              currency: 'USD',
              signed: 'sig1',
            ),
          ).called(1);
          verify(() => repository.getAllBalances()).called(1);
        },
      );

      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceError] when upsert throws',
        setUp: () {
          when(
            () => repository.upsertBalance(
              userPublicKey: any(named: 'userPublicKey'),
              netAmount: any(named: 'netAmount'),
              currency: any(named: 'currency'),
              signed: any(named: 'signed'),
            ),
          ).thenThrow(Exception('upsert failed'));
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(
          UpsertBalance(
            userPublicKey: 'user1',
            netAmount: 100,
            currency: 'USD',
          ),
        ),
        expect: () => [isA<BalanceLoading>(), isA<BalanceError>()],
        verify: (_) {
          verifyNever(() => repository.getAllBalances());
        },
      );
    });

    group('DeleteBalance', () {
      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceLoaded] after delete and reload',
        setUp: () {
          when(
            () => repository.deleteByPublicKey(any()),
          ).thenAnswer((_) async => 1);
          when(
            () => repository.getAllBalances(),
          ).thenAnswer((_) async => [balance2]);
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(DeleteBalance('user1')),
        expect: () => [
          isA<BalanceLoading>(),
          isA<BalanceLoaded>().having((s) => s.balances, 'balances', [
            balance2,
          ]),
        ],
        verify: (_) {
          verify(() => repository.deleteByPublicKey('user1')).called(1);
          verify(() => repository.getAllBalances()).called(1);
        },
      );

      blocTest<BalanceBloc, BalanceState>(
        'emits [BalanceLoading, BalanceError] when delete throws',
        setUp: () {
          when(
            () => repository.deleteByPublicKey(any()),
          ).thenThrow(Exception('delete failed'));
        },
        build: () => BalanceBloc(balanceRepository: repository),
        act: (bloc) => bloc.add(DeleteBalance('user1')),
        expect: () => [isA<BalanceLoading>(), isA<BalanceError>()],
        verify: (_) {
          verifyNever(() => repository.getAllBalances());
        },
      );
    });
  });
}
