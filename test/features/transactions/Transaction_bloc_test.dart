import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zplit/core/database/tables/transactions_table.dart';
import 'package:zplit/features/transaction/domain/models/transaction_model.dart';
import 'package:zplit/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:zplit/features/transaction/presentation/transaction_bloc.dart';
import 'package:zplit/features/transaction/presentation/transaction_event.dart';
import 'package:zplit/features/transaction/presentation/transaction_state.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepo;
  late TransactionBloc transactionBloc;

  final tTransaction1 = TransactionModel(
    id: 'tx_001',
    fromUserPublicKey: 'pk_alice',
    toUserPublicKey: 'pk_bob',
    amount: BigInt.from(1000),
    currency: 'USD',
    status: TransactionStatus.unsigned,
    description: 'Dinner split',
    tag: 'food',
    createdAt: DateTime(2025, 1, 1),
    senderSignature: null,
    receiverSignature: null,
  );

  final tTransaction2 = TransactionModel(
    id: 'tx_002',
    fromUserPublicKey: 'pk_bob',
    toUserPublicKey: 'pk_alice',
    amount: BigInt.from(500),
    currency: 'INR',
    status: TransactionStatus.signed,
    description: 'Cab fare',
    tag: 'travel',
    createdAt: DateTime(2025, 1, 2),
    senderSignature: 'sig_bob',
    receiverSignature: 'sig_alice',
  );

  final tTransactions = [tTransaction1, tTransaction2];

  setUp(() {
    mockRepo = MockTransactionRepository();
    transactionBloc = TransactionBloc(transactionRepository: mockRepo);
  });

  tearDown(() {
    transactionBloc.close();
  });

  test('initial state is TransactionInitial', () {
    expect(transactionBloc.state, isA<TransactionInitial>());
  });

  group('LoadAllTransactions', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] when getAllTransactions succeeds',
      build: () {
        when(
          () => mockRepo.getAllTransactions(),
        ).thenAnswer((_) async => tTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(LoadAllTransactions()),
      expect: () => [isA<TransactionLoading>(), isA<TransactionLoaded>()],
      verify: (_) {
        verify(() => mockRepo.getAllTransactions()).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] with correct list',
      build: () {
        when(
          () => mockRepo.getAllTransactions(),
        ).thenAnswer((_) async => tTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(LoadAllTransactions()),
      expect: () => [
        isA<TransactionLoading>(),
        predicate<TransactionState>(
          (s) => s is TransactionLoaded && s.transactions.length == 2,
          'TransactionLoaded with 2 transactions',
        ),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] with empty list',
      build: () {
        when(() => mockRepo.getAllTransactions()).thenAnswer((_) async => []);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(LoadAllTransactions()),
      expect: () => [
        isA<TransactionLoading>(),
        predicate<TransactionState>(
          (s) => s is TransactionLoaded && s.transactions.isEmpty,
          'TransactionLoaded with empty list',
        ),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionError] when getAllTransactions throws',
      build: () {
        when(
          () => mockRepo.getAllTransactions(),
        ).thenThrow(Exception('DB error'));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(LoadAllTransactions()),
      expect: () => [isA<TransactionLoading>(), isA<TransactionError>()],
    );
  });

  group('GetTransactionById', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] with single tx when found',
      build: () {
        when(
          () => mockRepo.getTransactionById('tx_001'),
        ).thenAnswer((_) async => tTransaction1);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(GetTransactionById('tx_001')),
      expect: () => [
        isA<TransactionLoading>(),
        predicate<TransactionState>(
          (s) =>
              s is TransactionLoaded &&
              s.transactions.length == 1 &&
              s.transactions.first.id == 'tx_001',
          'TransactionLoaded with tTransaction1',
        ),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] with empty list when not found',
      build: () {
        when(
          () => mockRepo.getTransactionById('unknown'),
        ).thenAnswer((_) async => null);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(GetTransactionById('unknown')),
      expect: () => [
        isA<TransactionLoading>(),
        predicate<TransactionState>(
          (s) => s is TransactionLoaded && s.transactions.isEmpty,
          'TransactionLoaded with empty list',
        ),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionError] when getTransactionById throws',
      build: () {
        when(
          () => mockRepo.getTransactionById(any()),
        ).thenThrow(Exception('Not found'));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(GetTransactionById('tx_001')),
      expect: () => [isA<TransactionLoading>(), isA<TransactionError>()],
    );
  });

  group('CreateTransaction', () {
    final tCreateEvent = CreateTransaction(
      fromUserPublicKey: 'pk_alice',
      toUserPublicKey: 'pk_bob',
      amount: BigInt.from(1000),
      currency: 'USD',
      description: 'Dinner split',
      tag: 'food',
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] after successful create',
      build: () {
        when(
          () => mockRepo.createTransaction(
            fromUserPublicKey: any(named: 'fromUserPublicKey'),
            toUserPublicKey: any(named: 'toUserPublicKey'),
            amount: any(named: 'amount'),
            currency: any(named: 'currency'),
            description: any(named: 'description'),
            tag: any(named: 'tag'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockRepo.getAllTransactions(),
        ).thenAnswer((_) async => tTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(tCreateEvent),
      expect: () => [isA<TransactionLoading>(), isA<TransactionLoaded>()],
      verify: (_) {
        verify(
          () => mockRepo.createTransaction(
            fromUserPublicKey: 'pk_alice',
            toUserPublicKey: 'pk_bob',
            amount: BigInt.from(1000),
            currency: 'USD',
            description: 'Dinner split',
            tag: 'food',
          ),
        ).called(1);
        verify(() => mockRepo.getAllTransactions()).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionError] when createTransaction throws',
      build: () {
        when(
          () => mockRepo.createTransaction(
            fromUserPublicKey: any(named: 'fromUserPublicKey'),
            toUserPublicKey: any(named: 'toUserPublicKey'),
            amount: any(named: 'amount'),
            currency: any(named: 'currency'),
            description: any(named: 'description'),
            tag: any(named: 'tag'),
          ),
        ).thenThrow(Exception('Create failed'));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(tCreateEvent),
      expect: () => [isA<TransactionLoading>(), isA<TransactionError>()],
    );
  });

  group('SignAsSender', () {
    final tSignEvent = SignAsSender(
      transactionId: 'tx_001',
      senderSignature: 'sig_alice',
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] after successful sign',
      build: () {
        when(
          () => mockRepo.signAsSender(
            transactionId: any(named: 'transactionId'),
            senderSignature: any(named: 'senderSignature'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockRepo.getAllTransactions(),
        ).thenAnswer((_) async => tTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(tSignEvent),
      expect: () => [isA<TransactionLoading>(), isA<TransactionLoaded>()],
      verify: (_) {
        verify(
          () => mockRepo.signAsSender(
            transactionId: 'tx_001',
            senderSignature: 'sig_alice',
          ),
        ).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionError] when signAsSender throws',
      build: () {
        when(
          () => mockRepo.signAsSender(
            transactionId: any(named: 'transactionId'),
            senderSignature: any(named: 'senderSignature'),
          ),
        ).thenThrow(Exception('Transaction not found'));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(tSignEvent),
      expect: () => [isA<TransactionLoading>(), isA<TransactionError>()],
    );
  });

  group('AcceptTransaction', () {
    final tAcceptEvent = AcceptTransaction(
      transactionId: 'tx_001',
      receiverSignature: 'sig_bob',
      signedBalancePayload: 'payload_signed',
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] after successful accept',
      build: () {
        when(
          () => mockRepo.acceptTransaction(
            transactionId: any(named: 'transactionId'),
            receiverSignature: any(named: 'receiverSignature'),
            signedBalancePayload: any(named: 'signedBalancePayload'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockRepo.getAllTransactions(),
        ).thenAnswer((_) async => tTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(tAcceptEvent),
      expect: () => [isA<TransactionLoading>(), isA<TransactionLoaded>()],
      verify: (_) {
        verify(
          () => mockRepo.acceptTransaction(
            transactionId: 'tx_001',
            receiverSignature: 'sig_bob',
            signedBalancePayload: 'payload_signed',
          ),
        ).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionError] when acceptTransaction throws',
      build: () {
        when(
          () => mockRepo.acceptTransaction(
            transactionId: any(named: 'transactionId'),
            receiverSignature: any(named: 'receiverSignature'),
            signedBalancePayload: any(named: 'signedBalancePayload'),
          ),
        ).thenThrow(Exception('Transaction not found'));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(tAcceptEvent),
      expect: () => [isA<TransactionLoading>(), isA<TransactionError>()],
    );
  });

  group('RejectTransaction', () {
    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] after successful reject',
      build: () {
        when(() => mockRepo.rejectTransaction(any())).thenAnswer((_) async {});
        when(
          () => mockRepo.getAllTransactions(),
        ).thenAnswer((_) async => tTransactions);
        return transactionBloc;
      },
      act: (bloc) => bloc.add(RejectTransaction('tx_001')),
      expect: () => [isA<TransactionLoading>(), isA<TransactionLoaded>()],
      verify: (_) {
        verify(() => mockRepo.rejectTransaction('tx_001')).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionError] when rejectTransaction throws',
      build: () {
        when(
          () => mockRepo.rejectTransaction(any()),
        ).thenThrow(Exception('Reject failed'));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(RejectTransaction('tx_001')),
      expect: () => [isA<TransactionLoading>(), isA<TransactionError>()],
    );
  });
}
