# NairaPal Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a beautiful, frictionless expense tracker with quick 3-second logging, pie chart visualization, and multi-currency support.

**Architecture:** Local-first Flutter app using Drift for SQLite storage and Riverpod for state management. Three main screens (Home, History, Settings) with a bottom sheet for expense entry. Soft warm visual theme with micro-interactions.

**Tech Stack:** Flutter 3.x, Drift (SQLite), Riverpod, fl_chart, flutter_animate, intl

---

## Phase 1: Project Setup & Core Infrastructure

### Task 1: Clean Up Default Flutter Template

**Files:**
- Modify: `lib/main.dart`
- Modify: `pubspec.yaml`

**Step 1: Update pubspec.yaml with dependencies**

```yaml
name: cash_book
description: "NairaPal - Personal expense tracker"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.7

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.4.9
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.2
  path: ^1.8.3
  fl_chart: ^0.66.2
  intl: ^0.19.0
  flutter_animate: ^4.5.0
  google_fonts: ^6.1.0
  phosphor_flutter: ^2.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  drift_dev: ^2.14.1
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
```

**Step 2: Run flutter pub get**

Run: `cd /Users/isaacbello/Documents/naira-pal && flutter pub get`
Expected: Dependencies resolve successfully

**Step 3: Replace main.dart with minimal app shell**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: NairaPalApp()));
}

class NairaPalApp extends StatelessWidget {
  const NairaPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NairaPal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4847C)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('NairaPal')),
      ),
    );
  }
}
```

**Step 4: Verify app runs**

Run: `cd /Users/isaacbello/Documents/naira-pal && flutter run -d macos`
Expected: App launches showing "NairaPal" text

**Step 5: Commit**

```bash
git add pubspec.yaml lib/main.dart
git commit -m "chore: set up project with core dependencies"
```

---

### Task 2: Create Theme System

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_typography.dart`
- Create: `lib/core/theme/app_theme.dart`

**Step 1: Create app_colors.dart**

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Light mode
  static const backgroundLight = Color(0xFFFAF8F5);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF2D2A26);
  static const textSecondaryLight = Color(0xFF6B6560);

  // Dark mode
  static const backgroundDark = Color(0xFF1C1B1A);
  static const surfaceDark = Color(0xFF2A2927);
  static const textPrimaryDark = Color(0xFFFAF8F5);
  static const textSecondaryDark = Color(0xFFB0ACA7);

  // Accent colors (same for both modes)
  static const primary = Color(0xFFD4847C);      // Coral
  static const secondary = Color(0xFF9CAF91);    // Sage green
  static const warning = Color(0xFFE6A959);      // Amber
  static const error = Color(0xFFD4645C);

  // Category colors
  static const categoryFood = Color(0xFFD4847C);
  static const categoryTransport = Color(0xFF6B9BD2);
  static const categoryShopping = Color(0xFF9B7ED9);
  static const categoryBills = Color(0xFF8B8B8B);
  static const categoryEntertainment = Color(0xFFE091B8);
  static const categoryHealth = Color(0xFF9CAF91);
  static const categoryEducation = Color(0xFF6BB5B5);
  static const categoryGifts = Color(0xFFE6A959);
  static const categoryGroceries = Color(0xFFA8C97F);
  static const categoryOther = Color(0xFFA39E99);
}
```

**Step 2: Create app_typography.dart**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? const Color(0xFF2D2A26)
        : const Color(0xFFFAF8F5);

    return TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
    );
  }
}
```

