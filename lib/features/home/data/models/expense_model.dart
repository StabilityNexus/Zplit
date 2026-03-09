import 'package:flutter/material.dart';

class ExpenseModel {
  final String title;
  final DateTime date;
  final double amount;
  final bool
  owesYou; // owesYou true = the other person owes you (shown in green), false = you owe them (shown in red).
  final Color avatarColor;
  final String avatarInitial;

  const ExpenseModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.owesYou,
    required this.avatarColor,
    required this.avatarInitial,
  });
}
