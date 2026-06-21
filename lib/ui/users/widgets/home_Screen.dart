import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/balance/view_model/balance_bloc.dart';
import 'package:zplit/ui/balance/view_model/balance_event.dart';
import 'package:zplit/ui/balance/view_model/balance_state.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';
import 'package:zplit/ui/users/widgets/Homebottomnav.dart';
import 'package:zplit/ui/transaction/widgets/balance_card.dart';
import 'package:zplit/ui/users/widgets/friendlist.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavIndex = 0;
  String? _myAddress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    FlutterSecureStorage().read(key: 'evm_address').then((addr) {
      if (mounted) setState(() => _myAddress = addr);
    });

    context.read<UserBloc>().add(LoadAllUsers());
    context.read<BalanceBloc>().add(LoadAllBalances());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: HomeBottomNav(
          selectedIndex: _selectedNavIndex,
          onTap: (index) => setState(() => _selectedNavIndex = index),
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
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 24,
              ),
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
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final hasFriends = _hasFriends(userState);

        return BlocBuilder<BalanceBloc, BalanceState>(
          builder: (context, balanceState) {
            int total = 0;
            if (balanceState is BalanceLoaded) {
              total = balanceState.balances.fold(
                0,
                (sum, b) => sum + b.netAmount,
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BalanceSummaryCard(
                total: total,
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
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
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

    // Wait for address to load from secure storage
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
              // Try to find current user by address
              final matchingUsers = userState.users
                  .where((u) => u.publicKey == _myAddress)
                  .toList();

              // No current user found at all → empty state
              if (matchingUsers.isEmpty) {
                return _buildEmptyState(null);
              }

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

  Widget _buildEmptyState(String? userPublicKey) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            child: Image.asset(
              'assets/images/homescreen.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.receipt_long_outlined,
                size: 100,
                color: colors.primary.withOpacity(0.25),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Expenses Found',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ),
        ],
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