**Step 3: Create app_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: AppColors.textPrimaryLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.textTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
```

**Step 4: Create theme barrel export**

Create: `lib/core/theme/theme.dart`

```dart
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_theme.dart';
```

**Step 5: Commit**

```bash
git add lib/core/
git commit -m "feat: add theme system with colors and typography"
```

---

### Task 3: Create Constants (Currencies & Default Categories)

**Files:**
- Create: `lib/core/constants/currencies.dart`
- Create: `lib/core/constants/default_categories.dart`
- Create: `lib/core/constants/constants.dart`

**Step 1: Create currencies.dart**

```dart
class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class Currencies {
  static const ngn = Currency(code: 'NGN', symbol: '₦', name: 'Nigerian Naira');
  static const usd = Currency(code: 'USD', symbol: '\$', name: 'US Dollar');
  static const gbp = Currency(code: 'GBP', symbol: '£', name: 'British Pound');
  static const eur = Currency(code: 'EUR', symbol: '€', name: 'Euro');
  static const ghs = Currency(code: 'GHS', symbol: '₵', name: 'Ghanaian Cedi');
  static const kes = Currency(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling');
  static const zar = Currency(code: 'ZAR', symbol: 'R', name: 'South African Rand');

  static const List<Currency> all = [ngn, usd, gbp, eur, ghs, kes, zar];

  static Currency fromCode(String code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => ngn,
    );
  }
}
```

**Step 2: Create default_categories.dart**

```dart
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
```

**Step 3: Create barrel export**

```dart
export 'currencies.dart';
export 'default_categories.dart';
```

**Step 4: Commit**

```bash
git add lib/core/constants/
git commit -m "feat: add currency and category constants"
```

---

### Task 4: Set Up Database with Drift

**Files:**
- Create: `lib/data/database/app_database.dart`
- Create: `lib/data/database/tables.dart`
- Create: `lib/data/database/daos/expense_dao.dart`
- Create: `lib/data/database/daos/category_dao.dart`
- Create: `lib/data/database/daos/settings_dao.dart`

**Step 1: Create tables.dart**

```dart
import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().withLength(min: 1, max: 50)();
  TextColumn get color => text().withLength(min: 7, max: 9)(); // Hex color
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get defaultCurrency => text().withDefault(const Constant('NGN'))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  DateTimeColumn get premiumExpiresAt => dateTime().nullable()();
}
```

**Step 2: Create app_database.dart**

```dart
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
        color: '#${cat.color.value.toRadixString(16).substring(2).toUpperCase()}',
        isDefault: const Value(true),
        sortOrder: Value(i),
      ));
    }

    // Insert default settings
    await into(userSettings).insert(UserSettingsCompanion.insert());
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nairapal.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

**Step 3: Create expense_dao.dart**

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses, Categories])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  Future<List<Expense>> getAllExpenses() => select(expenses).get();

  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();

  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end) {
    return (select(expenses)
          ..where((e) => e.createdAt.isBetweenValues(start, end))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();
  }

  Stream<List<Expense>> watchExpensesBetween(DateTime start, DateTime end) {
    return (select(expenses)
          ..where((e) => e.createdAt.isBetweenValues(start, end))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch();
  }

  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  Future<bool> updateExpense(Expense expense) {
    return update(expenses).replace(expense);
  }

  Future<int> deleteExpense(int id) {
    return (delete(expenses)..where((e) => e.id.equals(id))).go();
  }
}
```

**Step 4: Create category_dao.dart**

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<Category>> getAllCategories() {
    return (select(categories)
          ..where((c) => c.isArchived.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Stream<List<Category>> watchAllCategories() {
    return (select(categories)
          ..where((c) => c.isArchived.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  Future<Category?> getCategoryById(int id) {
    return (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  Future<bool> updateCategory(Category category) {
    return update(categories).replace(category);
  }

  Future<int> archiveCategory(int id) {
    return (update(categories)..where((c) => c.id.equals(id)))
        .write(const CategoriesCompanion(isArchived: Value(true)));
  }
}
```

**Step 5: Create settings_dao.dart**

```dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [UserSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<UserSetting?> getSettings() {
    return select(userSettings).getSingleOrNull();
  }

  Stream<UserSetting?> watchSettings() {
    return select(userSettings).watchSingleOrNull();
  }

  Future<int> updateSettings(UserSettingsCompanion settings) {
    return (update(userSettings)..where((s) => s.id.equals(1))).write(settings);
  }
}
```

**Step 6: Create database barrel export**

Create: `lib/data/database/database.dart`

```dart
export 'app_database.dart';
export 'tables.dart';
export 'daos/expense_dao.dart';
export 'daos/category_dao.dart';
export 'daos/settings_dao.dart';
```

**Step 7: Run build_runner to generate Drift code**

Run: `cd /Users/isaacbello/Documents/naira-pal && dart run build_runner build --delete-conflicting-outputs`
Expected: Generated files created (*.g.dart)

**Step 8: Commit**

```bash
git add lib/data/
git commit -m "feat: add Drift database with tables and DAOs"
```

---

### Task 5: Create Riverpod Providers

**Files:**
- Create: `lib/providers/database_provider.dart`
- Create: `lib/providers/expense_provider.dart`
- Create: `lib/providers/category_provider.dart`
- Create: `lib/providers/settings_provider.dart`
- Create: `lib/providers/providers.dart`

**Step 1: Create database_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
```

**Step 2: Create category_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import 'database_provider.dart';

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.categoryDao.watchAllCategories();
});

final categoryByIdProvider = FutureProvider.family<Category?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.categoryDao.getCategoryById(id);
});
```

**Step 3: Create settings_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import 'database_provider.dart';

final settingsProvider = StreamProvider<UserSetting?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.settingsDao.watchSettings();
});
```

**Step 4: Create expense_provider.dart**

```dart
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
```

**Step 5: Create barrel export**

```dart
export 'database_provider.dart';
export 'expense_provider.dart';
export 'category_provider.dart';
export 'settings_provider.dart';
```

**Step 6: Commit**

```bash
git add lib/providers/
git commit -m "feat: add Riverpod providers for state management"
```

---

## Phase 2: Core UI Components

### Task 6: Create App Shell with Bottom Navigation

**Files:**
- Create: `lib/app.dart`
- Create: `lib/screens/home/home_screen.dart`
- Create: `lib/screens/history/history_screen.dart`
- Create: `lib/screens/settings/settings_screen.dart`
- Modify: `lib/main.dart`

**Step 1: Create placeholder home_screen.dart**

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home')),
    );
  }
}
```

