import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    final encoded = uri.queryParameters['d'];
    if (encoded == null) {
      emit(DeepLinkError('Missing payload'));
      return;
    }

    final json =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(encoded))))
            as Map<String, dynamic>;

    final fromId = json['from'] as String? ?? '';
    if (fromId.isEmpty) {
      emit(DeepLinkError('Invalid transaction: missing sender'));
      return;
    }

    final sender = await _userRepository.getUserByPublicKey(fromId);
    if (sender == null) {
      emit(DeepLinkUnknownSender(fromId));
      return;
    }

    final me = await _userRepository.getCurrentUser();
    if (me == null) {
      emit(DeepLinkError('No local user found'));
      return;
    }

    final txnId = json['id'] as String? ?? '';
    final amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final desc = json['desc'] as String? ?? '';
    final tag = json['tag'] as String?;

    await _transactionRepository.receiveIncoming(
      id: txnId,
      fromUserPublicKey: fromId,
      toUserPublicKey: me.publicKey, // ✅ fixed
      amount: BigInt.from((amount * 100).round()),
      currency: 'INR',
      description: desc,
      tag: tag,
    );

    emit(
      TransactionReceived(
        txnId: txnId,
        fromUserId: fromId,
        fromUserName: sender.displayName,
        amount: amount,
        desc: desc,
        tag: tag,
      ),
    );
  }
}
