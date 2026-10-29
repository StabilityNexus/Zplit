import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/crypto.dart' show hexToBytes;
import 'package:web3dart/web3dart.dart'
    show Web3Client, FilterOptions, BlockNum, EthereumAddress;

import 'package:zplit/core/services/settlement_config.dart';

enum TransferCheckStatus {
  /// A USDC transfer to the right person for at least the right amount.
  verified,

  /// No receipt yet (not mined, or the hash is from another network).
  notFound,

  /// The transaction exists but does not match what Zplit expected.
  mismatch,

  /// The transaction was mined but reverted.
  failed,

  /// Could not reach the RPC node.
  networkError,
}

class TransferCheck {
  final TransferCheckStatus status;
  final String message;
  const TransferCheck(this.status, this.message);
}

/// One USDC transfer found by the payment lookup.
class FoundTransfer {
  final String txHash;
  final BigInt amount;

  /// Sender address (0x…), when it could be read from the log.
  final String? from;
  const FoundTransfer(this.txHash, this.amount, [this.from]);
}

/// Result of [SettlementService.findPayment].
class PayerLookup {
  final TransferCheckStatus status;
  final String message;
  final List<FoundTransfer> matches;
  const PayerLookup(this.status, this.message, [this.matches = const []]);
}

/// Plain `ethereum:` wallet link + on-chain checks through a public RPC node.
/// No SDKs, no accounts, no relay servers.
class SettlementService {
  SettlementService._();

  static final RegExp _addressRegex = RegExp(r'^0x[0-9a-fA-F]{40}$');
  static final RegExp _txHashRegex = RegExp(r'^0x[0-9a-fA-F]{64}$');

  /// keccak256("Transfer(address,address,uint256)")
  static const String _transferTopic =
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';

  static bool isValidAddress(String a) => _addressRegex.hasMatch(a.trim());
  static bool isValidTxHash(String h) => _txHashRegex.hasMatch(h.trim());

  // ── Amount maths (integer only — no floating point on money) ──────────

  /// INR as shown in the UI -> raw USDC units (6 decimals), rounded UP so the
  /// recipient is never short-changed by rounding.
  static BigInt usdcRawFromInr(double inr) {
    final paise = BigInt.from((inr.abs() * 100).round());
    final ratePaisePerUsd = BigInt.from(
      (SettlementConfig.inrPerUsd * 100).round(),
    );
    final scale = BigInt.from(10).pow(SettlementConfig.usdcDecimals);
    return (paise * scale + ratePaisePerUsd - BigInt.one) ~/ ratePaisePerUsd;
  }

  /// Raw USDC -> "12.34" (rounded up to the next cent).
  static String formatUsdc(BigInt raw) {
    final centUnit = BigInt.from(10).pow(SettlementConfig.usdcDecimals - 2);
    final cents = (raw + centUnit - BigInt.one) ~/ centUnit;
    final whole = cents ~/ BigInt.from(100);
    final frac = (cents % BigInt.from(100)).toString().padLeft(2, '0');
    return '$whole.$frac';
  }

  // ── Launching the wallet ──────────────────────────────────────────────

  /// EIP-681 token transfer link, e.g.
  /// ethereum:0xUSDC@1/transfer?address=0xFriend&uint256=1230000
  static Uri buildTransferUri({
    required String recipientAddress,
    required BigInt rawAmount,
  }) {
    final net = SettlementConfig.active;
    return Uri.parse(
      'ethereum:${net.usdcAddress}@${net.chainId}/transfer'
      '?address=$recipientAddress&uint256=$rawAmount',
    );
  }

  /// MetaMask's own link for the same ERC-20 transfer. MetaMask applies this
  /// more reliably than a bare `ethereum:` link, and switches to the right
  /// chain by itself. (link.metamask.io is the domain in MetaMask's current
  /// deeplink docs; the older metamask.app.link form is not used.)
  /// If MetaMask is not installed this opens a web page instead, so keep the
  /// generic `ethereum:` button for other wallets.
  static Uri buildMetaMaskUri({
    required String recipientAddress,
    required BigInt rawAmount,
  }) {
    final net = SettlementConfig.active;
    return Uri.parse(
      'https://link.metamask.io/send/${net.usdcAddress}@${net.chainId}'
      '/transfer?address=$recipientAddress&uint256=$rawAmount',
    );
  }

