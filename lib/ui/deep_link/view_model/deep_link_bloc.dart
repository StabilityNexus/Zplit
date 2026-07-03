import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zplit/core/services/deep_link_service.dart';
import 'package:zplit/domain/repositories/transaction/transaction_repository.dart';
import 'package:zplit/domain/repositories/user/user_repository.dart';

part 'deep_link_event.dart';
part 'deep_link_state.dart';

const _storage = FlutterSecureStorage();
const _addressStorageKey = 'evm_address';

class DeepLinkBloc extends Bloc<DeepLinkEvent, DeepLinkState> {
  final UserRepository _userRepository;
  final TransactionRepository _transactionRepository;

  DeepLinkBloc({
    required UserRepository userRepository,
    required TransactionRepository transactionRepository,
  }) : _userRepository = userRepository,
       _transactionRepository = transactionRepository,
       super(DeepLinkInitial()) {
    on<DeepLinkReceived>(_onDeepLinkReceived);
  }

  Future<void> _onDeepLinkReceived(
    DeepLinkReceived event,
    Emitter<DeepLinkState> emit,
  ) async {
    emit(DeepLinkLoading());
    try {
      final uri = event.uri;

      if (uri.host == 'invite') {
        await _handleInvite(uri, emit);
      } else if (uri.host == 'tx') {
        await _handleTransaction(uri, emit);
      } else {
        emit(DeepLinkError('Unknown route: ${uri.host}'));
      }
    } catch (e) {
      emit(DeepLinkError(e.toString()));
    }
  }

  Future<void> _handleInvite(Uri uri, Emitter<DeepLinkState> emit) async {
    final encoded = uri.queryParameters['d'];
    if (encoded == null) {
      emit(DeepLinkError('Missing payload'));
      return;
    }

    final json =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(encoded))))
            as Map<String, dynamic>;

    final id = json['id'] as String? ?? '';
    final name = json['name'] as String? ?? id;
    final addr = json['addr'] as String? ?? '';

    if (id.isEmpty) {
      emit(DeepLinkError('Invalid invite: missing id'));
      return;
    }

    final me = await _userRepository.getCurrentUser();
    if (me != null && me.publicKey.toLowerCase() == id.toLowerCase()) {
      emit(DeepLinkInitial());
      return;
    }

    await _userRepository.upsertUser(
      publicKey: id,
      displayName: name,
      cryptoAddress: addr,
      defaultCurrency: 'INR',
    );

    emit(InviteHandled(name));
  }

  Future<void> _handleTransaction(Uri uri, Emitter<DeepLinkState> emit) async {
    final tx = DeepLinkService.parseAndVerify(uri);

    if (tx == null) {
      emit(DeepLinkError('Invalid or unreadable transaction payload'));
      return;
    }

    if (!tx.isVerified) {
      emit(DeepLinkError('Transaction signature invalid — rejected'));
      return;
    }

    if (tx.fromPublicKey.isEmpty) {
      emit(DeepLinkError('Invalid transaction: missing sender'));
      return;
    }

    final sender = await _userRepository.getUserByPublicKey(tx.fromPublicKey);
    if (sender == null) {
      emit(DeepLinkUnknownSender(tx.fromPublicKey));
      return;
    }

    final me = await _userRepository.getCurrentUser();
    if (me == null) {
      emit(DeepLinkError('No local user found'));
      return;
    }

    await _transactionRepository.receiveIncoming(
      id: tx.id,
      fromUserPublicKey: tx.fromPublicKey,
      toUserPublicKey: me.publicKey,
      amount: BigInt.from((tx.amount * 100).round()),
      currency: 'INR',
      description: tx.description,
      tag: tx.tag,
    );

    emit(
      TransactionReceived(
        txnId: tx.id,
        fromUserId: tx.fromPublicKey,
        fromUserName: sender.displayName,
        amount: tx.amount,
        desc: tx.description,
        tag: tx.tag,
      ),
    );
  }
}
