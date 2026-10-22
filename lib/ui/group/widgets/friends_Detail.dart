import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zplit/core/services/bluetooth_service.dart' show BtEndpoint;
import 'package:zplit/core/services/crypto_service.dart';
import 'package:zplit/core/services/settlement_config.dart';
import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/transaction/transaction_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:zplit/ui/transaction/widgets/TransactionSentscreen.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_bloc.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_event.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_state.dart';
import 'package:zplit/routing/App_router.dart';

class FriendDetailScreen extends StatefulWidget {
  final UserModel friend;
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

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  // FIX: profile picture existence is now checked once asynchronously
  // instead of calling File(...).existsSync() synchronously inside
  // build() on every rebuild (blocking disk I/O on the UI thread) —
  // same fix pattern applied to HomeScreen.
  bool _friendPictureExists = false;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadAllTransactions());
    _checkFriendPicture();
  }

  Future<void> _checkFriendPicture() async {
    final path = widget.friend.profilePicture;
    if (path == null || path.isEmpty) return;
    final exists = await File(path).exists();
    if (mounted) setState(() => _friendPictureExists = exists);
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

    final absInr = amountInRupees.abs();
    // Single source of truth for the FX rate (SettlementConfig). The
    // settlement screen recomputes the real amount from absInr with integer
    // maths; this value is only passed along for compatibility.
    final usdcAmount = absInr / SettlementConfig.inrPerUsd;

    // The settlement screen pops with `true` once the user confirms they
    // paid in their wallet, or null if they back out.
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.settlement,
      arguments: {
        'friendName': widget.friend.displayName,
        'friendWalletAddress': address,
        'balanceInInr': absInr,
        'balanceInUsdc': usdcAmount,
      },
    );

    if (!mounted || result != true) return;

    await _recordSettlement(amountInRupees);
  }

  /// Records the settlement exactly the way AddExpenseScreen records an
  /// expense: create + sign the transaction, then send it to the friend over
  /// Bluetooth / WiFi Direct (if connected) and hand off to the sent screen
  /// for the link / QR / NFC options. The friend then gets the usual
  /// "Incoming Transaction" prompt, and once they Accept (and the ack comes
  /// back) the friend's balance clears too.
  Future<void> _recordSettlement(double amountInRupees) async {
    try {
      final me = widget.currentUserPublicKey;
      final friendKey = widget.friend.publicKey;
      final friendName = widget.friend.displayName;

      // Same convention as AddExpenseScreen's "You Paid": the amount is
      // NEGATIVE when the sender (me) paid, which cancels what I owed.
      final totalAmount = (amountInRupees.abs() * 100).round() / 100.0;
      final splitAmount = -totalAmount;
      final signedAmount = BigInt.from((splitAmount * 100).round());
      const splitType = 'You Paid';
      const tag = 'settlement';

      const desc = 'Settled via USDC';

      final txnId = DateTime.now().millisecondsSinceEpoch.toString();
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final senderSignature = await CryptoService.signTransaction(
        id: txnId,
        fromPublicKey: me,
        toPublicKey: friendKey,
        amount: signedAmount,
        currency: 'INR',
        description: desc,
        tag: tag,
        timestamp: ts,
      );
      if (!mounted) return;

      final txBloc = context.read<TransactionBloc>();
      txBloc.add(
        CreateTransaction(
          fromUserPublicKey: me,
          toUserPublicKey: friendKey,
          amount: signedAmount,
          currency: 'INR',
          description: desc,
          tag: tag,
        ),
      );
      txBloc.add(
        SignAsSender(transactionId: txnId, senderSignature: senderSignature),
      );

      final jsonPayload = jsonEncode({
        'id': txnId,
        'from': me,
        'to': friendKey,
        'amount': splitAmount,
        'split': splitType,
        'totalAmount': totalAmount,
        'desc': desc,
        'tag': tag,
        'ts': ts,
        'sig': senderSignature,
      });

      bool sentViaBluetooth = false;
      String? bluetoothEndpointId;
      final btState = context.read<BluetoothBloc>().state;
      final btEndpoint = _findConnectedEndpointForFriend(btState, friendName);
      if (btEndpoint != null) {
        context.read<BluetoothBloc>().add(
          BluetoothSendPayload(btEndpoint.id, jsonPayload),
        );
        sentViaBluetooth = true;
        bluetoothEndpointId = btEndpoint.id;
      }

      // WiFi Direct is a single 1-to-1 link, so being connected at all
      // means we are talking to this friend (same reasoning as
      // AddExpenseScreen._isWifiConnectedToFriend).
      bool sentViaWifi = false;
      final wifiState = context.read<WifiBloc>().state;
      if (wifiState.isConnected) {
        context.read<WifiBloc>().add(WifiSendPayload(jsonPayload));
        sentViaWifi = true;
      }

      // Zplit cannot check the blockchain (no RPC), so the payer's own
      // confirmation is the proof. Per SettlementConfig, mark the settlement
      // accepted locally right away so MY balance drops to zero now instead of
      // waiting for the friend to tap Accept. The short delay lets the create
      // + sign events above finish writing first.
      if (SettlementConfig.clearPayerBalanceImmediately) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        txBloc.add(AcceptTransaction(transactionId: txnId));
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        txBloc.add(LoadAllTransactions());
        context.read<BalanceBloc>().add(LoadAllBalances());
      }

      final encoded = base64Url.encode(utf8.encode(jsonPayload));
      final link = 'https://zplit.aossie.org/tx?d=$encoded';

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionSentScreen(
            friendName: friendName,
            totalAmount: totalAmount,
            splitAmount: splitAmount,
            splitType: splitType,
            description: desc,
            tag: tag,
            deepLink: link,
            sentViaBluetooth: sentViaBluetooth,
            bluetoothEndpointId: bluetoothEndpointId,
            bluetoothJsonPayload: sentViaBluetooth ? jsonPayload : null,
            nfcJsonPayload: jsonPayload,
            sentViaWifi: sentViaWifi,
            wifiJsonPayload: sentViaWifi ? jsonPayload : null,
          ),
        ),
      );

      if (!mounted) return;
      context.read<TransactionBloc>().add(LoadAllTransactions());
      context.read<BalanceBloc>().add(LoadAllBalances());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not record the settlement: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  BtEndpoint? _findConnectedEndpointForFriend(
    BluetoothState btState,
    String friendDisplayName,
  ) {
    for (final endpoint in btState.nearbyEndpoints) {
      final status = btState.connectionStatus[endpoint.id];
      if (endpoint.name == friendDisplayName &&
          status == BtConnectionStatus.connected) {
        return endpoint;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final balance = widget.balance;

    final amountInRupees = (balance?.netAmount ?? 0) / 100.0;
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
                      // FIX: wrapped in Expanded so a long display name
                      // next to the avatar and the overflow menu doesn't
                      // push past screen edges on narrow devices or at
                      // large accessibility font scales.
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
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
                    _buildActionChip(context, Icons.send_outlined, 'Remind'),
                    const SizedBox(width: 10),
                    _buildActionChip(
                      context,
                      Icons.ios_share_outlined,
                      'Export',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                    // FIX: was Colors.grey[600] — hardcoded, didn't
                    // adapt to dark mode. onSurface.withOpacity matches
                    // the convention used everywhere else in this app.
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
                // FIX: color now explicit + theme-matched, was an
                // unthemed default CircularProgressIndicator before.
                return Center(
                  child: CircularProgressIndicator(color: colors.primary),
                );
              }
              if (state is TransactionError) {
                // FIX: bare error text had no retry affordance — now
                // matches the pattern of a real error state with a
                // way to recover instead of a dead end.
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
                              // FIX: was Colors.grey[500] — hardcoded.
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
                    // FIX: was Colors.grey[500] — hardcoded.
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
                  // FIX: was Colors.grey[500] — hardcoded.
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