  static Future<bool> launchWalletTransfer({
    required String recipientAddress,
    required BigInt rawAmount,
    bool metaMask = false,
  }) async {
    final uri = metaMask
        ? buildMetaMaskUri(
            recipientAddress: recipientAddress,
            rawAmount: rawAmount,
          )
        : buildTransferUri(
            recipientAddress: recipientAddress,
            rawAmount: rawAmount,
          );
    debugPrint('Wallet URI: $uri');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Wallet launch failed: $e');
      return false;
    }
  }

  static Future<void> redirectToWalletInstall() async {
    await launchUrl(
      Uri.parse(
        'https://play.google.com/store/search?q=wallet+ethereum&c=apps',
      ),
      mode: LaunchMode.externalApplication,
    );
  }

  // ── Verifying ONE transaction hash ────────────────────────────────────

  /// Checks one transaction hash on-chain: it must have succeeded and contain
  /// a USDC `Transfer` to [recipientAddress] of at least [minRawAmount].
  /// This reads the Transfer event log, so it works for any wallet.
  static Future<TransferCheck> verifyTransfer({
    required String txHash,
    required String recipientAddress,
    required BigInt minRawAmount,
  }) async {
    final hash = txHash.trim();
    if (!isValidTxHash(hash)) {
      return const TransferCheck(
        TransferCheckStatus.mismatch,
        'That does not look like a transaction hash (0x + 64 characters).',
      );
    }

    final net = SettlementConfig.active;
    final client = Web3Client(net.rpcUrl, http.Client());
    try {
      final receipt = await client.getTransactionReceipt(hash);
      if (receipt == null) {
        return TransferCheck(
          TransferCheckStatus.notFound,
          'Transaction not found on ${net.name} yet. If you just paid, wait '
          'a minute and try again.',
        );
      }
      if (receipt.status != true) {
        return const TransferCheck(
          TransferCheckStatus.failed,
          'That transaction failed on-chain, so no money was sent.',
        );
      }

      final usdc = net.usdcAddress.toLowerCase().replaceFirst('0x', '');
      final wantTo = recipientAddress.toLowerCase().replaceFirst('0x', '');

      for (final log in receipt.logs) {
        final logAddr = log.address?.hex.toLowerCase().replaceFirst('0x', '');
        final topics = log.topics;
        if (logAddr != usdc || topics == null || topics.length < 3) continue;
        if (topics[0]?.toLowerCase() != _transferTopic) continue;

        final toTopic = (topics[2] ?? '').toLowerCase();
        if (toTopic.length < 40 ||
            toTopic.substring(toTopic.length - 40) != wantTo) {
          continue;
        }

        final data = log.data;
        if (data == null || data.length <= 2) continue;
        final amount = BigInt.parse(data);
        if (amount >= minRawAmount) {
          return TransferCheck(
            TransferCheckStatus.verified,
            'Verified: ${formatUsdc(amount)} USDC received.',
          );
        }
        return TransferCheck(
          TransferCheckStatus.mismatch,
          'That payment was only ${formatUsdc(amount)} USDC, less than the '
          '${formatUsdc(minRawAmount)} USDC needed.',
        );
      }

      return const TransferCheck(
        TransferCheckStatus.mismatch,
        'No USDC transfer to this friend was found in that transaction.',
      );
    } catch (e) {
      debugPrint('Verify failed: $e');
      return const TransferCheck(
        TransferCheckStatus.networkError,
        'Could not reach the blockchain node. Check your internet and retry.',
      );
    } finally {
      await client.dispose();
    }
  }

  // ── Finding a payment automatically ───────────────────────────────────

  static String _addressTopic(String a) =>
      '0x${a.trim().toLowerCase().replaceFirst('0x', '').padLeft(64, '0')}';

  /// Latest block number. Saved when the user taps Settle so the later
  /// lookup only searches payments made after that moment.
  static Future<int> currentBlock() async {
    final client = Web3Client(SettlementConfig.active.rpcUrl, http.Client());
    try {
      return await client.getBlockNumber();
    } finally {
      await client.dispose();
    }
  }

  /// USDC balance of [owner] on the active network (raw units), or null if
  /// the lookup fails. Used to warn before opening the wallet, because a
  /// transfer larger than the balance shows "likely to fail" in MetaMask.
  static Future<BigInt?> usdcBalanceOf(String owner) async {
    final net = SettlementConfig.active;
    final client = Web3Client(net.rpcUrl, http.Client());
    try {
      final arg = owner
          .trim()
          .toLowerCase()
          .replaceFirst('0x', '')
          .padLeft(64, '0');
      final res = await client.callRaw(
        contract: EthereumAddress.fromHex(net.usdcAddress),
        data: hexToBytes('0x70a08231$arg'), // balanceOf(address)
      );
      final hex = res.replaceFirst('0x', '');
      return hex.isEmpty ? BigInt.zero : BigInt.parse(hex, radix: 16);
    } catch (e) {
      debugPrint('Balance lookup failed: $e');
      return null;
    } finally {
      await client.dispose();
    }
  }

  /// ONE lookup: USDC transfers TO [recipientAddress] since [fromBlock], of
  /// at least [minRawAmount].
  ///
  /// If [payerAddress] is given, only transfers FROM that address count
  /// (strict). If it is empty, any sender matches, so the payment is found
  /// without the user typing or pasting anything.
  static Future<PayerLookup> findPayment({
    required String recipientAddress,
    required BigInt minRawAmount,
    required int fromBlock,
    String payerAddress = '',
  }) async {
    final net = SettlementConfig.active;
    final client = Web3Client(net.rpcUrl, http.Client());
    try {
      final payer = payerAddress.trim();
      final logs = await client.getLogs(
        FilterOptions(
          address: EthereumAddress.fromHex(net.usdcAddress),
          topics: [
            [_transferTopic],
            // An empty list means "any sender" in the JSON-RPC filter.
            payer.isEmpty ? <String>[] : [_addressTopic(payer)],
            [_addressTopic(recipientAddress)],
          ],
          fromBlock: BlockNum.exact(fromBlock),
          toBlock: BlockNum.current(),
        ),
      );

      final matches = <FoundTransfer>[];
      var sawSmaller = false;
      for (final log in logs) {
        final data = log.data;
        final hash = log.transactionHash;
        if (data == null || data.length <= 2 || hash == null) continue;
        final amount = BigInt.parse(data);
        if (amount >= minRawAmount) {
          final topics = log.topics;
          final t1 = (topics != null && topics.length > 1)
              ? (topics[1] ?? '')
              : '';
          final from = t1.length >= 40
              ? '0x${t1.substring(t1.length - 40)}'
              : null;
          matches.add(FoundTransfer(hash, amount, from));
        } else {
          sawSmaller = true;
        }
      }

      if (matches.isNotEmpty) {
        return PayerLookup(
          TransferCheckStatus.verified,
          'Verified: ${formatUsdc(matches.first.amount)} USDC received.',
          matches,
        );
      }
      return PayerLookup(
        TransferCheckStatus.notFound,
        sawSmaller
            ? 'A payment was found, but it was less than the '
                  '${formatUsdc(minRawAmount)} USDC needed.'
            : 'No payment found yet. If you just paid, wait a minute and '
                  'check again.',
      );
    } catch (e) {
      debugPrint('Payment lookup failed: $e');
      return const PayerLookup(
        TransferCheckStatus.networkError,
        'Could not reach the blockchain node. Check your internet and retry.',
      );
    } finally {
      await client.dispose();
    }
  }

  /// Kept so older callers still compile.
  static Future<PayerLookup> findPaymentByPayer({
    required String payerAddress,
    required String recipientAddress,
    required BigInt minRawAmount,
    required int fromBlock,
  }) {
    return findPayment(
      recipientAddress: recipientAddress,
      minRawAmount: minRawAmount,
      fromBlock: fromBlock,
      payerAddress: payerAddress,
    );
  }
}
