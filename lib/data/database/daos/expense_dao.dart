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
