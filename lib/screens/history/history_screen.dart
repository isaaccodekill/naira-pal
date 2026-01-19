import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/constants.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../providers/expense_provider.dart' as expense_provider;
import '../../widgets/expense_list_item.dart';
import '../../widgets/rounded_donut_chart.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _updateDateRange(WidgetRef ref, TimeFrame timeFrame) {
    ref.read(selectedTimeFrameProvider.notifier).state = timeFrame;

    final now = DateTime.now();
    expense_provider.DateTimeRange range;

    switch (timeFrame) {
      case TimeFrame.day:
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day + 1).subtract(const Duration(milliseconds: 1));
        range = expense_provider.DateTimeRange(start: startOfDay, end: endOfDay);
        break;
      case TimeFrame.week:
        // Last 7 days (rolling window, not calendar week)
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        final endOfWeek = DateTime(now.year, now.month, now.day + 1).subtract(const Duration(milliseconds: 1));
        range = expense_provider.DateTimeRange(start: startOfWeek, end: endOfWeek);
        break;
      case TimeFrame.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
        range = expense_provider.DateTimeRange(start: startOfMonth, end: endOfMonth);
        break;
      case TimeFrame.custom:
        return;
    }

    ref.read(selectedDateRangeProvider.notifier).state = range;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesInRangeProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final selectedTimeFrame = ref.watch(selectedTimeFrameProvider);

    final currencySymbol = settingsAsync.maybeWhen(
      data: (s) => Currencies.fromCode(s?.defaultCurrency ?? 'NGN').symbol,
      orElse: () => '₦',
    );

    return Scaffold(
      body: SafeArea(
        child: expensesAsync.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.receipt(),
                      size: 64,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your first expense to see it here',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              );
            }

            return categoriesAsync.when(
              data: (categories) => _HistoryContent(
                expenses: expenses,
                categories: categories,
                currencySymbol: currencySymbol,
                timeFrame: selectedTimeFrame,
                onTimeFrameSelected: (tf) => _updateDateRange(ref, tf),
                onDeleteExpense: (id) async {
                  final db = ref.read(databaseProvider);
                  await db.expenseDao.deleteExpense(id);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;
  final TimeFrame timeFrame;
  final Function(TimeFrame) onTimeFrameSelected;
  final Function(int) onDeleteExpense;

  const _HistoryContent({
    required this.expenses,
    required this.categories,
    required this.currencySymbol,
    required this.timeFrame,
    required this.onTimeFrameSelected,
    required this.onDeleteExpense,
  });

  @override
  Widget build(BuildContext context) {
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

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final dateFormat = DateFormat.yMMMd();

    return CustomScrollView(
      slivers: [
        // Category breakdown donut chart with total in center
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _CategoryBreakdown(
              expenses: expenses,
              categories: categories,
              currencySymbol: currencySymbol,
              timeFrame: timeFrame,
              onTimeFrameSelected: onTimeFrameSelected,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
        // Category list
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              'Top Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _CategoryList(
            expenses: expenses,
            categories: categories,
            currencySymbol: currencySymbol,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
        // Transactions section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              'Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ),
        ),
        // Expense list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final date = sortedDates[index];
              final dayExpenses = grouped[date]!;
              final dayTotal = dayExpenses.fold<double>(0, (sum, e) => sum + e.amount);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat.format(date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                        Text(
                          '$currencySymbol${NumberFormat('#,##0').format(dayTotal)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ...dayExpenses.map((expense) => ExpenseListItem(
                        expense: expense,
                        onDelete: () => onDeleteExpense(expense.id),
                      )),
                  const SizedBox(height: 8),
                ],
              );
            },
            childCount: sortedDates.length,
          ),
        ),
        // Bottom padding for nav bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}

class _CategoryBreakdown extends StatefulWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;
  final TimeFrame timeFrame;
  final Function(TimeFrame) onTimeFrameSelected;

  const _CategoryBreakdown({
    required this.expenses,
    required this.categories,
    required this.currencySymbol,
    required this.timeFrame,
    required this.onTimeFrameSelected,
  });

  @override
  State<_CategoryBreakdown> createState() => _CategoryBreakdownState();
}

class _CategoryBreakdownState extends State<_CategoryBreakdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getCenterLabel() {
    final now = DateTime.now();
    switch (widget.timeFrame) {
      case TimeFrame.day:
        return DateFormat('MMM d').format(now);
      case TimeFrame.week:
        return 'Last 7 days';
      case TimeFrame.month:
        return DateFormat('MMMM').format(now);
      case TimeFrame.custom:
        return 'Custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals per category
    final byCategory = <int?, double>{};
    for (final expense in widget.expenses) {
      byCategory[expense.categoryId] = (byCategory[expense.categoryId] ?? 0) + expense.amount;
    }

    final total = byCategory.values.fold<double>(0, (sum, v) => sum + v);
    final categoryMap = {for (var c in widget.categories) c.id: c};

    // Sort by amount descending
    final sortedEntries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Timeframe selector chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeframeChip(
                label: 'Day',
                isSelected: widget.timeFrame == TimeFrame.day,
                onTap: () => widget.onTimeFrameSelected(TimeFrame.day),
              ),
              const SizedBox(width: 8),
              _TimeframeChip(
                label: 'Week',
                isSelected: widget.timeFrame == TimeFrame.week,
                onTap: () => widget.onTimeFrameSelected(TimeFrame.week),
              ),
              const SizedBox(width: 8),
              _TimeframeChip(
                label: 'Month',
                isSelected: widget.timeFrame == TimeFrame.month,
                onTap: () => widget.onTimeFrameSelected(TimeFrame.month),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Rounded donut chart with total in center
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return RoundedDonutChart(
                  size: 220,
                  strokeWidth: 24,
                  animationValue: _animation.value,
                  sections: sortedEntries.map((entry) {
                    final category = categoryMap[entry.key];
                    final color = category != null
                        ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                        : Colors.grey;
                    return DonutSection(value: entry.value, color: color);
                  }).toList(),
                  centerWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCenterLabel(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.currencySymbol}${NumberFormat('#,##0').format(total)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeframeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeframeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;

  const _CategoryList({
    required this.expenses,
    required this.categories,
    required this.currencySymbol,
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
    // Calculate totals per category
    final byCategory = <int?, double>{};
    final countByCategory = <int?, int>{};
    for (final expense in expenses) {
      byCategory[expense.categoryId] = (byCategory[expense.categoryId] ?? 0) + expense.amount;
      countByCategory[expense.categoryId] = (countByCategory[expense.categoryId] ?? 0) + 1;
    }

    final categoryMap = {for (var c in categories) c.id: c};
    final sortedEntries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: sortedEntries.take(5).map((entry) {
            final category = categoryMap[entry.key];
            final color = category != null
                ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                : Colors.grey;
            final count = countByCategory[entry.key] ?? 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIcon(category?.icon ?? 'dots_three'),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          category?.name ?? 'Uncategorized',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$count',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$currencySymbol${NumberFormat('#,##0').format(entry.value)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    PhosphorIcons.caretRight(),
                    size: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
