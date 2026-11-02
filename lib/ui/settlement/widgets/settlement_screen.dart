import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zplit/core/services/settlement_config.dart';
import 'package:zplit/core/services/settlement_service.dart';
import 'package:zplit/ui/settlement/view_model/settlement_bloc.dart';
import 'package:zplit/ui/settlement/view_model/settlement_event.dart';
import 'package:zplit/ui/settlement/view_model/settlement_state.dart';

/// Pops with a [SettlementResult] when the user finishes (verified on-chain,
/// pending, or self-reported), or with null if they back out.
class SettlementScreen extends StatelessWidget {
  /// Used to save a session so the payment can still be found if Android
  /// kills Zplit while the wallet is open. Empty = no session.
  final String friendPublicKey;
  final String friendName;
  final String friendWalletAddress;
  final double balanceInInr;

  /// Kept so the existing router / FriendDetailScreen arguments still work.
  /// The amount actually sent is recomputed from [balanceInInr] with integer
  /// maths, so this value is not used.
  final double balanceInUsdc;

  const SettlementScreen({
    super.key,
    this.friendPublicKey = '',
    required this.friendName,
    required this.friendWalletAddress,
    required this.balanceInInr,
    required this.balanceInUsdc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettlementBloc(),
      child: _SettlementView(
        friendPublicKey: friendPublicKey,
        friendName: friendName,
        friendWalletAddress: friendWalletAddress,
        balanceInInr: balanceInInr,
      ),
    );
  }
}

class _SettlementView extends StatefulWidget {
  final String friendPublicKey;
  final String friendName;
  final String friendWalletAddress;
  final double balanceInInr;

  const _SettlementView({
    this.friendPublicKey = '',
    required this.friendName,
    required this.friendWalletAddress,
    required this.balanceInInr,
  });

  @override
  State<_SettlementView> createState() => _SettlementViewState();
}

