import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/expense_filter.dart';
import '../../../../core/utils/date_utils.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int? _quickFilterIndex; // 0 = You owe them, 1 = They owe you
  int? _dateRangeIndex;
  DateTime? _fromDate;
  DateTime? _toDate;
  final _amountFromCtrl = TextEditingController();
  final _amountToCtrl = TextEditingController();
  bool get _customDateSelected => _dateRangeIndex == 3;

  @override
  void dispose() {
    _amountFromCtrl.dispose();
    _amountToCtrl.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _quickFilterIndex = null;
      _dateRangeIndex = null;
      _fromDate = null;
      _toDate = null;
      _amountFromCtrl.clear();
      _amountToCtrl.clear();
    });
  }

  ExpenseFilter _buildFilter() {
    final now = DateTime.now();
    DateTime? fromDate = switch (_dateRangeIndex) {
      0 => now.subtract(const Duration(days: 14)),
      1 => now.subtract(const Duration(days: 30)),
      2 => now.subtract(const Duration(days: 60)),
      3 => _fromDate,
      _ => null,
    };
    final toDate = _dateRangeIndex == 3 ? _toDate : null;
    final minAmount = double.tryParse(_amountFromCtrl.text);
    final maxAmount = double.tryParse(_amountToCtrl.text);
    return ExpenseFilter(
      owesYou: _quickFilterIndex == null
          ? null
          : _quickFilterIndex == 1, // 1 = they owe you, 0 = you owe
      fromDate: fromDate,
      toDate: toDate,
      minAmount: minAmount,
      maxAmount: maxAmount,
    );
  }

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final initial = isFrom
        ? (_fromDate ?? now.subtract(const Duration(days: 7)))
        : (_toDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: DatePickerThemeData(
            todayForegroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? Colors.white : null,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Padding(
              padding: EdgeInsets.only(
                top: Responsive.dp(12, constraints),
                bottom: Responsive.dp(4, constraints),
              ),
              child: Center(
                child: Container(
                  width: Responsive.dp(40, constraints),
                  height: Responsive.dp(4, constraints),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withAlpha(80),
                    borderRadius: BorderRadius.circular(
                      Responsive.dp(2, constraints),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hPad = Responsive.dp(20, constraints);
                final cs = Theme.of(context).colorScheme;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    Responsive.dp(8, constraints),
                    hPad,
                    MediaQuery.of(context).viewInsets.bottom +
                        Responsive.dp(32, constraints),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: Responsive.sp(18, constraints),
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.dp(14, constraints)),
                      const _SectionLabel('Quick Filters'),
                      SizedBox(height: Responsive.dp(9, constraints)),
                      Wrap(
                        spacing: 7,
                        runSpacing: 10,
                        children: [
                          _Chip(
                            label: 'You owe them',
                            selected: _quickFilterIndex == 0,
                            onTap: () => setState(
                              () => _quickFilterIndex = _quickFilterIndex == 0
                                  ? null
                                  : 0,
                            ),
                          ),
                          _Chip(
                            label: 'They owe you',
                            selected: _quickFilterIndex == 1,
                            onTap: () => setState(
                              () => _quickFilterIndex = _quickFilterIndex == 1
                                  ? null
                                  : 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.dp(24, constraints)),
                      const _SectionLabel('Date Range'),
                      SizedBox(height: Responsive.dp(12, constraints)),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _Chip(
                            label: 'Last 14 days',
                            selected: _dateRangeIndex == 0,
                            onTap: () => setState(
                              () => _dateRangeIndex = _dateRangeIndex == 0
                                  ? null
                                  : 0,
                            ),
                          ),
                          _Chip(
                            label: 'Last 30 days',
                            selected: _dateRangeIndex == 1,
                            onTap: () => setState(
                              () => _dateRangeIndex = _dateRangeIndex == 1
                                  ? null
                                  : 1,
                            ),
                          ),
                          _Chip(
                            label: 'Last 60 days',
                            selected: _dateRangeIndex == 2,
                            onTap: () => setState(
                              () => _dateRangeIndex = _dateRangeIndex == 2
                                  ? null
                                  : 2,
                            ),
                          ),
                          _Chip(
                            label: 'Custom date range',
                            selected: _customDateSelected,
                            onTap: () => setState(
                              () => _dateRangeIndex = _customDateSelected
                                  ? null
                                  : 3,
                            ),
                          ),
                        ],
                      ),
                      if (_customDateSelected) ...[
                        SizedBox(height: Responsive.dp(16, constraints)),
                        Row(
                          children: [
                            Expanded(
                              child: _DatePickerField(
                                label: 'From',
                                value: _fromDate != null
                                    ? formatDateLong(_fromDate!)
                                    : formatDateLong(
                                        DateTime.now().subtract(
                                          const Duration(days: 7),
                                        ),
                                      ),
                                onTap: () => _pickDate(true),
                              ),
                            ),
                            SizedBox(width: Responsive.dp(12, constraints)),
                            Expanded(
                              child: _DatePickerField(
                                label: 'To',
                                value: _toDate != null
                                    ? formatDateLong(_toDate!)
                                    : formatDateLong(DateTime.now()),
                                onTap: () => _pickDate(false),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: Responsive.dp(24, constraints)),
                      const _SectionLabel('Amount Range'),
                      SizedBox(height: Responsive.dp(12, constraints)),
                      Row(
                        children: [
                          Expanded(
                            child: _AmountField(
                              label: 'From',
                              hint: '0.00',
                              controller: _amountFromCtrl,
                            ),
                          ),
                          SizedBox(width: Responsive.dp(12, constraints)),
                          Expanded(
                            child: _AmountField(
                              label: 'To',
                              hint: '5000.00',
                              controller: _amountToCtrl,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.dp(32, constraints)),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: Responsive.dp(52, constraints),
                              child: ElevatedButton(
                                onPressed: _clearAll,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFBDBDBD),
                                ),
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(16, constraints),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.dp(12, constraints)),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: Responsive.dp(52, constraints),
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, _buildFilter()),
                                child: Text(
                                  'Apply Filters',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(16, constraints),
                                    fontWeight: FontWeight.w600,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Text(
        text,
        style: TextStyle(
          fontSize: Responsive.sp(16, constraints),
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cs = Theme.of(context).colorScheme;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.dp(10, constraints),
              vertical: Responsive.dp(6, constraints),
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withAlpha(20) : cs.surface,
              border: Border.all(
                color: selected ? AppColors.primary : cs.outlineVariant,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(
                Responsive.dp(24, constraints),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(14, constraints),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.primary : cs.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cs = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(12, constraints),
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: Responsive.dp(6, constraints)),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.dp(14, constraints),
                  vertical: Responsive.dp(11, constraints),
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(
                    Responsive.dp(25, constraints),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: Responsive.sp(13, constraints),
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: Responsive.dp(20, constraints),
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AmountField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _AmountField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cs = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(13, constraints),
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: Responsive.dp(6, constraints)),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(
                  Responsive.dp(25, constraints),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: Responsive.dp(14, constraints),
                    ),
                    child: Text(
                      '₹',
                      style: TextStyle(
                        fontSize: Responsive.sp(15, constraints),
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      style: TextStyle(
                        fontSize: Responsive.sp(14, constraints),
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: TextStyle(
                          fontSize: Responsive.sp(14, constraints),
                          color: cs.onSurfaceVariant,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: Responsive.dp(8, constraints),
                          vertical: Responsive.dp(10, constraints),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
