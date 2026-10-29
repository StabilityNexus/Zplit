import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zplit/core/services/settlement_config.dart';
import 'package:zplit/core/services/settlement_service.dart';

import 'package:zplit/ui/settlement/view_model/settlement_bloc.dart';
import 'package:zplit/ui/settlement/view_model/settlement_event.dart';
import 'package:zplit/ui/settlement/view_model/settlement_state.dart';
import 'package:zplit/ui/settlement/widgets/settlement_tracker.dart';

const _friend = '0x2222222222222222222222222222222222222222';
final _goodHash = '0x${'ab' * 32}';

void main() {
  // The bloc's reset path clears the saved settlement session, which writes
  // to flutter_secure_storage. That needs Flutter's test binding and an
  // in-memory secure storage (there is no real keystore under `flutter test`).
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  // These expectations assume the fixed rate in SettlementConfig.
  test('config rate is 83 INR per USD (tests below depend on it)', () {
    expect(SettlementConfig.inrPerUsd, 83.0);
    expect(SettlementConfig.usdcDecimals, 6);
  });

  group('usdcRawFromInr', () {
    test('₹83 is exactly 1 USDC', () {
      expect(SettlementService.usdcRawFromInr(83), BigInt.from(1000000));
    });

    test('zero stays zero', () {
      expect(SettlementService.usdcRawFromInr(0), BigInt.zero);
    });

    test('rounds UP so the recipient is never short-changed', () {
      // ₹1 = 1/83 USDC = 12048.19... raw units -> 12049
      expect(SettlementService.usdcRawFromInr(1), BigInt.from(12049));
    });

    test('negative input uses the absolute value', () {
      expect(SettlementService.usdcRawFromInr(-83), BigInt.from(1000000));
    });

    test('₹166 is exactly 2 USDC', () {
      expect(SettlementService.usdcRawFromInr(166), BigInt.from(2000000));
    });
  });

  group('formatUsdc', () {
    test('whole amount', () {
      expect(SettlementService.formatUsdc(BigInt.from(1000000)), '1.00');
    });

    test('zero', () {
      expect(SettlementService.formatUsdc(BigInt.zero), '0.00');
    });

    test('smallest unit rounds up to one cent', () {
      expect(SettlementService.formatUsdc(BigInt.one), '0.01');
    });

    test('rounds up to the next cent', () {
      expect(SettlementService.formatUsdc(BigInt.from(6024098)), '6.03');
    });
  });

  group('validation', () {
    test('valid and invalid addresses', () {
      expect(SettlementService.isValidAddress(_friend), isTrue);
      expect(SettlementService.isValidAddress('0x123'), isFalse);
      expect(SettlementService.isValidAddress(_friend.substring(2)), isFalse);
      expect(SettlementService.isValidAddress('${_friend}00'), isFalse);
      expect(SettlementService.isValidAddress(''), isFalse);
    });

    test('valid and invalid tx hashes', () {
      expect(SettlementService.isValidTxHash(_goodHash), isTrue);
      expect(SettlementService.isValidTxHash(' $_goodHash '), isTrue);
      expect(SettlementService.isValidTxHash('0xabc'), isFalse);
      expect(SettlementService.isValidTxHash(_friend), isFalse);
      expect(SettlementService.isValidTxHash(''), isFalse);
    });
  });

  group('buildTransferUri', () {
    test('is an EIP-681 USDC transfer on the active network', () {
      final uri = SettlementService.buildTransferUri(
        recipientAddress: _friend,
        rawAmount: BigInt.from(1000000),
      );
      final s = uri.toString();
      final net = SettlementConfig.active;

      expect(uri.scheme, 'ethereum');
      expect(s, contains(net.usdcAddress));
      expect(s, contains('@${net.chainId}'));
      expect(s, contains('/transfer'));
      expect(s, contains('address=$_friend'));
      expect(s, contains('uint256=1000000'));
    });
  });

  group('SettlementConfig network', () {
    test('active network has everything the verifier and UI need', () {
      final net = SettlementConfig.active;
      expect(net.rpcUrl, startsWith('https://'));
      expect(net.usdcAddress, matches(RegExp(r'^0x[0-9a-fA-F]{40}$')));
      expect(net.txUrl('0xabc'), '${net.explorerUrl}/tx/0xabc');
    });

    test('defaults to a testnet', () {
      expect(SettlementConfig.active.isTestnet, isTrue);
    });
  });

  group('PendingSettlement', () {
    test('survives a JSON round trip', () {
      final original = PendingSettlement(
        id: '1',
        friendPublicKey: '0xfriend',
        friendName: 'Test Friend',
        friendWalletAddress: _friend,
        amountPaise: 8300,
        minRawAmount: '1000000',
        txHash: _goodHash,
        createdAtMs: 1700000000000,
        status: PendingSettlementStatus.confirmed,
        notice: 'ok',
      );

      final copy = PendingSettlement.fromJson(original.toJson());

      expect(copy.id, '1');
      expect(copy.friendName, 'Test Friend');
      expect(copy.amountPaise, 8300);
      expect(copy.minRawAmount, '1000000');
      expect(copy.txHash, _goodHash);
      expect(copy.status, PendingSettlementStatus.confirmed);
      expect(copy.notice, 'ok');
    });

    test('unknown status falls back to checking', () {
      final json = PendingSettlement(
        id: '1',
        friendPublicKey: 'k',
        friendName: 'n',
        friendWalletAddress: _friend,
        amountPaise: 1,
        minRawAmount: '1',
        txHash: _goodHash,
        createdAtMs: 0,
      ).toJson()..['status'] = 'something_new';

      expect(
        PendingSettlement.fromJson(json).status,
        PendingSettlementStatus.checking,
      );
    });

    test('copyWith changes only status and notice', () {
      final p = PendingSettlement(
        id: '1',
        friendPublicKey: 'k',
        friendName: 'n',
        friendWalletAddress: _friend,
        amountPaise: 8300,
        minRawAmount: '1000000',
        txHash: _goodHash,
        createdAtMs: 5,
      );
      final q = p.copyWith(
        status: PendingSettlementStatus.failed,
        notice: 'nope',
      );
      expect(q.status, PendingSettlementStatus.failed);
      expect(q.notice, 'nope');
      expect(q.txHash, p.txHash);
      expect(q.amountPaise, p.amountPaise);
    });
  });

  group('SettlementResult', () {
    test('pending defaults to false', () {
      const r = SettlementResult(verified: false);
      expect(r.pending, isFalse);
      expect(r.txHash, isNull);
    });
  });

  group('SettlementBloc (no network)', () {
    test('invalid wallet address -> error', () async {
      final bloc = SettlementBloc();
      bloc.add(SettleRequested(friendWalletAddress: 'nope', balanceInInr: 83));
      await expectLater(bloc.stream, emits(isA<SettlementError>()));
      await bloc.close();
    });

    test('zero amount -> "too small" error', () async {
      final bloc = SettlementBloc();
      bloc.add(SettleRequested(friendWalletAddress: _friend, balanceInInr: 0));
      await expectLater(
        bloc.stream,
        emits(
          isA<SettlementError>().having(
            (e) => e.message,
            'message',
            contains('too small'),
          ),
        ),
      );
      await bloc.close();
    });

    test('"mark as paid" then reset', () async {
      final bloc = SettlementBloc();
      bloc.add(SettlementPaidClaimed());
      bloc.add(SettlementReset());
      await expectLater(
        bloc.stream,
        emitsInOrder([isA<SettlementSelfReported>(), isA<SettlementInitial>()]),
      );
      await bloc.close();
    });

    test('returning from the wallet only counts after launching it', () async {
      final bloc = SettlementBloc();
      bloc.add(SettlementReturned()); // state is Initial: must be ignored
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isA<SettlementInitial>());
      await bloc.close();
    });

    test(
      'malformed hash -> verifying, then back to confirming with notice',
      () async {
        final bloc = SettlementBloc();
        bloc.add(
          SettlementVerifyRequested(
            txHash: '0xnothex',
            friendWalletAddress: _friend,
            balanceInInr: 83,
          ),
        );
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SettlementVerifying>(),
            isA<SettlementConfirming>().having(
              (s) => s.notice,
              'notice',
              isNotNull,
            ),
          ]),
        );
        await bloc.close();
      },
    );
  });

  // ── Live Sepolia checks (skipped unless you pass the dart-defines) ─────
  const liveTx = String.fromEnvironment('SEPOLIA_TX');
  const liveTo = String.fromEnvironment('SEPOLIA_TO');
  final skipLive = (liveTx.isEmpty || liveTo.isEmpty)
      ? 'pass --dart-define=SEPOLIA_TX=0x… and --dart-define=SEPOLIA_TO=0x…'
      : false;

  group('verifyTransfer (live Sepolia)', () {
    test('real payment to the right address is verified', () async {
      final r = await SettlementService.verifyTransfer(
        txHash: liveTx,
        recipientAddress: liveTo,
        minRawAmount: BigInt.one,
      );
      expect(r.status, TransferCheckStatus.verified, reason: r.message);
    });

    test('same payment, wrong recipient -> mismatch', () async {
      final r = await SettlementService.verifyTransfer(
        txHash: liveTx,
        recipientAddress: '0x3333333333333333333333333333333333333333',
        minRawAmount: BigInt.one,
      );
      expect(r.status, TransferCheckStatus.mismatch, reason: r.message);
    });

    test('same payment, absurdly high minimum -> mismatch', () async {
      final r = await SettlementService.verifyTransfer(
        txHash: liveTx,
        recipientAddress: liveTo,
        minRawAmount: BigInt.from(10).pow(18),
      );
      expect(r.status, TransferCheckStatus.mismatch, reason: r.message);
    });
  }, skip: skipLive);
}
