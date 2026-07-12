import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/domain/repositories/transaction/transaction_repository.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;
  final BalanceBloc _balanceBloc;

  TransactionBloc({
    required TransactionRepository transactionRepository,
    required BalanceBloc balanceBloc,
  }) : _transactionRepository = transactionRepository,
       _balanceBloc = balanceBloc,
       super(TransactionInitial()) {
    on<LoadAllTransactions>(_onLoadAllTransactions);
    on<GetTransactionById>(_onGetTransactionById);
    on<CreateTransaction>(_onCreateTransaction);
    on<ReceiveIncomingTransaction>(_onReceiveIncoming);
    on<SignAsSender>(_onSignAsSender);
    on<AcceptTransaction>(_onAcceptTransaction);
    on<RejectTransaction>(_onRejectTransaction);
  }

  Future<void> _onLoadAllTransactions(
    LoadAllTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onGetTransactionById(
    GetTransactionById event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final tx = await _transactionRepository.getTransactionById(event.id);
      emit(TransactionLoaded(tx == null ? [] : [tx]));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.createTransaction(
        fromUserPublicKey: event.fromUserPublicKey,
        toUserPublicKey: event.toUserPublicKey,
        amount: event.amount,
        currency: event.currency,
        description: event.description,
        tag: event.tag,
      );
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onReceiveIncoming(
    ReceiveIncomingTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.receiveIncoming(
        id: event.id,
        fromUserPublicKey: event.fromUserPublicKey,
        toUserPublicKey: event.toUserPublicKey,
        amount: event.amount,
        currency: event.currency,
        description: event.description,
        tag: event.tag,
      );
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onSignAsSender(
    SignAsSender event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.signAsSender(
        transactionId: event.transactionId,
        senderSignature: event.senderSignature,
      );
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAcceptTransaction(
    AcceptTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.acceptTransaction(
        transactionId: event.transactionId,
      );

      _balanceBloc.add(LoadAllBalances());
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onRejectTransaction(
    RejectTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.rejectTransaction(event.transactionId);
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
