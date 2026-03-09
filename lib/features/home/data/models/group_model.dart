import 'package:flutter/material.dart';

class GroupModel {
  final String name;
  final int memberCount;
  final double balance;
  final bool isPositive; // true = you are owed (green), false = you owe (red)
  final List<Color> memberAvatarColors;

  const GroupModel({
    required this.name,
    required this.memberCount,
    required this.balance,
    required this.isPositive,
    required this.memberAvatarColors,
  });
}
