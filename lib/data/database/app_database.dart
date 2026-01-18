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
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nairapal.db'));
    return NativeDatabase.createInBackground(file);
  });
}
