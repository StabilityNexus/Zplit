import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/expense_filter.dart';
import '../bloc/expenses/expenses_bloc.dart';
import 'expense_tile.dart';
import 'filter_bottom_sheet.dart';

class ExpensesSection extends StatelessWidget {
  const ExpensesSection({super.key});

  void _showFilterSheet(BuildContext context) async {
    final filter = await showModalBottomSheet<ExpenseFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const FilterBottomSheet(),
    );
    if (filter != null && context.mounted) {
      context.read<ExpensesBloc>().add(ExpensesFilterApplied(filter));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesBloc, ExpensesState>(
      builder: (context, state) {
        final expenses = state is ExpensesSuccess
            ? state.expenses
            : <String, List<ExpenseModel>>{};
        final isFiltered =
            state is ExpensesSuccess && state.activeFilter.isActive;
        return LayoutBuilder(
          builder: (context, constraints) {
            final titleSize = Responsive.sp(18, constraints);
            final iconSize = Responsive.dp(24, constraints);
            final gap = Responsive.dp(10, constraints);
            final cs = Theme.of(context).colorScheme;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expenses',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showFilterSheet(context),
                      child: Icon(
                        isFiltered ? Icons.tune_rounded : Icons.tune,
                        color: isFiltered
                            ? AppColors.primary
                            : cs.onSurfaceVariant,
                        size: iconSize,
                      ),
                    ),
                  ],
                ),
                if (isFiltered) ...[
                  SizedBox(height: Responsive.dp(8, constraints)),
                  GestureDetector(
                    onTap: () => context.read<ExpensesBloc>().add(
                      ExpensesFilterApplied(ExpenseFilter.empty),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.dp(10, constraints),
                        vertical: Responsive.dp(5, constraints),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(
                          Responsive.dp(20, constraints),
                        ),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(80),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filters applied',
                            style: TextStyle(
                              fontSize: Responsive.sp(12, constraints),
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: Responsive.dp(6, constraints)),
                          Icon(
                            Icons.close_rounded,
                            size: Responsive.dp(14, constraints),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: gap),
                if (expenses.isEmpty)
                  Center(child: _EmptyState(constraints: constraints))
                else
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.dp(16, constraints),
                      vertical: Responsive.dp(8, constraints),
                    ),
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
                        ...expenses.entries.map(
                          (entry) => _MonthGroup(
                            month: entry.key,
                            expenses: entry.value,
                          ),
                        ),
                      ],
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

class _MonthGroup extends StatelessWidget {
  final String month;
  final List<ExpenseModel> expenses;

  const _MonthGroup({required this.month, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Responsive.dp(8, constraints),
              ),
              child: Text(
                month,
                style: TextStyle(
                  fontSize: Responsive.sp(13, constraints),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ...expenses.map((e) => ExpenseTile(data: e)),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final BoxConstraints constraints;
  const _EmptyState({required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.dp(22, constraints)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/home_emptystate.png',
            width: Responsive.dp(220, constraints),
          ),
          Text(
            'No Expenses Found',
            style: TextStyle(
              fontSize: Responsive.sp(16, constraints),
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
