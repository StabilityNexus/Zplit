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

  String _formatAmount(int minorUnits) {
    final rupees = minorUnits ~/ 100;
    final paise = minorUnits % 100;

    final digits = rupees.toString();
    final buffer = StringBuffer();
    final len = digits.length;
    for (int i = 0; i < len; i++) {
      final posFromEnd = len - i;
      buffer.write(digits[i]);
      final isLast = posFromEnd == 1;
      if (!isLast &&
          (posFromEnd == 4 || (posFromEnd > 4 && (posFromEnd - 4) % 2 == 0))) {
        buffer.write(',');
      }
    }
    buffer.write('.');
    buffer.write(paise.toString().padLeft(2, '0'));
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPositive = total > 0;
    final isSettled = total == 0;

    final label = isSettled
        ? 'Total'
        : isPositive
        ? 'You are owed'
        : 'You owe';

    final amountColor = isSettled
        ? theme.textTheme.displayLarge?.color
        : isPositive
        ? colors.primary
        : colors.error;

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
                  color: colors.primary,
                  size: 22,
                ),
              ),
            ),
          Text(
            label,

            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '₹${_formatAmount(total.abs())}',

                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 40,
                    color: amountColor,
                  ),
                ),
                if (!isSettled) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: amountColor,
                    size: 26,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
