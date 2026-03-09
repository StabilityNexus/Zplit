import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/groups/groups_bloc.dart';
import 'group_card.dart';

class GroupsSection extends StatelessWidget {
  const GroupsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        final groups = state is GroupsSuccess ? state.groups : const [];

        return LayoutBuilder(
          builder: (context, constraints) {
            final titleSize = Responsive.sp(18, constraints);
            final iconSize = Responsive.dp(24, constraints);
            final gap = Responsive.dp(12, constraints);
            final cs = Theme.of(context).colorScheme;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Group expenses',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.group_add_outlined,
                            color: AppColors.primary,
                            size: iconSize,
                          ),
                        ),
                        SizedBox(width: Responsive.dp(12, constraints)),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.qr_code_2_outlined,
                            color: AppColors.primary,
                            size: iconSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: gap),
                ...groups.map(
                  (g) => Padding(
                    padding: EdgeInsets.only(bottom: gap),
                    child: GroupCard(data: g),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
