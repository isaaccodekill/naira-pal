import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/expense_dao.dart';
import 'daos/category_dao.dart';
import 'daos/settings_dao.dart';
import '../../core/constants/constants.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Expenses, Budgets, UserSettings],
  daos: [ExpenseDao, CategoryDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultData();
      },
    );
  }

  Future<void> _seedDefaultData() async {
    // Insert default categories
    for (var i = 0; i < DefaultCategories.all.length; i++) {
      final cat = DefaultCategories.all[i];
      await into(categories).insert(CategoriesCompanion.insert(
        name: cat.name,
        icon: cat.icon,
        color: '#${cat.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
        isDefault: const Value(true),
        sortOrder: Value(i),
      ));
    }

    // Insert default settings
    await into(userSettings).insert(UserSettingsCompanion.insert());

    // Insert sample expenses for demo purposes
    await _seedSampleExpenses();
  }

  /// Public method to seed sample expenses for demo purposes
  Future<void> seedSampleExpenses() async {
    await _seedSampleExpenses();
  }

  Future<void> _seedSampleExpenses() async {
    final now = DateTime.now();
    final sampleExpenses = [
      // Today
      (amount: 2500.0, categoryId: 1, note: 'Lunch at Chicken Republic', daysAgo: 0),
      (amount: 1200.0, categoryId: 2, note: 'Uber to work', daysAgo: 0),
      (amount: 850.0, categoryId: 9, note: 'Groceries', daysAgo: 0),
      // Yesterday
      (amount: 15000.0, categoryId: 3, note: 'New shoes', daysAgo: 1),
      (amount: 3500.0, categoryId: 1, note: 'Dinner date', daysAgo: 1),
      (amount: 500.0, categoryId: 2, note: 'Bus fare', daysAgo: 1),
      // 2 days ago
      (amount: 8500.0, categoryId: 4, note: 'Electricity bill', daysAgo: 2),
      (amount: 1800.0, categoryId: 1, note: 'Pizza delivery', daysAgo: 2),
      // 3 days ago
      (amount: 4500.0, categoryId: 5, note: 'Netflix subscription', daysAgo: 3),
      (amount: 2200.0, categoryId: 6, note: 'Pharmacy', daysAgo: 3),
      // 5 days ago
      (amount: 12000.0, categoryId: 9, note: 'Weekly groceries', daysAgo: 5),
      (amount: 3000.0, categoryId: 2, note: 'Taxi', daysAgo: 5),
      // 7 days ago
      (amount: 25000.0, categoryId: 7, note: 'Online course', daysAgo: 7),
      (amount: 4000.0, categoryId: 1, note: 'Restaurant', daysAgo: 7),
      // 10 days ago
      (amount: 6500.0, categoryId: 8, note: 'Birthday gift', daysAgo: 10),
      (amount: 2800.0, categoryId: 5, note: 'Cinema tickets', daysAgo: 10),
      // 14 days ago
      (amount: 18000.0, categoryId: 4, note: 'Internet bill', daysAgo: 14),
      (amount: 5500.0, categoryId: 3, note: 'Clothes shopping', daysAgo: 14),
      // 20 days ago
      (amount: 9000.0, categoryId: 9, note: 'Groceries', daysAgo: 20),
      (amount: 3200.0, categoryId: 2, note: 'Fuel', daysAgo: 20),
      // 25 days ago
      (amount: 7500.0, categoryId: 6, note: 'Doctor visit', daysAgo: 25),
      (amount: 4200.0, categoryId: 1, note: 'Takeout food', daysAgo: 25),
      // 28 days ago
      (amount: 15500.0, categoryId: 3, note: 'Electronics', daysAgo: 28),
      (amount: 2000.0, categoryId: 5, note: 'Spotify', daysAgo: 28),
    ];

    for (final expense in sampleExpenses) {
      final createdAt = now.subtract(Duration(days: expense.daysAgo));
      await into(expenses).insert(ExpensesCompanion.insert(
        amount: expense.amount,
        currency: 'NGN',
        categoryId: Value(expense.categoryId),
        note: Value(expense.note),
        createdAt: Value(createdAt),
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nairapal.db'));
    return NativeDatabase.createInBackground(file);
  });
}