**Step 2: Create placeholder history_screen.dart**

```dart
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('History')),
    );
  }
}
```

**Step 3: Create placeholder settings_screen.dart**

```dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Settings')),
    );
  }
}
```

**Step 4: Create app.dart with navigation**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'core/theme/theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class NairaPalApp extends ConsumerWidget {
  const NairaPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    final screens = [
      const HomeScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return MaterialApp(
      title: 'NairaPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: IndexedStack(
          index: selectedTab,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: (index) {
            ref.read(selectedTabProvider.notifier).state = index;
          },
          destinations: [
            NavigationDestination(
              icon: Icon(PhosphorIcons.house()),
              selectedIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.clockCounterClockwise()),
              selectedIcon: Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill)),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.gear()),
              selectedIcon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.fill)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Update main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NairaPalApp()));
}
```

**Step 6: Verify app runs with navigation**

Run: `cd /Users/isaacbello/Documents/naira-pal && flutter run -d macos`
Expected: App shows bottom navigation with 3 tabs

**Step 7: Commit**

```bash
git add lib/
git commit -m "feat: add app shell with bottom navigation"
```

---

### Task 7: Build Entry Sheet Component

**Files:**
- Create: `lib/screens/entry/entry_sheet.dart`
- Create: `lib/widgets/numpad.dart`
- Create: `lib/widgets/category_chips.dart`

**Step 1: Create numpad.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Numpad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const Numpad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _NumpadKey(
                  label: key,
                  onTap: () {
                    if (key == '⌫') {
                      onBackspace();
                    } else {
                      onKeyPressed(key);
                    }
                  },
                  onLongPress: key == '⌫' ? onClear : null,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _NumpadKey({
    required this.label,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.stop()).shimmer(
      duration: 200.ms,
    );
  }
}
```

**Step 2: Create category_chips.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/database/database.dart';
import '../providers/providers.dart';
import '../core/theme/theme.dart';

