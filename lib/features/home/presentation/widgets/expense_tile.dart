import 'package:flutter/material.dart';
import 'package:zplit/core/utils/responsive.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/models/expense_model.dart';

export '../../data/models/expense_model.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel data;

  const ExpenseTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final avatarRadius = Responsive.dp(28, constraints);
        final avatarFontSize = Responsive.sp(18, constraints);
        final titleSize = Responsive.sp(16, constraints);
        final dateSize = Responsive.sp(13, constraints);
        final labelSize = Responsive.sp(12, constraints);
        final amountSize = Responsive.sp(20, constraints);
        final gap = Responsive.dp(14, constraints);
        final vPad = Responsive.dp(8, constraints);
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: vPad),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: data.avatarColor,
                child: Text(
                  data.avatarInitial,
                  style: TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: avatarFontSize,
                  ),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: Responsive.dp(3, constraints)),
                    Text(
                      formatDateShort(data.date),
                      style: TextStyle(
                        fontSize: dateSize,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.owesYou ? 'Owes you:' : 'You owe:',
                    style: TextStyle(
                      fontSize: labelSize,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: Responsive.dp(2, constraints)),
                  Text(
                    '₹${data.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: amountSize,
                      fontWeight: FontWeight.bold,
                      color: data.owesYou
                          ? AppColors.positiveAmount
                          : AppColors.negativeAmount,
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
