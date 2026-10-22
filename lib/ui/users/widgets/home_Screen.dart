import 'dart:convert';
import 'dart:io';
import 'package:zplit/ui/transaction/view_model/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_event.dart';
import 'package:zplit/ui/balance/view_model/balance_state.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';
import 'package:zplit/ui/group/view_models/group_bloc.dart';
import 'package:zplit/ui/group/view_models/group_event.dart';
import 'package:zplit/ui/group/view_models/group_state.dart';
import 'package:zplit/ui/group/widgets/manage_groups_screen.dart';
import 'package:zplit/ui/transaction/view_model/transaction_bloc.dart';
import 'package:zplit/ui/transaction/view_model/transaction_event.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';
import 'package:zplit/ui/transaction/widgets/balance_card.dart';
import 'package:zplit/ui/users/widgets/friendlist.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_bloc.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _myAddress;

  // Profile picture existence is checked once, off the build path, instead
  // of calling File(...).existsSync() synchronously inside build() on every
  // rebuild (blocking disk I/O on the UI thread).
  String? _profilePicturePath;
  bool _profilePictureExists = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    FlutterSecureStorage().read(key: 'evm_address').then((addr) {
      if (mounted) setState(() => _myAddress = addr);
    });

    context.read<UserBloc>().add(LoadAllUsers());
    context.read<BalanceBloc>().add(LoadAllBalances());
    context.read<TransactionBloc>().add(LoadAllTransactions());
    context.read<GroupBloc>().add(LoadAllGroups());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfilePicture(String? path) async {
    if (path == _profilePicturePath) return; // avoid redundant disk hits
    _profilePicturePath = path;

    if (path == null || path.isEmpty) {
      if (mounted) setState(() => _profilePictureExists = false);
      return;
    }

    final exists = await File(path).exists();
    if (mounted) setState(() => _profilePictureExists = exists);
  }

  /// Opens the group management screen and reloads the list on return, so
  /// groups created or deleted there show up here straight away.
  Future<void> _openManageGroups() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageGroupsScreen()),
    );
    if (mounted) context.read<GroupBloc>().add(LoadAllGroups());
  }

  void _sendAck(
    BuildContext context,
    String txnId,
    String outcome,
    String? viaTransport,
  ) {
    final payload = jsonEncode({'id': txnId, 'outcome': outcome});

    switch (viaTransport) {
      case 'bluetooth':
        final endpointId = context
            .read<BluetoothBloc>()
            .state
            .lastReceivedFromEndpointId;
        if (endpointId == null) return;
        context.read<BluetoothBloc>().add(
          BluetoothSendPayload(endpointId, payload),
        );
        break;

      case 'wifi':
        context.read<WifiBloc>().add(WifiSendPayload(payload));
        break;

      case 'nfc':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Response saved locally — tap phones together again to '
              'let them know',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      default:
        break;
    }
  }

  void _showAcceptRejectSheet(BuildContext context, TransactionReceived state) {
    final transactionBloc = context.read<TransactionBloc>();
    final navigator = Navigator.of(context);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Incoming Transaction',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _infoRow(theme, 'From', state.fromUserName),
              _infoRow(
                theme,
                'Amount',
                '₹${state.amount.abs().toStringAsFixed(2)}',
              ),
              if (state.desc.isNotEmpty) _infoRow(theme, 'Note', state.desc),
              if (state.tag != null) _infoRow(theme, 'Tag', state.tag!),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        transactionBloc.add(RejectTransaction(state.txnId));
                        _sendAck(
                          context,
                          state.txnId,
                          'rejected',
                          state.viaTransport,
                        );
                        navigator.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                        side: BorderSide(color: colors.error),
                        foregroundColor: colors.error,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        navigator.pop();
                        transactionBloc.add(
                          AcceptTransaction(transactionId: state.txnId),
                        );
                        _sendAck(
                          context,
                          state.txnId,
                          'accepted',
                          state.viaTransport,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Labels no longer overflow horizontally on long sender names, notes, or
  // tags — label stays fixed-width, value wraps and truncates gracefully.
  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<DeepLinkBloc, DeepLinkState>(
          listener: (context, state) {
            if (state is TransactionReceived) {
              _showAcceptRejectSheet(context, state);
            }
            if (state is InviteHandled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.displayName} added as contact'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              context.read<UserBloc>().add(LoadAllUsers());
            }
            if (state is DeepLinkUnknownSender) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Unknown sender — ask them to share their invite link first',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is TransactionAckReceived) {
              final msg = state.outcome == 'rejected'
                  ? 'Transaction was rejected'
                  : 'Transaction was accepted';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<TransactionBloc>().add(LoadAllTransactions());
              context.read<BalanceBloc>().add(LoadAllBalances());
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 12),
              _buildBalanceCard(context),
              const SizedBox(height: 16),
              _buildFriendsGroupsTabs(context),
              const SizedBox(height: 8),
              // The tab bar above is driven by the same controller, so
              // switching tabs now actually switches the content.
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildBody(), _buildGroupsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              String? profilePicturePath;
              if (state is UserLoaded && _myAddress != null) {
                final matches = state.users.where(
                  (u) => u.publicKey == _myAddress,
                );
                if (matches.isNotEmpty) {
                  profilePicturePath = matches.first.profilePicture;
                }
              }

              // Kick off the async existence check here instead of calling
              // existsSync() inline — doesn't block this build, and only
              // re-checks disk when the path actually changes.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshProfilePicture(profilePicturePath);
              });

              final hasImage =
                  _profilePictureExists &&
                  profilePicturePath == _profilePicturePath;

              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.15,
                  ),
                  backgroundImage: hasImage
                      ? FileImage(File(profilePicturePath!))
                      : null,
                  child: !hasImage
                      ? Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 24,
                        )
                      : null,
                ),
              );
            },
          ),
          Row(
            children: [
              BlocBuilder<NfcBloc, NfcState>(
                builder: (context, nfcState) {
                  return IconButton(
                    onPressed: nfcState.isBusy
                        ? null
                        : () =>
                              context.read<NfcBloc>().add(NfcStartListening()),
                    icon: nfcState.isBusy
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Icon(
                            Icons.nfc_rounded,
                            color: theme.colorScheme.onSurface,
                            size: 26,
                          ),
                  );
                },
              ),
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.qrScanner),
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: theme.colorScheme.onSurface,
                  size: 26,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onSurface,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final hasFriends = _hasFriends(userState);

        return BlocBuilder<BalanceBloc, BalanceState>(
          builder: (context, balanceState) {
            int totalPaise = 0;
            if (balanceState is BalanceLoaded) {
              totalPaise = balanceState.balances.fold(
                0,
                (sum, b) => sum + b.netAmount,
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BalanceSummaryCard(
                total: totalPaise,
                showAnalyticsButton: hasFriends,
                onAnalyticsTap: () =>
                    Navigator.pushNamed(context, AppRoutes.analytics),
              ),
            );
          },
        );
      },
    );
  }

  bool _hasFriends(UserState state) {
    if (state is! UserLoaded || _myAddress == null) return false;
    return state.users.any((u) => u.publicKey != _myAddress);
  }

  Widget _buildFriendsGroupsTabs(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            // theme.cardColor tracks light/dark correctly, unlike the
            // hardcoded Colors.white this used to be.
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.24 : 0.08,
                ),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: colors.onSurface,
          unselectedLabelColor: theme.textTheme.bodySmall?.color,
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final colors = Theme.of(context).colorScheme;

    if (_myAddress == null) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        return BlocBuilder<BalanceBloc, BalanceState>(
          builder: (context, balanceState) {
            if (userState is UserLoading || balanceState is BalanceLoading) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            if (userState is UserError) return _buildError(userState.message);

            if (userState is UserLoaded && balanceState is BalanceLoaded) {
              final matchingUsers = userState.users
                  .where((u) => u.publicKey == _myAddress)
                  .toList();

              if (matchingUsers.isEmpty) return _buildEmptyState(null);

              final currentUser = matchingUsers.first;

              final friends = userState.users
                  .where((u) => u.publicKey != currentUser.publicKey)
                  .toList();

              if (friends.isEmpty) {
                return _buildEmptyState(currentUser.publicKey);
              }

              return FriendsList(
                users: friends,
                balances: balanceState.balances,
                currentUserPublicKey: currentUser.publicKey,
                onAddFriend: () =>
                    Navigator.pushNamed(context, AppRoutes.addExpense),
              );
            }

            return _buildEmptyState(null);
          },
        );
      },
    );
  }

  /// The Groups tab: every group stored on this device. Groups are local
  /// only and never synced to friends.
  Widget _buildGroupsTab() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return Center(
            child: CircularProgressIndicator(color: colors.primary),
          );
        }

        if (state is GroupError) return _buildError(state.message);

        if (state is GroupLoaded) {
          if (state.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 72,
                    color: colors.primary.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No groups yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openManageGroups,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Create a group',
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
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: state.groups.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              if (i == state.groups.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _openManageGroups,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Manage groups'),
                  ),
                );
              }

              final group = state.groups[i];
              final initial = group.name.isNotEmpty
                  ? group.name[0].toUpperCase()
                  : '?';
              final count = group.users.length;
              final description = group.description;

              return Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.primary.withValues(alpha: 0.15),
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (description != null && description.isNotEmpty)
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        '$count ${count == 1 ? 'member' : 'members'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // GroupInitial: nothing loaded yet.
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(String? userPublicKey) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: Image.asset(
                'assets/images/homescreen.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.receipt_long_outlined,
                  size: 100,
                  color: colors.primary.withValues(alpha: 0.25),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Expenses Found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addExpense);
              },
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
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Error: $message',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