class _SettlementViewState extends State<_SettlementView>
    with WidgetsBindingObserver {
  final _hashController = TextEditingController();
  final _payerController = TextEditingController();
  static const _payerKey = 'payer_wallet_address';

  /// True once Zplit has actually gone to the background while waiting for
  /// the wallet, so a stray "resumed" (e.g. a system dialog) isn't mistaken
  /// for the user returning from the wallet.
  bool _wentToBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPayerAddress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hashController.dispose();
    _payerController.dispose();
    super.dispose();
  }

  // launchUrl returns almost immediately, so `paused` can arrive while the
  // bloc is still in SettlementLaunching (before AwaitingReturn is emitted).
  // We record `paused` in both states so the later `resumed` is not lost.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final s = context.read<SettlementBloc>().state;

    final waitingForWallet =
        s is SettlementLaunching || s is SettlementAwaitingReturn;

    if (state == AppLifecycleState.paused && waitingForWallet) {
      _wentToBackground = true;
    } else if (state == AppLifecycleState.resumed &&
        _wentToBackground &&
        s is SettlementAwaitingReturn) {
      _wentToBackground = false;
      context.read<SettlementBloc>().add(SettlementReturned());
    }
  }

  /// The payer address is asked once and remembered.
  Future<void> _loadPayerAddress() async {
    try {
      final saved = await const FlutterSecureStorage().read(key: _payerKey);
      if (mounted && saved != null && _payerController.text.isEmpty) {
        _payerController.text = saved;
      }
    } catch (_) {
      // Storage unavailable: the user can type it again.
    }
  }

  /// [metaMask] = true opens MetaMask's own link instead of a generic
  /// `ethereum:` link.
  Future<void> _settle(BuildContext context, {bool metaMask = false}) async {
    final payer = _payerController.text.trim();
    if (SettlementService.isValidAddress(payer)) {
      try {
        await const FlutterSecureStorage().write(key: _payerKey, value: payer);
      } catch (_) {}
    }
    if (!context.mounted) return;
    context.read<SettlementBloc>().add(
      SettleRequested(
        friendWalletAddress: widget.friendWalletAddress,
        balanceInInr: widget.balanceInInr,
        payerAddress: payer,
        friendPublicKey: widget.friendPublicKey,
        friendName: widget.friendName,
        useMetaMask: metaMask,
      ),
    );
  }

  /// Fills the hash field from the clipboard, but only when the field is
  /// empty and the clipboard holds something shaped like a tx hash
  /// (0x + 64 hex characters). Android only lets an app read the clipboard
  /// once it has window focus again, which can be a moment after resuming,
  /// so this tries a few times. The user still taps "Verify payment".
  Future<void> _prefillHashFromClipboard() async {
    for (var i = 1; i <= 3; i++) {
      await Future.delayed(Duration(milliseconds: 400 * i));
      if (!mounted || _hashController.text.isNotEmpty) return;
      try {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text?.trim();
        if (text != null && SettlementService.isValidTxHash(text)) {
          _hashController.text = text;
          return;
        }
      } catch (_) {
        // Clipboard unavailable: the user can still paste manually.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final settlementState = context.watch<SettlementBloc>().state;

    // Once a payment is verified or submitted, going "back" must still hand
    // it to the caller. Otherwise a paid payment would be lost: its hash is
    // already marked as used, so nothing would ever find it again.
    final SettlementResult? resultOnBack = switch (settlementState) {
      SettlementVerified(:final txHash) => SettlementResult(
        verified: true,
        txHash: txHash,
      ),
      SettlementPending(:final txHash) => SettlementResult(
        verified: false,
        txHash: txHash,
        pending: true,
      ),
      _ => null,
    };

    return PopScope(
      canPop: resultOnBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && resultOnBack != null) {
          Navigator.pop(context, resultOnBack);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Settle Balance')),
        body: BlocListener<SettlementBloc, SettlementState>(
          listener: (context, st) {
            // Back from the wallet and the automatic lookup found nothing:
            // if the clipboard holds a tx hash, fill it in.
            if (st is SettlementConfirming) _prefillHashFromClipboard();

            // Covers the case where the app already resumed *before* the
            // bloc flipped to SettlementAwaitingReturn.
            if (st is SettlementAwaitingReturn &&
                _wentToBackground &&
                WidgetsBinding.instance.lifecycleState ==
                    AppLifecycleState.resumed) {
              _wentToBackground = false;
              context.read<SettlementBloc>().add(SettlementReturned());
            } else if (st is! SettlementLaunching &&
                st is! SettlementAwaitingReturn) {
              // Not waiting on the wallet any more: drop any stale flag.
              _wentToBackground = false;
            }
          },
          child: BlocBuilder<SettlementBloc, SettlementState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _summaryCard(theme, colors),
                    const SizedBox(height: 16),
                    if (SettlementConfig.active.isTestnet)
                      _messageBox(
                        colors,
                        'Test network (${SettlementConfig.active.name}) — '
                        'no real money moves. Make sure this network is '
                        'enabled in your wallet and that it holds test USDC '
                        'and a little test ETH for fees.',
                      )
                    else
                      _messageBox(
                        colors,
                        'Live network (${SettlementConfig.active.name}): this '
                        'sends real USDC and cannot be undone. Network fees '
                        'are paid in ETH and can be high for small amounts.',
                        isError: true,
                      ),
                    _body(context, theme, colors, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── State-driven body ─────────────────────────────────────────────────

  Widget _body(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    SettlementState state,
  ) {
    if (state is SettlementLaunching) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Preparing your payment…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (state is SettlementAwaitingReturn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _messageBox(
            colors,
            'Complete the payment in your wallet, then come back to Zplit. '
            'Zplit will find the payment on its own.',
          ),
          OutlinedButton(
            onPressed: () =>
                context.read<SettlementBloc>().add(SettlementReturned()),
            child: const Text("I've finished in my wallet"),
          ),
        ],
      );
    }

    if (state is SettlementConfirming || state is SettlementVerifying) {
      return _confirmSection(context, theme, colors, state);
    }

    if (state is SettlementVerified) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _messageBox(colors, state.message, success: true),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse(SettlementConfig.active.txUrl(state.txHash)),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('View transaction'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              SettlementResult(verified: true, txHash: state.txHash),
            ),
            style: _primaryButtonStyle(colors),
            child: const Text('Done'),
          ),
        ],
      );
    }

    if (state is SettlementPending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _messageBox(
            colors,
            'Payment submitted. ${state.message}\n\n'
            'Zplit will check this transaction again each time you open the '
            'app, and tell you when it is confirmed.',
          ),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse(SettlementConfig.active.txUrl(state.txHash)),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('View transaction'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              SettlementResult(
                verified: false,
                txHash: state.txHash,
                pending: true,
              ),
            ),
            style: _primaryButtonStyle(colors),
            child: const Text('Done'),
          ),
        ],
      );
    }

    if (state is SettlementSelfReported) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _messageBox(
            colors,
            'Marked as paid. Zplit could not verify this payment, so it is '
            'recorded as unverified.',
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, const SettlementResult(verified: false)),
            style: _primaryButtonStyle(colors),
            child: const Text('Done'),
          ),
        ],
      );
    }

    // Initial, NoWalletFound, Error → show the pay button (+ any message).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tapping below opens your wallet app (MetaMask, Trust Wallet, etc.) '
          'with the USDC transfer pre-filled. Confirm the send inside your '
          'wallet — Zplit never holds or moves your funds. When you come '
          'back, Zplit looks for the payment automatically.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        if (state is SettlementNoWalletFound) ...[
          _messageBox(
            colors,
            'No wallet app found on this device.',
            isError: true,
          ),
          OutlinedButton(
            onPressed: SettlementService.redirectToWalletInstall,
            child: const Text('Install a wallet app'),
          ),
          const SizedBox(height: 12),
        ],
        if (state is SettlementError) ...[
          _messageBox(colors, state.message, isError: true),
        ],
        TextField(
          controller: _payerController,
          decoration: InputDecoration(
            labelText: 'Your wallet address (optional)',
            helperText:
                'Not needed. Adding it makes automatic detection stricter '
                'and lets Zplit warn you if your balance is too low.',
            helperMaxLines: 3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _settle(context),
          style: _primaryButtonStyle(colors),
          child: const Text('Settle with Wallet'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _settle(context, metaMask: true),
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: const Text('Open in MetaMask'),
        ),
        const SizedBox(height: 20),
        _manualFallback(theme, colors),
      ],
    );
  }

  /// Shown for when the wallet doesn't open pre-filled: the user can send the
  /// payment by hand, and Zplit still finds it afterwards.
  Widget _manualFallback(ThemeData theme, ColorScheme colors) {
    final raw = SettlementService.usdcRawFromInr(widget.balanceInInr);
    final net = SettlementConfig.active;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet didn\'t open pre-filled?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Send USDC manually on ${net.name}, then come back to Zplit.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          _copyRow('To', widget.friendWalletAddress),
          _copyRow('Amount', SettlementService.formatUsdc(raw)),
          _copyRow('USDC token', net.usdcAddress),
        ],
      ),
    );
  }

  Widget _copyRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $value',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label copied'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _confirmSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    SettlementState state,
  ) {
    final verifying = state is SettlementVerifying;
    final notice = state is SettlementConfirming ? state.notice : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          verifying
              ? 'Looking for your payment…'
              : 'Did you complete the payment?',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          verifying
              ? 'This can take up to a minute while the network confirms it.'
              : 'Zplit checks the network for your payment. If it is not '
                    'found, paste the transaction hash from your wallet and '
                    'Zplit will check it on-chain.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        if (verifying)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (notice != null) _messageBox(colors, notice, isError: true),
        TextField(
          controller: _hashController,
          enabled: !verifying,
          decoration: InputDecoration(
            labelText: 'Transaction hash (0x…)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.paste),
              onPressed: verifying
                  ? null
                  : () async {
                      final data = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );
                      if (data?.text != null) {
                        _hashController.text = data!.text!.trim();
                      }
                    },
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: verifying
              ? null
              : () => context.read<SettlementBloc>().add(
                  SettlementVerifyRequested(
                    txHash: _hashController.text,
                    friendWalletAddress: widget.friendWalletAddress,
                    balanceInInr: widget.balanceInInr,
                  ),
                ),
          style: _primaryButtonStyle(colors),
          child: const Text('Verify payment'),
        ),
        const SizedBox(height: 8),
        if (state is SettlementConfirming)
          OutlinedButton(
            onPressed: () => context.read<SettlementBloc>().add(
              SettlementCheckAgainRequested(),
            ),
            child: const Text('Check again for my payment'),
          ),
        TextButton(
          onPressed: verifying
              ? null
              : () =>
                    context.read<SettlementBloc>().add(SettlementPaidClaimed()),
          child: const Text('Mark as paid without verifying'),
        ),
        TextButton(
          onPressed: verifying
              ? null
              : () => context.read<SettlementBloc>().add(SettlementReset()),
          child: const Text("I didn't pay / try again"),
        ),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────

  Widget _summaryCard(ThemeData theme, ColorScheme colors) {
    final raw = SettlementService.usdcRawFromInr(widget.balanceInInr);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _row(theme, 'Settling with', widget.friendName),
          const SizedBox(height: 12),
          _row(
            theme,
            'Current balance',
            '₹${widget.balanceInInr.abs().toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _row(
            theme,
            'You will send',
            '${SettlementService.formatUsdc(raw)} USDC',
            highlight: true,
            color: colors.primary,
          ),
          const SizedBox(height: 12),
          _row(theme, 'Network', SettlementConfig.active.name),
          const SizedBox(height: 12),
          _row(
            theme,
            'Rate',
            '1 USD = ₹${SettlementConfig.inrPerUsd.toStringAsFixed(2)}',
          ),
          if (SettlementConfig.rateIsLive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse('https://www.exchangerate-api.com'),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(
                  'Rates By Exchange Rate API',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _messageBox(
    ColorScheme colors,
    String text, {
    bool isError = false,
    bool success = false,
  }) {
    final bg = isError
        ? colors.errorContainer
        : success
        ? Colors.green.withValues(alpha: 0.12)
        : colors.primaryContainer;
    final fg = isError ? colors.onErrorContainer : colors.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : success
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              color: isError
                  ? colors.error
                  : success
                  ? Colors.green
                  : colors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: TextStyle(color: fg)),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle(ColorScheme colors) =>
      ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  Widget _row(
    ThemeData theme,
    String label,
    String value, {
    bool highlight = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight ? color : null,
          ),
        ),
      ],
    );
  }
}
