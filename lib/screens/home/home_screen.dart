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
