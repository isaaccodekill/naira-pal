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
