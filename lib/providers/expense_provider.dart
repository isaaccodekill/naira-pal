import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import 'database_provider.dart';
import 'category_provider.dart';

enum TimeFrame { day, week, month, custom }

final selectedTimeFrameProvider = StateProvider<TimeFrame>((ref) => TimeFrame.month);

final selectedDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  // Use start of next month to be fully inclusive of all times on the last day
  final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
  return DateTimeRange(start: startOfMonth, end: endOfMonth);
});

final expensesInRangeProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  final range = ref.watch(selectedDateRangeProvider);
  return db.expenseDao.watchExpensesBetween(range.start, range.end);
});

final expensesByCategoryProvider = Provider<Map<int?, double>>((ref) {
  final expensesAsync = ref.watch(expensesInRangeProvider);
  return expensesAsync.maybeWhen(
    data: (expenses) {
      final map = <int?, double>{};
      for (final expense in expenses) {
        map[expense.categoryId] = (map[expense.categoryId] ?? 0) + expense.amount;
      }
      return map;
    },
    orElse: () => {},
  );
});

final totalExpensesProvider = Provider<double>((ref) {
  final byCategory = ref.watch(expensesByCategoryProvider);
  return byCategory.values.fold(0, (sum, amount) => sum + amount);
});

// Provider for last 30 days expenses (used for accent color)
final last30DaysExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final thirtyDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
  final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return db.expenseDao.watchExpensesBetween(thirtyDaysAgo, endOfToday);
});

// Provider for the top spending category ID (based on last 30 days)
final topCategoryIdProvider = Provider<int?>((ref) {
  final expensesAsync = ref.watch(last30DaysExpensesProvider);
  return expensesAsync.maybeWhen(
    data: (expenses) {
      if (expenses.isEmpty) return null;

      final byCategory = <int?, double>{};
      for (final expense in expenses) {
        byCategory[expense.categoryId] = (byCategory[expense.categoryId] ?? 0) + expense.amount;
      }

      if (byCategory.isEmpty) return null;

      final topEntry = byCategory.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      return topEntry.key;
    },
    orElse: () => null,
  );
});

// Provider for the accent color based on top category
final accentColorProvider = Provider<Color>((ref) {
  final topCategoryId = ref.watch(topCategoryIdProvider);
  final categoriesAsync = ref.watch(categoriesProvider);

  return categoriesAsync.maybeWhen(
    data: (categories) {
      if (topCategoryId == null) return const Color(0xFFD4847C); // Default coral

      final category = categories.cast<Category?>().firstWhere(
        (c) => c?.id == topCategoryId,
        orElse: () => null,
      );

      if (category == null) return const Color(0xFFD4847C);

      return Color(int.parse(category.color.replaceFirst('#', '0xFF')));
    },
    orElse: () => const Color(0xFFD4847C),
  );
});

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}
