import 'package:flutter/material.dart';
import 'models/expense_model.dart';
import 'models/group_model.dart';

// Placeholder dummy data for UI development.
class HomeDummyData {
  HomeDummyData._();

  static final Map<String, List<ExpenseModel>> expenses = {
    'November 2025': [
      ExpenseModel(
        title: 'Ayush - Rent',
        date: DateTime(2025, 11, 10),
        amount: 2000,
        owesYou: false,
        avatarColor: const Color(0xFF5E97B7),
        avatarInitial: 'A',
      ),
      ExpenseModel(
        title: 'Kritika - Food',
        date: DateTime(2025, 11, 8),
        amount: 4200,
        owesYou: true,
        avatarColor: const Color(0xFFE88E8E),
        avatarInitial: 'K',
      ),
    ],
    'October 2025': [
      ExpenseModel(
        title: 'Arpita - Coffee',
        date: DateTime(2025, 10, 28),
        amount: 500,
        owesYou: false,
        avatarColor: const Color(0xFFC4A87B),
        avatarInitial: 'A',
      ),
      ExpenseModel(
        title: 'Akshat - Fuel',
        date: DateTime(2025, 10, 20),
        amount: 200,
        owesYou: false,
        avatarColor: const Color(0xFF8D7B6E),
        avatarInitial: 'A',
      ),
    ],
  };

  static double get totalBalance => expenses.values
      .expand((list) => list)
      .fold(
        0.0,
        (sum, e) => sum + (e.owesYou ? e.amount : -e.amount),
      ); //postive=you are owed, negative = you owe

  static final List<GroupModel> groups = [
    const GroupModel(
      name: 'Household',
      memberCount: 2,
      balance: 2000,
      isPositive: false,
      memberAvatarColors: [Color(0xFF8D7B6E), Color(0xFF5E97B7)],
    ),
    const GroupModel(
      name: 'Hiking Pals',
      memberCount: 4,
      balance: 3200,
      isPositive: true,
      memberAvatarColors: [
        Color(0xFF8D7B6E),
        Color(0xFF5E97B7),
        Color(0xFFE88E8E),
        Color(0xFF8BC34A),
      ],
    ),
    const GroupModel(
      name: 'Goa Trip 2025',
      memberCount: 5,
      balance: 3500,
      isPositive: true,
      memberAvatarColors: [
        Color(0xFF5E97B7),
        Color(0xFF8D7B6E),
        Color(0xFFE88E8E),
        Color(0xFF8BC34A),
      ],
    ),
  ];
}
