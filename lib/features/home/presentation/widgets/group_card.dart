import 'package:flutter/material.dart';
import 'package:zplit/core/utils/responsive.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/group_model.dart';

export '../../data/models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel data;

  const GroupCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleSize = Responsive.sp(16, constraints);
        final labelSize = Responsive.sp(12, constraints);
        final amountSize = Responsive.sp(22, constraints);
        final avatarRadius = Responsive.dp(20, constraints);
        final overlap = Responsive.dp(12, constraints);
        final pad = Responsive.dp(16, constraints);
        final moreIconSize = Responsive.dp(20, constraints);
        final cs = Theme.of(context).colorScheme;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(pad),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StackedAvatars(
                    colors: data.memberAvatarColors,
                    radius: avatarRadius,
                    overlap: overlap,
                  ),
                  SizedBox(width: Responsive.dp(12, constraints)),
                  Expanded(
                    child: Text(
                      data.name,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.more_vert,
                    color: cs.onSurfaceVariant,
                    size: moreIconSize,
                  ),
                ],
              ),
              SizedBox(height: Responsive.dp(14, constraints)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.isPositive ? 'you are owed:' : 'you owe:',
                        style: TextStyle(
                          fontSize: labelSize,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: Responsive.dp(2, constraints)),
                      Text(
                        '₹${data.balance.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: amountSize,
                          fontWeight: FontWeight.bold,
                          color: data.isPositive
                              ? AppColors.positiveAmount
                              : AppColors.negativeAmount,
                        ),
                      ),
                    ],
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

class _StackedAvatars extends StatelessWidget {
  final List<Color> colors;
  final double radius;
  final double overlap;

  const _StackedAvatars({
    required this.colors,
    required this.radius,
    required this.overlap,
  });

  @override
  Widget build(BuildContext context) {
    final count = colors.length.clamp(1, 4);
    final diameter = radius * 2;
    final totalWidth = diameter + (count - 1) * (diameter - overlap);
    return SizedBox(
      width: totalWidth,
      height: diameter,
      child: Stack(
        children: List.generate(count, (i) {
          return Positioned(
            left: i * (diameter - overlap),
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: colors[i % colors.length],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
