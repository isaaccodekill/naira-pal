import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants/constants.dart';
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
