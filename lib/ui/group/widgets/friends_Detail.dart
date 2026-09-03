import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/transaction/transaction_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
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
  bool get _hasFriendPicture =>
      widget.friend.profilePicture != null &&
      File(widget.friend.profilePicture!).existsSync();

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadAllTransactions());
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
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: colors.primary.withOpacity(0.12),
                            backgroundImage: _hasFriendPicture
                                ? FileImage(File(widget.friend.profilePicture!))
                                : null,
                            child: !_hasFriendPicture
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
                          Text(
                            widget.friend.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amountInRupees == 0
                      ? 'Settled'
                      : '₹${amountInRupees.abs().toStringAsFixed(2)}', // ✅ correct amount
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    color: amountInRupees == 0
                        ? theme.colorScheme.onSurface.withOpacity(0.4)
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

  Widget _buildActionChip(BuildContext context, IconData icon, String label) {
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: () {},
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
        side: BorderSide(color: colors.primary.withOpacity(0.4)),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
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
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TransactionError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              if (state is TransactionLoaded) {
                final txs = state.transactions.where((tx) {
                  return (tx.fromUserPublicKey == widget.currentUserPublicKey &&
                          tx.toUserPublicKey == widget.friend.publicKey) ||
                      (tx.toUserPublicKey == widget.currentUserPublicKey &&
                          tx.fromUserPublicKey == widget.friend.publicKey);
                }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (txs.isEmpty) {
                  return const Center(
                    child: Text('No transactions shared yet.'),
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
                              color: Colors.grey[500],
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

    // ✅ Divide by 100 — stored in paise, display in rupees
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
              color: iconBg.withOpacity(0.12),
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
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(tx.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                // ✅ derived from amount sign, not from who created the row
                iPaid ? 'You paid:' : '${widget.friend.displayName} paid:',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${amountInRupees.abs().toStringAsFixed(2)}', // ✅ always show magnitude
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
