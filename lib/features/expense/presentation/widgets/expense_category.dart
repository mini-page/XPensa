import 'package:flutter/material.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

const List<ExpenseCategory> expenseCategories = <ExpenseCategory>[
  ExpenseCategory(
    name: 'Food & Dining',
    icon: Icons.restaurant_outlined,
    color: Color(0xFFFFB648),
  ),
  ExpenseCategory(
    name: 'Transportation',
    icon: Icons.directions_bus_outlined,
    color: Color(0xFF61A7FF),
  ),
  ExpenseCategory(
    name: 'Shopping',
    icon: Icons.shopping_bag_outlined,
    color: Color(0xFFFF8C7A),
  ),
  ExpenseCategory(
    name: 'Beauty & Care',
    icon: Icons.auto_awesome_outlined,
    color: Color(0xFFFF72B6),
  ),
  ExpenseCategory(
    name: 'Social',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF9B8CFF),
  ),
  ExpenseCategory(
    name: 'Travel',
    icon: Icons.flight_takeoff_outlined,
    color: Color(0xFF4BB7A6),
  ),
  ExpenseCategory(
    name: 'Other',
    icon: Icons.widgets_outlined,
    color: Color(0xFF7B8BAA),
  ),
  ExpenseCategory(
    name: 'Accessories',
    icon: Icons.watch_outlined,
    color: Color(0xFF6D8FFF),
  ),
];

const List<ExpenseCategory> incomeCategories = <ExpenseCategory>[
  ExpenseCategory(
    name: 'Salary',
    icon: Icons.work_outline_rounded,
    color: Color(0xFF8FC7FF),
  ),
  ExpenseCategory(
    name: 'Award',
    icon: Icons.emoji_events_outlined,
    color: Color(0xFFB4EFB8),
  ),
  ExpenseCategory(
    name: 'Coupon',
    icon: Icons.confirmation_num_outlined,
    color: Color(0xFFFFB9C6),
  ),
  ExpenseCategory(
    name: 'Grant',
    icon: Icons.card_giftcard_outlined,
    color: Color(0xFFD0BEFF),
  ),
  ExpenseCategory(
    name: 'Lottery',
    icon: Icons.casino_outlined,
    color: Color(0xFFFFE38A),
  ),
  ExpenseCategory(
    name: 'Refund',
    icon: Icons.replay_circle_filled_outlined,
    color: Color(0xFF7FD4C0),
  ),
  ExpenseCategory(
    name: 'Sale',
    icon: Icons.sell_outlined,
    color: Color(0xFFFFCB7A),
  ),
];

ExpenseCategory resolveExpenseCategory(String name) {
  return expenseCategories.firstWhere(
    (category) => category.name == name,
    orElse: () => expenseCategories.last,
  );
}

ExpenseCategory resolveIncomeCategory(String name) {
  return incomeCategories.firstWhere(
    (category) => category.name == name,
    orElse: () => incomeCategories.last,
  );
}

ExpenseCategory resolveCategory(String name, {bool income = false}) {
  return income ? resolveIncomeCategory(name) : resolveExpenseCategory(name);
}
