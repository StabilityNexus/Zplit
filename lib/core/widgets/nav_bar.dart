import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/responsive.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAddExpense;
  final bool compact;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAddExpense,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pillHeight = Responsive.dp(compact ? 52 : 68, constraints);
        final buttonSize = Responsive.dp(compact ? 46 : 60, constraints);
        final bottomMargin = Responsive.dp(compact ? 12 : 16, constraints);
        final protrusion = buttonSize / 2;

        return SizedBox(
          height: protrusion + pillHeight + bottomMargin + bottomPadding,
          child: Stack(
            children: [
              Positioned(
                bottom: bottomMargin + bottomPadding,
                left: Responsive.dp(24, constraints),
                right: Responsive.dp(24, constraints),
                height: pillHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      Responsive.dp(40, constraints),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        index: 0,
                        currentIndex: currentIndex,
                        onTap: onTap,
                        cs: cs,
                        constraints: constraints,
                        compact: compact,
                      ),
                      _NavItem(
                        icon: Icons.group_outlined,
                        activeIcon: Icons.group_rounded,
                        index: 1,
                        currentIndex: currentIndex,
                        onTap: onTap,
                        cs: cs,
                        constraints: constraints,
                        compact: compact,
                      ),
                      const Expanded(child: SizedBox()),
                      _NavItem(
                        icon: Icons.notifications_outlined,
                        activeIcon: Icons.notifications_rounded,
                        index: 2,
                        currentIndex: currentIndex,
                        onTap: onTap,
                        cs: cs,
                        constraints: constraints,
                        compact: compact,
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        index: 3,
                        currentIndex: currentIndex,
                        onTap: onTap,
                        cs: cs,
                        constraints: constraints,
                        compact: compact,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: bottomMargin + bottomPadding + pillHeight - protrusion,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onAddExpense ?? () {},
                    child: Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: Responsive.dp(compact ? 22 : 28, constraints),
                      ),
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
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ColorScheme cs;
  final BoxConstraints constraints;
  final bool compact;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.cs,
    required this.constraints,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final circleSize = Responsive.dp(compact ? 36 : 48, constraints);
    final iconSize = Responsive.dp(compact ? 20 : 24, constraints);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: isActive ? cs.surface : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : cs.onSurfaceVariant,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
