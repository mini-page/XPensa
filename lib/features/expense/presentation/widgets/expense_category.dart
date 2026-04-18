import 'package:flutter/material.dart';

/// Maps a category icon key string to its [IconData].
/// Used by [CustomCategoryModel] and [CategoryEditorSheet].
IconData categoryIconFromKey(String key) {
  switch (key) {
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'transport':
      return Icons.directions_bus_outlined;
    case 'shopping':
      return Icons.shopping_bag_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'health':
      return Icons.health_and_safety_outlined;
    case 'education':
      return Icons.school_outlined;
    case 'entertainment':
      return Icons.movie_outlined;
    case 'gym':
      return Icons.fitness_center_outlined;
    case 'pets':
      return Icons.pets_outlined;
    case 'gift':
      return Icons.card_giftcard_outlined;
    case 'work':
      return Icons.work_outline_rounded;
    case 'star':
      return Icons.star_outline_rounded;
    default:
      return Icons.category_outlined;
  }
}

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

ExpenseCategory resolveExpenseCategory(
  String name, [
  List<ExpenseCategory> extra = const [],
]) {
  for (final c in extra) {
    if (c.name == name) return c;
  }
  return expenseCategories.firstWhere(
    (category) => category.name == name,
    orElse: () => expenseCategories.last,
  );
}

ExpenseCategory resolveIncomeCategory(
  String name, [
  List<ExpenseCategory> extra = const [],
]) {
  for (final c in extra) {
    if (c.name == name) return c;
  }
  return incomeCategories.firstWhere(
    (category) => category.name == name,
    orElse: () => incomeCategories.last,
  );
}

ExpenseCategory resolveCategory(
  String name, {
  bool income = false,
  List<ExpenseCategory> extra = const [],
}) {
  return income
      ? resolveIncomeCategory(name, extra)
      : resolveExpenseCategory(name, extra);
}
