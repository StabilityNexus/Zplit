import 'package:flutter/material.dart';

class BalanceSummaryCard extends StatelessWidget {
  final int total;
  final bool showAnalyticsButton;
  final VoidCallback onAnalyticsTap;

  const BalanceSummaryCard({
    super.key,
    required this.total,
    required this.showAnalyticsButton,
    required this.onAnalyticsTap,
  });

  static const _positiveColor = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = total > 0;
    final isSettled = total == 0;

    final label = isSettled
        ? "You're all settled up"
        : isPositive
        ? 'You are owed'
        : 'You owe';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 16, 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          if (showAnalyticsButton)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onAnalyticsTap,
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: _positiveColor,
                  size: 22,
                ),
              ),
            ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          if (isSettled)
            Text(
              'Settled',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${total.abs()}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isPositive ? _positiveColor : theme.colorScheme.error,
                  size: 26,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
