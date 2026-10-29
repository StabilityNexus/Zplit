import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/core/services/settlement_config.dart';
import 'package:zplit/core/services/settlement_service.dart';

import 'package:zplit/ui/settlement/view_model/settlement_event.dart';
import 'package:zplit/ui/settlement/view_model/settlement_state.dart';
import 'package:zplit/ui/settlement/widgets/settlement_tracker.dart';

class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  // Remembered from SettleRequested for the automatic lookup.
  String _friendAddress = '';
  String _friendKey = '';
  double _balanceInInr = 0;

  /// Optional. When set, only payments FROM this address count.
  String _payerAddress = '';

  /// Block number when the user tapped Settle. Only payments after this
  /// count. Null if the node could not be reached (paste-a-hash still works).
  int? _startBlock;

  /// How long to keep looking after the user returns from the wallet.
  static const int _lookupAttempts = 6;
  static const Duration _lookupGap = Duration(seconds: 10);

  bool get _canAutoDetect => _startBlock != null;

  SettlementBloc() : super(const SettlementInitial()) {
    on<SettleRequested>(_onSettleRequested);
    on<SettlementReturned>(_onReturned);
    on<SettlementCheckAgainRequested>(_onCheckAgain);
    on<SettlementVerifyRequested>(_onVerifyRequested);
    on<SettlementPaidClaimed>(
      (_, emit) => emit(const SettlementSelfReported()),
    );
    on<SettlementReset>((_, emit) async {
      await SettlementTracker.clearSession(_friendKey);
      emit(const SettlementInitial());
    });
  }

  Future<void> _onSettleRequested(
    SettleRequested event,
    Emitter<SettlementState> emit,
  ) async {
    if (state is SettlementLaunching) return;

    if (!SettlementService.isValidAddress(event.friendWalletAddress)) {
      emit(
        const SettlementError(
          'The recipient wallet address is not valid. Ask them to re-share it.',
        ),
      );
      return;
    }

    final payer = event.payerAddress.trim();
    if (payer.isNotEmpty && !SettlementService.isValidAddress(payer)) {
      emit(
        const SettlementError(
          'Your wallet address is not valid (0x + 40 characters).',
        ),
      );
      return;
    }

    final raw = SettlementService.usdcRawFromInr(event.balanceInInr);
    if (raw <= BigInt.zero) {
      emit(const SettlementError('Amount is too small to settle.'));
      return;
    }

    _friendAddress = event.friendWalletAddress;
    _friendKey = event.friendPublicKey;
    _balanceInInr = event.balanceInInr;
    _payerAddress = payer;
    _startBlock = null;

    emit(const SettlementLaunching());

    // If we know who is paying, warn BEFORE opening the wallet when they do
    // not hold enough USDC. Otherwise MetaMask shows "likely to fail".
    // A failed lookup (null) is ignored: the wallet will still warn.
    if (payer.isNotEmpty) {
      final bal = await SettlementService.usdcBalanceOf(
        payer,
      ).timeout(const Duration(seconds: 6), onTimeout: () => null);
      if (bal != null && bal < raw) {
        emit(
          SettlementError(
            'That wallet holds ${SettlementService.formatUsdc(bal)} USDC on '
            '${SettlementConfig.active.name}, but '
            '${SettlementService.formatUsdc(raw)} USDC is needed. Add USDC '
            'on this network and try again.',
          ),
        );
        return;
      }
    }

    // Note where the chain is NOW, so only payments made after this count.
    // If this fails we still continue: the user can paste the hash instead.
    try {
      _startBlock = await SettlementService.currentBlock().timeout(
        const Duration(seconds: 6),
      );
    } catch (_) {
      _startBlock = null;
    }

    // Save a session BEFORE leaving the app: if Android kills Zplit while
    // the wallet is open, SettlementTracker.resumeSessions() still finds
    // the payment the next time the app starts.
    if (_startBlock != null && event.friendPublicKey.isNotEmpty) {
      await SettlementTracker.saveSession(
        SettlementSession(
          friendPublicKey: event.friendPublicKey,
          friendName: event.friendName,
          friendAddress: event.friendWalletAddress,
          amountPaise: (event.balanceInInr.abs() * 100).round(),
          minRawAmount: raw.toString(),
          payerAddress: payer,
          startBlock: _startBlock!,
          chainId: SettlementConfig.active.chainId,
          createdAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    final launched = await SettlementService.launchWalletTransfer(
      recipientAddress: event.friendWalletAddress,
      rawAmount: raw,
      metaMask: event.useMetaMask,
    );
    emit(
      launched
          ? const SettlementAwaitingReturn()
          : const SettlementNoWalletFound(),
    );
  }

  Future<void> _onReturned(
    SettlementReturned event,
    Emitter<SettlementState> emit,
  ) async {
    // Only meaningful if we actually sent the user to a wallet.
    if (state is! SettlementAwaitingReturn) return;
    if (_canAutoDetect) {
      await _autoCheck(emit);
    } else {
      emit(const SettlementConfirming());
    }
  }

  Future<void> _onCheckAgain(
    SettlementCheckAgainRequested event,
    Emitter<SettlementState> emit,
  ) async {
    if (state is! SettlementConfirming) return;
    if (!_canAutoDetect) {
      emit(
        const SettlementConfirming(
          notice:
              'Automatic detection is not available right now. Paste the '
              'transaction hash from your wallet instead.',
        ),
      );
      return;
    }
    await _autoCheck(emit);
  }

  /// Looks for the payment on-chain, retrying for about a minute because a
  /// transaction is usually not mined yet when the user first comes back.
  ///
  /// Found -> SettlementVerified (the same state the paste flow produces, so
  /// the caller needs no changes). Otherwise back to the paste-a-hash form
  /// with a message.
  Future<void> _autoCheck(Emitter<SettlementState> emit) async {
    final minRaw = SettlementService.usdcRawFromInr(_balanceInInr);
    PayerLookup? result;

    for (var i = 0; i < _lookupAttempts; i++) {
      emit(const SettlementVerifying());

      result = await SettlementService.findPayment(
        recipientAddress: _friendAddress,
        minRawAmount: minRaw,
        fromBlock: _startBlock!,
        payerAddress: _payerAddress,
      );

      // Stop on anything other than "not there yet".
      if (result.status != TransferCheckStatus.notFound) break;

      if (i < _lookupAttempts - 1) {
        await Future.delayed(_lookupGap);
        // The user may have pressed Reset or left the screen meanwhile.
        if (emit.isDone || state is! SettlementVerifying) return;
      }
    }

    final r = result!;
    if (r.status == TransferCheckStatus.verified) {
      for (final m in r.matches) {
        // One payment can only settle one balance.
        if (!await SettlementTracker.isHashUsed(m.txHash)) {
          await SettlementTracker.markHashUsed(m.txHash);
          await SettlementTracker.clearSession(_friendKey);
          emit(SettlementVerified(m.txHash, r.message));
          return;
        }
      }
      emit(
        const SettlementConfirming(
          notice: 'That payment was already used for another settlement.',
        ),
      );
      return;
    }

    emit(SettlementConfirming(notice: r.message));
  }

  Future<void> _onVerifyRequested(
    SettlementVerifyRequested event,
    Emitter<SettlementState> emit,
  ) async {
    if (state is SettlementVerifying) return;
    emit(const SettlementVerifying());

    final hash = event.txHash.trim();

    // A hash can only ever settle ONE balance.
    if (SettlementService.isValidTxHash(hash) &&
        await SettlementTracker.isHashUsed(hash)) {
      emit(
        const SettlementConfirming(
          notice: 'That transaction was already used for another settlement.',
        ),
      );
      return;
    }

    final check = await SettlementService.verifyTransfer(
      txHash: hash,
      recipientAddress: event.friendWalletAddress,
      minRawAmount: SettlementService.usdcRawFromInr(event.balanceInInr),
    );

    switch (check.status) {
      case TransferCheckStatus.verified:
        await SettlementTracker.markHashUsed(hash);
        await SettlementTracker.clearSession(_friendKey);
        emit(SettlementVerified(hash, check.message));
      case TransferCheckStatus.notFound:
      case TransferCheckStatus.networkError:
        // Well-formed hash we can't confirm right now: keep it and re-check
        // when the app is next opened.
        emit(SettlementPending(hash, check.message));
      case TransferCheckStatus.mismatch:
      case TransferCheckStatus.failed:
        emit(SettlementConfirming(notice: check.message));
    }
  }
}