class CategoryChips extends ConsumerWidget {
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...categories.map((cat) => _CategoryChip(
                category: cat,
                isSelected: selectedCategoryId == cat.id,
                onTap: () => onCategorySelected(cat.id),
              )),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fork_knife':
        return PhosphorIcons.forkKnife();
      case 'car':
        return PhosphorIcons.car();
      case 'shopping_bag':
        return PhosphorIcons.shoppingBag();
      case 'file_text':
        return PhosphorIcons.fileText();
      case 'film_strip':
        return PhosphorIcons.filmStrip();
      case 'pill':
        return PhosphorIcons.pill();
      case 'book_open':
        return PhosphorIcons.bookOpen();
      case 'gift':
        return PhosphorIcons.gift();
      case 'shopping_cart':
        return PhosphorIcons.shoppingCart();
      default:
        return PhosphorIcons.dotsThree();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        _getIcon(category.icon),
        size: 18,
        color: isSelected ? Colors.white : color,
      ),
      label: Text(category.name),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }
}
```

**Step 3: Create entry_sheet.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/constants.dart';
import '../../core/theme/theme.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../widgets/numpad.dart';
import '../../widgets/category_chips.dart';

class EntrySheet extends ConsumerStatefulWidget {
  const EntrySheet({super.key});

  @override
  ConsumerState<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<EntrySheet> {
  String _amount = '0';
  int? _selectedCategoryId;
  String _note = '';
  String _currency = 'NGN';
  bool _showNoteField = false;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDefaultCurrency();
  }

  Future<void> _loadDefaultCurrency() async {
    final settings = await ref.read(settingsProvider.future);
    if (settings != null && mounted) {
      setState(() {
        _currency = settings.defaultCurrency;
      });
    }
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_amount == '0' && key != '.') {
        _amount = key;
      } else if (key == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.contains('.') && _amount.split('.')[1].length >= 2) {
        return;
      } else {
        _amount += key;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _onClear() {
    setState(() {
      _amount = '0';
    });
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      return;
    }

    final db = ref.read(databaseProvider);
    await db.expenseDao.insertExpense(ExpensesCompanion.insert(
      amount: amount,
      currency: _currency,
      categoryId: Value(_selectedCategoryId),
      note: Value(_note.isEmpty ? null : _note),
    ));

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = Currencies.fromCode(_currency).symbol;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Amount display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currencySymbol,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                _amount,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ).animate().fadeIn(duration: 150.ms),
            ],
          ),
          const SizedBox(height: 24),

          // Category chips
          CategoryChips(
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (id) {
              setState(() {
                _selectedCategoryId = id;
              });
            },
          ),
          const SizedBox(height: 16),

          // Note field toggle
          if (!_showNoteField)
            TextButton.icon(
              onPressed: () => setState(() => _showNoteField = true),
              icon: const Icon(Icons.add),
              label: const Text('Add note'),
            )
          else
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _note = value,
              autofocus: true,
            ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 24),

          // Numpad
          Numpad(
            onKeyPressed: _onKeyPressed,
            onBackspace: _onBackspace,
            onClear: _onClear,
          ),
          const SizedBox(height: 16),

          // Done button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _amount != '0' ? _saveExpense : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Done'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

void showEntrySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const EntrySheet(),
  );
}
```

**Step 4: Create widgets barrel export**

Create: `lib/widgets/widgets.dart`

```dart
export 'numpad.dart';
export 'category_chips.dart';
```

**Step 5: Commit**

```bash
git add lib/screens/entry/ lib/widgets/
git commit -m "feat: add expense entry sheet with numpad and category selection"
```

---

### Task 8: Build Home Screen with Pie Chart

**Files:**
- Modify: `lib/screens/home/home_screen.dart`
- Create: `lib/widgets/expense_pie_chart.dart`
- Create: `lib/widgets/category_spending_card.dart`
- Create: `lib/widgets/timeframe_selector.dart`

**Step 1: Create timeframe_selector.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

class TimeframeSelector extends ConsumerWidget {
  const TimeframeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTimeFrame = ref.watch(selectedTimeFrameProvider);

