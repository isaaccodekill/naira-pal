import 'package:flutter/material.dart';

class DefaultCategory {
  final String name;
  final String icon;
  final Color color;

  const DefaultCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class DefaultCategories {
  static const List<DefaultCategory> all = [
    DefaultCategory(
      name: 'Food & Drinks',
      icon: 'fork_knife',
      color: Color(0xFFD4847C),
    ),
    DefaultCategory(
      name: 'Transport',
      icon: 'car',
      color: Color(0xFF6B9BD2),
    ),
    DefaultCategory(
      name: 'Shopping',
      icon: 'shopping_bag',
      color: Color(0xFF9B7ED9),
    ),
    DefaultCategory(
      name: 'Bills & Utilities',
      icon: 'file_text',
      color: Color(0xFF8B8B8B),
    ),
    DefaultCategory(
      name: 'Entertainment',
      icon: 'film_strip',
      color: Color(0xFFE091B8),
    ),
    DefaultCategory(
      name: 'Health',
      icon: 'pill',
      color: Color(0xFF9CAF91),
    ),
    DefaultCategory(
      name: 'Education',
      icon: 'book_open',
      color: Color(0xFF6BB5B5),
    ),
    DefaultCategory(
      name: 'Gifts',
      icon: 'gift',
      color: Color(0xFFE6A959),
    ),
    DefaultCategory(
      name: 'Groceries',
      icon: 'shopping_cart',
      color: Color(0xFFA8C97F),
    ),
    DefaultCategory(
      name: 'Other',
      icon: 'dots_three',
      color: Color(0xFFA39E99),
    ),
  ];
}
