class ExpenseFilter {
  final bool? owesYou; // null = no filter, true = they owe you, false = you owe
  final DateTime? fromDate;
  final DateTime? toDate;
  final double? minAmount;
  final double? maxAmount;

  const ExpenseFilter({
    this.owesYou,
    this.fromDate,
    this.toDate,
    this.minAmount,
    this.maxAmount,
  });

  static const empty = ExpenseFilter();

  bool get isActive =>
      owesYou != null ||
      fromDate != null ||
      toDate != null ||
      (minAmount != null && minAmount! > 0) ||
      (maxAmount != null && maxAmount! < 5000);
}
