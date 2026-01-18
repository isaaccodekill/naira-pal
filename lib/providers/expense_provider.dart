import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import 'database_provider.dart';

enum TimeFrame { day, week, month, custom }

final selectedTimeFrameProvider = StateProvider<TimeFrame>((ref) => TimeFrame.month);

final selectedDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
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

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}
