import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
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
    on<BluetoothInviteReceived>(_onBluetoothInviteReceived);
    on<BluetoothAckReceived>(_onBluetoothAckReceived);
    on<BluetoothTransactionReceived>(_onBluetoothTransactionReceived); // NEW
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

  Future<void> _onBluetoothInviteReceived(
    BluetoothInviteReceived event,
    Emitter<DeepLinkState> emit,
  ) async {
    emit(DeepLinkLoading());
    try {
      final json = jsonDecode(event.jsonPayload) as Map<String, dynamic>;
      await _upsertFromInviteJson(json, emit);
    } catch (e) {
      emit(DeepLinkError(e.toString()));
    }
  }

  Future<void> _onBluetoothAckReceived(
    BluetoothAckReceived event,
    Emitter<DeepLinkState> emit,
  ) async {
    try {
      final json = jsonDecode(event.jsonPayload) as Map<String, dynamic>;
      final txnId = json['id'] as String? ?? '';
      final outcome = json['outcome'] as String? ?? '';

      if (txnId.isEmpty || outcome.isEmpty) {
        emit(DeepLinkError('Invalid ack payload'));
        return;
      }

      await _transactionRepository.applyRemoteAck(
        transactionId: txnId,
        outcome: outcome,
      );

      emit(TransactionAckReceived(txnId: txnId, outcome: outcome));
    } catch (e) {
      emit(DeepLinkError(e.toString()));
    }
  }

  Future<void> _onBluetoothTransactionReceived(
    BluetoothTransactionReceived event,
    Emitter<DeepLinkState> emit,
  ) async {
    emit(DeepLinkLoading());
    try {
      final encoded = base64Url.encode(utf8.encode(event.jsonPayload));
      final fakeUri = Uri.parse('zplit://tx?d=$encoded');
      await _handleTransaction(fakeUri, emit);
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

    await _upsertFromInviteJson(json, emit);
  }

  Future<String?> _savePictureIfPresent(
    String? picBase64,
    String forPublicKey,
  ) async {
    if (picBase64 == null || picBase64.isEmpty) return null;

    try {
      final bytes = base64Decode(picBase64);
      final dir = await getApplicationDocumentsDirectory();
      final safeKey = forPublicKey.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final file = File('${dir.path}/profile_$safeKey.jpg');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      print('Failed to save synced profile picture: $e');
      return null;
    }
  }

  Future<void> _upsertFromInviteJson(
    Map<String, dynamic> json,
    Emitter<DeepLinkState> emit,
  ) async {
    if (json.containsKey('sig')) {
      emit(
        DeepLinkError(
          'Received a transaction-shaped payload on the invite path — ignored',
        ),
      );
      return;
    }

    final id = json['id'] as String? ?? '';
    final name = json['name'] as String? ?? id;
    final addr = json['addr'] as String? ?? '';
    final picBase64 = json['pic'] as String?;

    if (id.isEmpty) {
      emit(DeepLinkError('Invalid invite: missing id'));
      return;
    }

    final me = await _userRepository.getCurrentUser();
    if (me != null && me.publicKey.toLowerCase() == id.toLowerCase()) {
      emit(DeepLinkInitial());
      return;
    }

    final savedPicturePath = await _savePictureIfPresent(picBase64, id);

    await _userRepository.upsertUser(
      publicKey: id,
      displayName: name,
      cryptoAddress: addr,
      profilePicture: savedPicturePath,
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
      emit(DeepLinkError(' Transaction signature invalid — rejected'));
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