    return SegmentedButton<TimeFrame>(
      segments: const [
        ButtonSegment(value: TimeFrame.day, label: Text('Day')),
        ButtonSegment(value: TimeFrame.week, label: Text('Week')),
        ButtonSegment(value: TimeFrame.month, label: Text('Month')),
      ],
      selected: {selectedTimeFrame},
      onSelectionChanged: (selection) {
        final timeFrame = selection.first;
        ref.read(selectedTimeFrameProvider.notifier).state = timeFrame;

        final now = DateTime.now();
        late DateTimeRange range;

        switch (timeFrame) {
          case TimeFrame.day:
            final startOfDay = DateTime(now.year, now.month, now.day);
            final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
            range = DateTimeRange(start: startOfDay, end: endOfDay);
          case TimeFrame.week:
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
            final endOfWeek = startOfWeekMidnight.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
            range = DateTimeRange(start: startOfWeekMidnight, end: endOfWeek);
          case TimeFrame.month:
            final startOfMonth = DateTime(now.year, now.month, 1);
            final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
            range = DateTimeRange(start: startOfMonth, end: endOfMonth);
          case TimeFrame.custom:
            return;
        }

        ref.read(selectedDateRangeProvider.notifier).state = range;
      },
    );
  }
}
```

**Step 2: Create expense_pie_chart.dart**

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants/constants.dart';
import '../data/database/database.dart';
import '../providers/providers.dart';

class ExpensePieChart extends ConsumerWidget {
  const ExpensePieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byCategory = ref.watch(expensesByCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final total = ref.watch(totalExpensesProvider);
    final settings = ref.watch(settingsProvider);

    if (byCategory.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No expenses yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
        ),
      );
    }

    return categoriesAsync.when(
      data: (categories) {
        final categoryMap = {for (var c in categories) c.id: c};
        final currencySymbol = settings.maybeWhen(
          data: (s) => Currencies.fromCode(s?.defaultCurrency ?? 'NGN').symbol,
          orElse: () => '₦',
        );

        final sections = byCategory.entries.map((entry) {
          final category = categoryMap[entry.key];
          final color = category != null
              ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
              : Colors.grey;
          final percentage = (entry.value / total * 100);

          return PieChartSectionData(
            value: entry.value,
            color: color,
            title: '${percentage.toStringAsFixed(0)}%',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            radius: 60,
          );
        }).toList();

        return SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                ),
              ).animate().scale(
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$currencySymbol${total.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

**Step 3: Create category_spending_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/constants/constants.dart';
import '../data/database/database.dart';
import '../providers/providers.dart';

class CategorySpendingList extends ConsumerWidget {
  const CategorySpendingList({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fork_knife':
        return PhosphorIcons.forkKnife();
      case 'car':
        return PhosphorIcons.car();
      case 'shopping_bag':
        return PhosphorIcons.shoppingBag();
      case 'file_text':
        return PhosphorIcons.fileText();
      case 'film_strip':
        return PhosphorIcons.filmStrip();
      case 'pill':
        return PhosphorIcons.pill();
      case 'book_open':
        return PhosphorIcons.bookOpen();
      case 'gift':
        return PhosphorIcons.gift();
      case 'shopping_cart':
        return PhosphorIcons.shoppingCart();
      default:
        return PhosphorIcons.dotsThree();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byCategory = ref.watch(expensesByCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final total = ref.watch(totalExpensesProvider);
    final settings = ref.watch(settingsProvider);

    if (byCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    return categoriesAsync.when(
      data: (categories) {
        final categoryMap = {for (var c in categories) c.id: c};
        final currencySymbol = settings.maybeWhen(
          data: (s) => Currencies.fromCode(s?.defaultCurrency ?? 'NGN').symbol,
          orElse: () => '₦',
        );

        // Sort by amount descending
        final sortedEntries = byCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          children: sortedEntries.map((entry) {
            final category = categoryMap[entry.key];
            final color = category != null
                ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                : Colors.grey;
            final percentage = total > 0 ? (entry.value / total) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(category?.icon ?? 'dots_three'),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category?.name ?? 'Uncategorized',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '$currencySymbol${entry.value.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(color),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

**Step 4: Update home_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../widgets/expense_pie_chart.dart';
import '../../widgets/category_spending_card.dart';
import '../../widgets/timeframe_selector.dart';
import '../entry/entry_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NairaPal',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),

              // Timeframe selector
              const Center(child: TimeframeSelector()),
              const SizedBox(height: 24),

              // Pie chart
              const ExpensePieChart(),
              const SizedBox(height: 32),

              // Category spending list
              Text(
                'Spending by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const CategorySpendingList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showEntrySheet(context),
        child: Icon(PhosphorIcons.plus()),
      ),
    );
  }
}
```

**Step 5: Update widgets barrel export**

Modify: `lib/widgets/widgets.dart`

```dart
export 'numpad.dart';
export 'category_chips.dart';
export 'expense_pie_chart.dart';
export 'category_spending_card.dart';
export 'timeframe_selector.dart';
```

