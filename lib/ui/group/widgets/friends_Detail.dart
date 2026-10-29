import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zplit/core/services/settlement_config.dart';
import 'package:zplit/core/services/settlement_service.dart';

import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/transaction/transaction_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_event.dart';

import 'package:zplit/ui/balance/view_model/balance_state.dart';
import 'package:zplit/ui/settlement/view_model/settlement_state.dart'
    show SettlementResult;
import 'package:zplit/ui/settlement/widgets/settlement_tracker.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:zplit/routing/App_router.dart';

class FriendDetailScreen extends StatefulWidget {
  final UserModel friend;

  /// Snapshot passed in when the screen was opened. Only used as a fallback
  /// while the live balance from [BalanceBloc] isn't available.
  final BalanceModel? balance;
  final String currentUserPublicKey;

  const FriendDetailScreen({
    super.key,
    required this.friend,
    required this.currentUserPublicKey,
    this.balance,
  });

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen>
    with WidgetsBindingObserver {
  /// Submitted USDC payments for this friend that are still being tracked.
  List<PendingSettlement> _pending = [];

  bool _friendPictureExists = false;

  // BalanceBloc emits BalanceLoading before every load. Without a cache the
  // screen would flash the stale snapshot during loading. We keep the last
  // loaded value and keep showing it until a new BalanceLoaded arrives.
  BalanceModel? _lastBalance;

  /// Set right after a settlement is applied, so this screen shows the new
  /// balance immediately. Cleared as soon as BalanceBloc reports fresh data.
  int? _netOverride;

  /// Current balance with this friend in paise (negative = you owe them).
  int get _currentNetPaise => _netOverride ?? (_lastBalance?.netAmount ?? 0);

  @override
  void initState() {
    super.initState();
    _lastBalance = widget.balance;
    context.read<TransactionBloc>().add(LoadAllTransactions());

    context.read<BalanceBloc>().add(LoadAllBalances());
    _checkFriendPicture();
    WidgetsBinding.instance.addObserver(this);

    // After the first frame: _refreshPending reads ModalRoute.of(context),
    // which isn't allowed to be looked up inside initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshPending();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPending();
  }

  Future<void> _refreshPending() async {
    // When returning from the wallet, this screen also gets "resumed" while
    // the settlement screen is still on top. Only look for unfinished
    // sessions when THIS screen is visible, so the two don't race for the
    // same payment.
    final isOnTop = ModalRoute.of(context)?.isCurrent ?? true;

    final stored = await SettlementTracker.forFriend(widget.friend.publicKey);
    if (mounted) setState(() => _pending = stored);

    if (isOnTop) await SettlementTracker.resumeSessions();
    await SettlementTracker.checkAll();

    final updated = await SettlementTracker.forFriend(widget.friend.publicKey);
    if (mounted) setState(() => _pending = updated);
  }

  Future<void> _savePending(SettlementResult result, double absInr) async {
    final hash = result.txHash;
    if (hash == null) return;

    await SettlementTracker.add(
      PendingSettlement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        friendPublicKey: widget.friend.publicKey,
        friendName: widget.friend.displayName,
        friendWalletAddress: widget.friend.cryptoAddress ?? '',
        amountPaise: (absInr * 100).round(),
        minRawAmount: SettlementService.usdcRawFromInr(absInr).toString(),
        txHash: hash,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment submitted. Zplit will confirm it when the network does.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    await _refreshPending();
  }

  /// The payment is confirmed on-chain: apply it to the balance, then stop
  /// tracking the payment.
  Future<void> _sendConfirmedSettlement(PendingSettlement p) async {
    await _recordSettlement(
      p.amountPaise / 100.0,
      txHash: p.txHash,
      verified: true,
    );
    await SettlementTracker.remove(p.id);
    await _refreshPending();
  }

  Future<void> _dismissPending(PendingSettlement p) async {
    await SettlementTracker.remove(p.id);
    await _refreshPending();
  }

  Future<void> _checkFriendPicture() async {
    final path = widget.friend.profilePicture;
    if (path == null || path.isEmpty) return;
    final exists = await File(path).exists();
    if (mounted) setState(() => _friendPictureExists = exists);
  }

  /// Reads the current balance for this friend from [BalanceBloc].
  ///
  /// NOTE: assumes BalanceLoaded exposes the list as `balances`. Rename if
  /// your BalanceState uses a different field name.
  ///
  /// CAUTION: LoadPositiveBalances / LoadNegativeBalances also emit
  /// BalanceLoaded with a filtered list. If another screen dispatches those
  /// while this one is open, a friend you owe could be missing from the list
  /// and wrongly show as "Settled".
  BalanceModel? _liveBalance(BalanceState s) {
    if (s is BalanceLoaded) {
      BalanceModel? found;
      for (final b in s.balances) {
        if (b.userPublicKey == widget.friend.publicKey) {
          found = b;
          break;
        }
      }
      _lastBalance = found; // null = no entry = settled
      _netOverride = null; // fresh data replaces the optimistic value
    } else if (s is BalanceError) {
      _netOverride = null; // the write may have failed: show the truth
    }
    // Loading / initial: keep showing the last known value.
    return _lastBalance;
  }

  Future<void> _onSettleUpTapped(double amountInRupees) async {
    final address = widget.friend.cryptoAddress;
    if (address == null || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.friend.displayName} hasn\'t set up a wallet yet.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (amountInRupees == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'re already settled up.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Positive balance = the friend owes ME. Settlement sends USDC from my
    // wallet to theirs, so it only makes sense when I owe them.
    if (amountInRupees > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.friend.displayName} owes you — they need to pay you.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Don't let the user pay twice while a payment is still being tracked.
    if (_pending.any((p) => p.status != PendingSettlementStatus.failed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You already have a payment waiting for this friend. '
            'Finish that one first.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final absInr = amountInRupees.abs();

    final usdcAmount = absInr / SettlementConfig.inrPerUsd;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.settlement,
      arguments: {
        'friendPublicKey': widget.friend.publicKey,
        'friendName': widget.friend.displayName,
        'friendWalletAddress': address,
        'balanceInInr': absInr,
        'balanceInUsdc': usdcAmount,
      },
    );

    if (!mounted || result is! SettlementResult) return; // backed out

    // Handled here now, so the startup lookup must not pick it up again.
    await SettlementTracker.clearSession(widget.friend.publicKey);

    if (result.pending && result.txHash != null) {
      // Submitted but not confirmed yet: track it, re-check on next app open.
      await _savePending(result, absInr);
      return;
    }

    // verified == true  → paid and confirmed on-chain
    // verified == false → "Mark as paid without verifying"
    await _recordSettlement(
      absInr,
      txHash: result.txHash,
      verified: result.verified,
    );
  }

  /// Applies a USDC settlement to this friend's balance (on this phone).
  Future<void> _recordSettlement(
    double absInr, {
    String? txHash,
    required bool verified,
  }) async {
    final current = _currentNetPaise; // negative = you owe
    final paidPaise = (absInr * 100).round();
    final newNet = current + paidPaise; // full settlement -> 0

    context.read<BalanceBloc>().add(
      UpsertBalance(
        userPublicKey: widget.friend.publicKey,
        netAmount: newNet,
        currency: 'INR',
      ),
    );

    setState(() => _netOverride = newNet); // update this screen right away

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          verified
              ? 'Settled with ${widget.friend.displayName} ✓'
              : 'Marked as paid (unverified)',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild whenever BalanceBloc changes so the amount updates.
    return BlocBuilder<BalanceBloc, BalanceState>(
      builder: (context, balState) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        _liveBalance(balState); // refreshes _lastBalance / clears the override

        final amountInRupees = _currentNetPaise / 100.0;
        final isPositive = amountInRupees >= 0;

        String oweLabel;
        if (amountInRupees == 0) {
          oweLabel = 'you are all settled';
        } else if (isPositive) {
          oweLabel = '${widget.friend.displayName} owes you';
        } else {
          oweLabel = 'you owe ${widget.friend.displayName}';
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // ── Top bar ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          // Wrapped in Expanded so a long display name next to
                          // the avatar and the overflow menu doesn't push past
                          // screen edges on narrow devices or at large
                          // accessibility font scales.
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: colors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  backgroundImage: _friendPictureExists
                                      ? FileImage(
                                          File(widget.friend.profilePicture!),
                                        )
                                      : null,
                                  child: !_friendPictureExists
                                      ? Text(
                                          widget.friend.displayName.isNotEmpty
                                              ? widget.friend.displayName[0]
                                                    .toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: colors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.friend.displayName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {},
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'remove',
                                child: Text('Remove Friend'),
                              ),
                              const PopupMenuItem(
                                value: 'block',
                                child: Text(
                                  'Block Friend',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      oweLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amountInRupees == 0
                          ? 'Settled'
                          : '₹${amountInRupees.abs().toStringAsFixed(2)}',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        color: amountInRupees == 0
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                            : isPositive
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Action buttons ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionChip(
                          context,
                          Icons.handshake_outlined,
                          'Settle Up',
                          onTap: () => _onSettleUpTapped(amountInRupees),
                        ),
                        const SizedBox(width: 10),
                        _buildActionChip(
                          context,
                          Icons.send_outlined,
                          'Remind',
                        ),
                        const SizedBox(width: 10),
                        _buildActionChip(
                          context,
                          Icons.ios_share_outlined,
                          'Export',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Submitted USDC payments being tracked ──
                    ..._buildPendingBanners(theme, colors),

                    // ── Transactions ──
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildTransactionList(theme, colors),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sticky Add An Expense button ──
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.addExpense),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Add An Expense',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: const StadiumBorder(),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPendingBanners(ThemeData theme, ColorScheme colors) {
    return _pending.map((p) {
      final String title;
      final String body;
      final Color tint;
      final List<Widget> actions;

      switch (p.status) {
        case PendingSettlementStatus.checking:
          title = 'Waiting for confirmation';
          body =
              'Your USDC payment was submitted. Zplit checks it again each '
              'time you open the app.';
          tint = colors.primary;
          actions = [
            TextButton(
              onPressed: _refreshPending,
              child: const Text('Check now'),
            ),
          ];
        case PendingSettlementStatus.confirmed:
          title = 'Payment confirmed';
          body =
              '${p.notice ?? 'Your USDC payment is confirmed.'} '
              'Tap below to clear your balance with ${p.friendName}.';
          tint = Colors.green;
          actions = [
            ElevatedButton(
              onPressed: () => _sendConfirmedSettlement(p),
              child: const Text('Clear balance'),
            ),
          ];
        case PendingSettlementStatus.failed:
          title = 'Payment could not be confirmed';
          body = p.notice ?? 'The transaction could not be verified.';
          tint = colors.error;
          actions = [
            TextButton(
              onPressed: () => _dismissPending(p),
              child: const Text('Dismiss'),
            ),
          ];
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tint.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tint,
                ),
              ),
              const SizedBox(height: 4),
              Text(body, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(spacing: 8, children: actions),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildActionChip(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap ?? () {},
      icon: Icon(icon, size: 16, color: colors.primary),
      label: Text(
        label,
        style: TextStyle(
          color: colors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }

  Widget _buildTransactionList(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'Filter',
                    // onSurface.withOpacity matches the convention used
                    // everywhere else in this app (adapts to dark mode).
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.tune, size: 16, color: colors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return Center(
                  child: CircularProgressIndicator(color: colors.primary),
                );
              }
              if (state is TransactionError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colors.error,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Couldn\'t load transactions: ${state.message}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.read<TransactionBloc>().add(
                            LoadAllTransactions(),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is TransactionLoaded) {
                final txs = state.transactions.where((tx) {
                  return (tx.fromUserPublicKey == widget.currentUserPublicKey &&
                          tx.toUserPublicKey == widget.friend.publicKey) ||
                      (tx.toUserPublicKey == widget.currentUserPublicKey &&
                          tx.fromUserPublicKey == widget.friend.publicKey);
                }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (txs.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions shared yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }

                final Map<String, List<TransactionModel>> grouped = {};
                for (final tx in txs) {
                  final label = _monthLabel(tx.createdAt);
                  grouped.putIfAbsent(label, () => []);
                  grouped[label]!.add(tx);
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            entry.key,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (tx) => _buildTransactionTile(tx, theme, colors),
                        ),
                      ],
                    );
                  }).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(
    TransactionModel tx,
    ThemeData theme,
    ColorScheme colors,
  ) {
    // ── Who actually paid ──
    // tx.fromUserPublicKey is whoever CREATED the transaction record, which is
    // NOT necessarily who paid (the "They Paid" split option lets the creator
    // record that the *other* person paid). The sign of tx.amount is the real
    // source of truth for direction, matching the balance-update logic:
    //   amount > 0  → fromUser owes toUser   → toUser paid
    //   amount < 0  → toUser owes fromUser   → fromUser paid
    final isFromUser = tx.fromUserPublicKey == widget.currentUserPublicKey;
    final amountIsPositive = tx.amount > BigInt.zero;
    final iPaid = amountIsPositive ? !isFromUser : isFromUser;

    final amountInRupees = (tx.amount / BigInt.from(100)).toDouble();

    IconData itemIcon = Icons.receipt_long_outlined;
    Color iconBg = const Color(0xFF6366F1);

    final tag = tx.tag?.toLowerCase() ?? '';
    final desc = tx.description?.toLowerCase() ?? '';
    if (tag.contains('grocery') || desc.contains('grocery')) {
      itemIcon = Icons.shopping_cart_outlined;
      iconBg = const Color(0xFFF97316);
    } else if (tag.contains('uber') || desc.contains('uber')) {
      itemIcon = Icons.local_taxi_outlined;
      iconBg = const Color(0xFF6366F1);
    } else if (tag.contains('food') || desc.contains('food')) {
      itemIcon = Icons.restaurant_outlined;
      iconBg = const Color(0xFFEF4444);
    } else if (tag.contains('rent') || desc.contains('rent')) {
      itemIcon = Icons.home_outlined;
      iconBg = const Color(0xFF10B981);
    } else if (tag.contains('fuel') || desc.contains('fuel')) {
      itemIcon = Icons.local_gas_station_outlined;
      iconBg = const Color(0xFFF59E0B);
    } else if (tag.contains('drinks') || desc.contains('drinks')) {
      itemIcon = Icons.local_bar_outlined;
      iconBg = const Color(0xFF8B5CF6);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(itemIcon, color: iconBg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description?.isNotEmpty == true
                      ? tx.description!
                      : 'Expense Split',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(tx.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                iPaid ? 'You paid:' : '${widget.friend.displayName} paid:',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '₹${amountInRupees.abs().toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_shortMonth(date.month)}';
  }

  String _monthLabel(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _shortMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
