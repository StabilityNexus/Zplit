import 'package:flutter/material.dart';
import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/routing/App_router.dart';

class FriendTile extends StatelessWidget {
  static const Color _positiveColor = Color(0xFF16A34A);

  final UserModel user;
  final BalanceModel? balance;
  final String currentUserPublicKey;

  const FriendTile({
    super.key,
    required this.user,
    required this.balance,
    required this.currentUserPublicKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final amount = balance?.netAmount ?? 0;
    final isPositive = amount >= 0;
    final currency = balance?.currency ?? '₹';

    final amountColor = amount == 0
        ? theme.textTheme.bodySmall?.color
        : isPositive
        ? _positiveColor
        : colors.error;

    final oweLabel = amount == 0
        ? 'Settled up'
        : isPositive
        ? 'Owes you:'
        : 'You owe:';

    final amountLabel = amount == 0 ? '' : '$currency${amount.abs()}';

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.friendDetail,
          arguments: {
            'friend': user,
            'balance': balance,
            'currentUserPublicKey': currentUserPublicKey,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.primary.withOpacity(0.12),
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: user.profilePicture == null
                  ? Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Name + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (balance != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(balance!.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  oweLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: amountColor,
                    fontSize: 11,
                  ),
                ),
                if (amountLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    amountLabel,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_shortMonth(date.month)}';
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