**Step 6: Verify home screen works**

Run: `cd /Users/isaacbello/Documents/naira-pal && flutter run -d macos`
Expected: Home screen shows timeframe selector, pie chart, and category spending list

**Step 7: Commit**

```bash
git add lib/
git commit -m "feat: add home screen with pie chart and category spending"
```

---

### Task 9: Build History Screen

**Files:**
- Modify: `lib/screens/history/history_screen.dart`
- Create: `lib/widgets/expense_list_item.dart`

**Step 1: Create expense_list_item.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../core/constants/constants.dart';
import '../data/database/database.dart';
import '../providers/providers.dart';

class ExpenseListItem extends ConsumerWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
  });

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fork_knife':
        return PhosphorIcons.forkKnife();
      case 'car':
        return PhosphorIcons.car();
      case 'shopping_bag':
        return PhosphorIcons.shoppingBag();
      case 'file_text':
        return PhosphorIcons.fileText();
      case 'film_strip':
        return PhosphorIcons.filmStrip();
      case 'pill':
        return PhosphorIcons.pill();
      case 'book_open':
        return PhosphorIcons.bookOpen();
      case 'gift':
        return PhosphorIcons.gift();
      case 'shopping_cart':
        return PhosphorIcons.shoppingCart();
      default:
        return PhosphorIcons.dotsThree();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = expense.categoryId != null
        ? ref.watch(categoryByIdProvider(expense.categoryId!))
        : const AsyncValue<Category?>.data(null);

    final currencySymbol = Currencies.fromCode(expense.currency).symbol;
    final timeFormat = DateFormat.jm();

    return Dismissible(
      key: Key('expense_${expense.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          PhosphorIcons.trash(),
          color: Colors.white,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: categoryAsync.when(
          data: (category) {
            final color = category != null
                ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                : Colors.grey;
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(category?.icon ?? 'dots_three'),
                color: color,
                size: 22,
              ),
            );
          },
          loading: () => const SizedBox(width: 44, height: 44),
          error: (_, __) => const SizedBox(width: 44, height: 44),
        ),
        title: Text(
          '$currencySymbol${expense.amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            categoryAsync.when(
              data: (category) => Text(category?.name ?? 'Uncategorized'),
              loading: () => const Text('...'),
              error: (_, __) => const Text('Unknown'),
            ),
            if (expense.note != null && expense.note!.isNotEmpty)
              Text(
                expense.note!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          timeFormat.format(expense.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
```

**Step 2: Update history_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../widgets/expense_list_item.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesInRangeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'History',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Expanded(
              child: expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return Center(
                      child: Text(
                        'No expenses yet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                    );
                  }

                  // Group by date
                  final grouped = <DateTime, List<Expense>>{};
                  for (final expense in expenses) {
                    final date = DateTime(
                      expense.createdAt.year,
                      expense.createdAt.month,
                      expense.createdAt.day,
                    );
                    grouped.putIfAbsent(date, () => []).add(expense);
                  }

                  final sortedDates = grouped.keys.toList()
                    ..sort((a, b) => b.compareTo(a));
                  final dateFormat = DateFormat.yMMMd();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final dayExpenses = grouped[date]!;
                      final dayTotal = dayExpenses.fold<double>(
                        0,
                        (sum, e) => sum + e.amount,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateFormat.format(date),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                ),
                                Text(
                                  '${dayExpenses.first.currency} ${dayTotal.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          ...dayExpenses.map((expense) => ExpenseListItem(
                                expense: expense,
                                onDelete: () async {
                                  final db = ref.read(databaseProvider);
                                  await db.expenseDao.deleteExpense(expense.id);
                                },
                              )),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 3: Update widgets barrel export**

Modify: `lib/widgets/widgets.dart`

```dart
export 'numpad.dart';
export 'category_chips.dart';
export 'expense_pie_chart.dart';
export 'category_spending_card.dart';
export 'timeframe_selector.dart';
export 'expense_list_item.dart';
```

**Step 4: Commit**

```bash
git add lib/
git commit -m "feat: add history screen with grouped expense list"
```

---

### Task 10: Build Settings Screen

**Files:**
- Modify: `lib/screens/settings/settings_screen.dart`

**Step 1: Update settings_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/constants.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),

              // Currency
              Text(
                'Currency',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              settingsAsync.when(
                data: (settings) => _CurrencySelector(
                  currentCurrency: settings?.defaultCurrency ?? 'NGN',
                  onChanged: (currency) async {
                    final db = ref.read(databaseProvider);
                    await db.settingsDao.updateSettings(
                      UserSettingsCompanion(defaultCurrency: Value(currency)),
                    );
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Categories
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(PhosphorIcons.squares_four()),
                title: const Text('Categories'),
                subtitle: const Text('Manage expense categories'),
                trailing: Icon(PhosphorIcons.caretRight()),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _CategoriesScreen()),
                  );
                },
              ),
              const Divider(),

              // Premium
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(PhosphorIcons.crown()),
                title: const Text('Premium'),
                subtitle: const Text('Unlock budgets and more'),
                trailing: Icon(PhosphorIcons.caretRight()),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
              const Divider(),

              // Export
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(PhosphorIcons.export_icon()),
                title: const Text('Export Data'),
                subtitle: const Text('Download your expenses'),
                trailing: Icon(PhosphorIcons.caretRight()),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
              const Divider(),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'NairaPal v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final String currentCurrency;
  final Function(String) onChanged;

  const _CurrencySelector({
    required this.currentCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Currencies.all.map((currency) {
        final isSelected = currency.code == currentCurrency;
        return ChoiceChip(
          selected: isSelected,
          onSelected: (_) => onChanged(currency.code),
          label: Text('${currency.symbol} ${currency.code}'),
        );
      }).toList(),
    );
  }
}

class _CategoriesScreen extends ConsumerWidget {
  const _CategoriesScreen();

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fork_knife':
        return PhosphorIcons.forkKnife();
      case 'car':
        return PhosphorIcons.car();
      case 'shopping_bag':
        return PhosphorIcons.shoppingBag();
      case 'file_text':
        return PhosphorIcons.fileText();
      case 'film_strip':
        return PhosphorIcons.filmStrip();
      case 'pill':
        return PhosphorIcons.pill();
      case 'book_open':
        return PhosphorIcons.bookOpen();
      case 'gift':
        return PhosphorIcons.gift();
      case 'shopping_cart':
        return PhosphorIcons.shoppingCart();
      default:
        return PhosphorIcons.dotsThree();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoriesAsync.when(
        data: (categories) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final color = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(category.icon),
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(category.name),
              trailing: category.isDefault
                  ? null
                  : IconButton(
                      icon: Icon(PhosphorIcons.trash()),
                      onPressed: () async {
                        final db = ref.read(databaseProvider);
                        await db.categoryDao.archiveCategory(category.id);
                      },
                    ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/screens/settings/
git commit -m "feat: add settings screen with currency and category management"
```

---

## Phase 3: Polish & Final Integration

### Task 11: Add Import Statements and Fix Any Compilation Errors

**Files:**
- Review and fix all files for missing imports

**Step 1: Run flutter analyze to find issues**

Run: `cd /Users/isaacbello/Documents/naira-pal && flutter analyze`
Expected: Identify any missing imports or type errors

**Step 2: Fix any identified issues**

Fix imports, type errors, or other issues identified by the analyzer.

**Step 3: Run the app to verify**

Run: `cd /Users/isaacbello/Documents/naira-pal && flutter run -d macos`
Expected: App compiles and runs without errors

**Step 4: Commit fixes**

```bash
git add .
git commit -m "fix: resolve compilation errors and missing imports"
```

---

### Task 12: Final Testing and Polish

**Step 1: Test full flow**
- Add an expense using the entry sheet
- Verify it appears in the home screen chart
- Verify it appears in history
- Change timeframe and verify chart updates
- Delete an expense and verify removal
- Change currency in settings

**Step 2: Make any final adjustments**

**Step 3: Final commit**

```bash
git add .
git commit -m "feat: complete NairaPal MVP implementation"
```

---

## Summary

This plan implements NairaPal MVP with:
- 12 tasks across 3 phases
- Local SQLite storage via Drift
- Riverpod state management
- Pie chart visualization
- Quick expense entry
- Category management
- Multi-currency support

Estimated commits: ~12 (one per task)
