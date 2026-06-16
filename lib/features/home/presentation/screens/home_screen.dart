import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/nav_bar.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/filter_expenses_usecase.dart';
import '../bloc/expenses/expenses_bloc.dart';
import '../bloc/groups/groups_bloc.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/expenses_section.dart';
import '../widgets/groups_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const repository = HomeRepositoryImpl();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(
          create: (_) =>
              ExpensesBloc(repository, const FilterExpensesUseCase())
                ..add(ExpensesStarted()),
        ),
        BlocProvider(
          create: (_) => GroupsBloc(repository)..add(GroupsStarted()),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.sizeOf(context).width >= Responsive.tabletBreakpoint;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    const _HomeAppBar(),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final bottomInset = MediaQuery.of(
                            context,
                          ).padding.bottom;
                          final navPad =
                              Responsive.dp(114, constraints) + bottomInset;

                          if (isTablet) {
                            const double sidePad = 20;
                            final contentW = constraints.maxWidth - sidePad * 2;
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                sidePad,
                                Responsive.dp(16, constraints),
                                sidePad,
                                0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: contentW * 0.38,
                                    child: const _BalanceSummaryCard(),
                                  ),
                                  SizedBox(
                                    width: Responsive.dp(20, constraints),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.only(bottom: navPad),
                                      child: _ToggleAndContent(state: state),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final hPad = Responsive.horizontalPadding(context);
                          return SingleChildScrollView(
                            padding: hPad.copyWith(top: 8, bottom: navPad),
                            child: Column(
                              children: [
                                const _BalanceSummaryCard(),
                                SizedBox(
                                  height: Responsive.dp(20, constraints),
                                ),
                                _ToggleAndContent(state: state),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppNavBar(
                  currentIndex: 0,
                  onTap: (_) {},
                  onAddExpense: () {},
                  compact: isTablet,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleAndContent extends StatelessWidget {
  final HomeState state;
  const _ToggleAndContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FriendsGroupsToggle(
            selectedIndex: state.selectedIndex,
            onToggle: (index) =>
                context.read<HomeBloc>().add(HomeTabSelected(index)),
          ),
          SizedBox(height: Responsive.dp(16, constraints)),
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                final goingForward = state.selectedIndex > state.previousIndex;
                final isIncoming =
                    (child.key == const ValueKey(0) &&
                        state.selectedIndex == 0) ||
                    (child.key == const ValueKey(1) &&
                        state.selectedIndex == 1);
                final begin = isIncoming
                    ? (goingForward
                          ? const Offset(1.0, 0.0)
                          : const Offset(-1.0, 0.0))
                    : (goingForward
                          ? const Offset(-1.0, 0.0)
                          : const Offset(1.0, 0.0));
                return SlideTransition(
                  position: Tween<Offset>(begin: begin, end: Offset.zero)
                      .animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              child: state.selectedIndex == 0
                  ? const ExpensesSection(key: ValueKey(0))
                  : const GroupsSection(key: ValueKey(1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.sizeOf(context).width >= Responsive.tabletBreakpoint;
    final hPadding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 20)
        : Responsive.horizontalPadding(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final avatarRadius = Responsive.dp(20, constraints);
        final iconSize = Responsive.dp(26, constraints);
        final titleSize = Responsive.sp(20, constraints);
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: hPadding.copyWith(top: 12, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(hPadding.horizontal / 2),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: const Color(0xFF8D7B6E),
                  child: Icon(Icons.person, color: cs.surface, size: iconSize),
                ),
              ),
              Text(
                'Home',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(hPadding.horizontal / 2),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: cs.onSurface,
                    size: iconSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceSummaryCard extends StatelessWidget {
  const _BalanceSummaryCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final amountSize = Responsive.sp(38, constraints);
        final labelSize = Responsive.sp(14, constraints);
        final iconSize = Responsive.dp(28, constraints);
        final arrowSize = Responsive.dp(26, constraints);
        final vPad = Responsive.dp(20, constraints);
        final bPad = Responsive.dp(24, constraints);
        final hPad = Responsive.dp(20, constraints);
        final expState = context.watch<ExpensesBloc>().state;
        final balance = expState is ExpensesSuccess
            ? expState.totalBalance
            : 0.0;
        final cs = Theme.of(context).colorScheme;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, bPad),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    balance > 0
                        ? 'You are owed'
                        : balance < 0
                        ? 'You owe'
                        : 'Total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: labelSize,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: Responsive.dp(3, constraints)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${balance.abs().toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: amountSize,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      if (balance != 0)
                        Icon(
                          balance > 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: balance > 0
                              ? AppColors.primary
                              : AppColors.negativeAmount,
                          size: arrowSize,
                        ),
                    ],
                  ),
                ],
              ),
              if (expState is ExpensesSuccess && expState.expenses.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.primary,
                    size: iconSize,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FriendsGroupsToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onToggle;

  const _FriendsGroupsToggle({
    required this.selectedIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = Responsive.dp(50, constraints);
        final fontSize = Responsive.sp(15, constraints);
        final cs = Theme.of(context).colorScheme;
        return Container(
          height: height,
          padding: EdgeInsets.all(Responsive.dp(4, constraints)),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: selectedIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(Responsive.dp(8, constraints)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.5,
                    heightFactor: 1.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onToggle(0),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: selectedIndex == 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selectedIndex == 0
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                          ),
                          child: const Text('Friends'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onToggle(1),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: selectedIndex == 1
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selectedIndex == 1
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                          ),
                          child: const Text('Groups'),
                        ),
                      ),
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
}
