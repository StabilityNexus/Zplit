import 'package:flutter/material.dart';
import 'package:zplit/domain/models/balance/balance_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/users/widgets/friendtile.dart';

class FriendsList extends StatefulWidget {
  final List<UserModel> users;
  final List<BalanceModel> balances;
  final String currentUserPublicKey;
  final VoidCallback onAddFriend;

  const FriendsList({
    super.key,
    required this.users,
    required this.balances,
    required this.currentUserPublicKey,
    required this.onAddFriend,
  });

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  String _quickFilter = '';
  String _dateFilter = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  double _amountFrom = 0;
  double _amountTo = 5000;

  String _monthLabel(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(
        quickFilter: _quickFilter,
        dateFilter: _dateFilter,
        fromDate: _fromDate,
        toDate: _toDate,
        amountFrom: _amountFrom,
        amountTo: _amountTo,
        onApply:
            (quickFilter, dateFilter, fromDate, toDate, amountFrom, amountTo) {
              setState(() {
                _quickFilter = quickFilter;
                _dateFilter = dateFilter;
                _fromDate = fromDate;
                _toDate = toDate;
                _amountFrom = amountFrom;
                _amountTo = amountTo;
              });
            },
      ),
    );
  }

  List<UserModel> _applyFilters(
    List<UserModel> users,
    Map<String, BalanceModel> balanceMap,
  ) {
    return users.where((user) {
      final balance = balanceMap[user.publicKey];

      final amountInRupees = (balance?.netAmount ?? 0) / 100.0;

      if (_quickFilter == 'owe' && amountInRupees >= 0) return false;
      if (_quickFilter == 'owed' && amountInRupees <= 0) return false;
      if (amountInRupees.abs() < _amountFrom ||
          amountInRupees.abs() > _amountTo) {
        return false;
      }

      if (balance != null && _dateFilter.isNotEmpty) {
        final now = DateTime.now();
        if (_dateFilter == 'last14' &&
            balance.updatedAt.isBefore(now.subtract(const Duration(days: 14))))
          return false;
        if (_dateFilter == 'last30' &&
            balance.updatedAt.isBefore(now.subtract(const Duration(days: 30))))
          return false;
        if (_dateFilter == 'last60' &&
            balance.updatedAt.isBefore(now.subtract(const Duration(days: 60))))
          return false;
        if (_dateFilter == 'custom' && _fromDate != null && _toDate != null) {
          if (balance.updatedAt.isBefore(_fromDate!) ||
              balance.updatedAt.isAfter(_toDate!))
            return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final balanceMap = {
      for (var balance in widget.balances) balance.userPublicKey: balance,
    };

    final filteredUsers = _applyFilters(widget.users, balanceMap);

    final Map<String, List<UserModel>> grouped = {};
    for (final user in filteredUsers) {
      final balance = balanceMap[user.publicKey];
      final label = balance != null
          ? _monthLabel(balance.updatedAt)
          : 'No activity';
      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(user);
    }

    final filtersActive =
        _quickFilter.isNotEmpty ||
        _dateFilter.isNotEmpty ||
        _amountFrom != 0 ||
        _amountTo != 5000;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expenses',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Icon(
                      Icons.tune,
                      color: filtersActive
                          ? colors.primary
                          : colors.primary.withOpacity(0.6),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            if (filteredUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        filtersActive
                            ? 'No results match your filters.'
                            : 'No expenses yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.45),
                        ),
                      ),
                      if (filtersActive) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _quickFilter = '';
                              _dateFilter = '';
                              _fromDate = null;
                              _toDate = null;
                              _amountFrom = 0;
                              _amountTo = 5000;
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              ...grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        entry.key,
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.5,
                          color: theme.colorScheme.onSurface.withOpacity(0.45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ...entry.value.map(
                      (user) => FriendTile(
                        user: user,
                        balance: balanceMap[user.publicKey],
                        currentUserPublicKey: widget.currentUserPublicKey,
                      ),
                    ),
                  ],
                );
              }),
          ],
        ),

        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: widget.onAddFriend,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add An Expense',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
                elevation: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String quickFilter;
  final String dateFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double amountFrom;
  final double amountTo;
  final Function(String, String, DateTime?, DateTime?, double, double) onApply;

  const _FilterSheet({
    required this.quickFilter,
    required this.dateFilter,
    required this.fromDate,
    required this.toDate,
    required this.amountFrom,
    required this.amountTo,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _quickFilter;
  late String _dateFilter;
  late DateTime? _fromDate;
  late DateTime? _toDate;
  late double _amountFrom;
  late double _amountTo;

  final _fromAmountController = TextEditingController();
  final _toAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quickFilter = widget.quickFilter;
    _dateFilter = widget.dateFilter;
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    _amountFrom = widget.amountFrom;
    _amountTo = widget.amountTo;
    _fromAmountController.text = _amountFrom.toStringAsFixed(2);
    _toAmountController.text = _amountTo.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _fromAmountController.dispose();
    _toAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null)
      setState(() {
        if (isFrom)
          _fromDate = picked;
        else
          _toDate = picked;
      });
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Quick Filters',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _chip(
                    theme,
                    'You owe them',
                    _quickFilter == 'owe',
                    () => setState(
                      () => _quickFilter = _quickFilter == 'owe' ? '' : 'owe',
                    ),
                  ),
                  const SizedBox(width: 10),
                  _chip(
                    theme,
                    'They owe you',
                    _quickFilter == 'owed',
                    () => setState(
                      () => _quickFilter = _quickFilter == 'owed' ? '' : 'owed',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                'Date Range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    theme,
                    'Last 14 days',
                    _dateFilter == 'last14',
                    () => setState(
                      () =>
                          _dateFilter = _dateFilter == 'last14' ? '' : 'last14',
                    ),
                  ),
                  _chip(
                    theme,
                    'Last 30 days',
                    _dateFilter == 'last30',
                    () => setState(
                      () =>
                          _dateFilter = _dateFilter == 'last30' ? '' : 'last30',
                    ),
                  ),
                  _chip(
                    theme,
                    'Last 60 days',
                    _dateFilter == 'last60',
                    () => setState(
                      () =>
                          _dateFilter = _dateFilter == 'last60' ? '' : 'last60',
                    ),
                  ),
                  _chip(
                    theme,
                    'Custom date range',
                    _dateFilter == 'custom',
                    () => setState(
                      () =>
                          _dateFilter = _dateFilter == 'custom' ? '' : 'custom',
                    ),
                  ),
                ],
              ),

              if (_dateFilter == 'custom') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _datePicker(
                        theme,
                        'From',
                        _fromDate,
                        () => _pickDate(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _datePicker(
                        theme,
                        'To',
                        _toDate,
                        () => _pickDate(false),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),
              Text(
                'Amount Range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _amountField(
                      theme,
                      'From',
                      _fromAmountController,
                      (v) => _amountFrom = double.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _amountField(
                      theme,
                      'To',
                      _toAmountController,
                      (v) => _amountTo = double.tryParse(v) ?? 5000,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onApply('', '', null, null, 0, 5000);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          _quickFilter,
                          _dateFilter,
                          _fromDate,
                          _toDate,
                          _amountFrom,
                          _amountTo,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    ThemeData theme,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final colors = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          border: Border.all(
            color: selected ? colors.primary : theme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: selected
                ? Colors.white
                : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _datePicker(
    ThemeData theme,
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? _formatDate(date) : 'Select',
                  style: theme.textTheme.bodyMedium,
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixText: '₹ ',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
          ),
        ),
      ],
    );
  }
}
