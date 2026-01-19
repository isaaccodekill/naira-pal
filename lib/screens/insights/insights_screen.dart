import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/constants.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';

// Provider for last 6 months expenses
final insightsLast6MonthsProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.expenseDao.watchExpensesLastMonths(6);
});

// Provider for last 12 months (for yearly comparison)
final insightsLast12MonthsProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.expenseDao.watchExpensesLastMonths(12);
});

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final accentColor = ref.watch(accentColorProvider);

    final currencySymbol = settingsAsync.maybeWhen(
      data: (s) => Currencies.fromCode(s?.defaultCurrency ?? 'NGN').symbol,
      orElse: () => '₦',
    );

    return Scaffold(
      body: SafeArea(
        child: categoriesAsync.when(
          data: (categories) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly comparison
                _MonthlyStackedChart(
                  currencySymbol: currencySymbol,
                  categories: categories,
                  accentColor: accentColor,
                ),
                const SizedBox(height: 24),
                // Yearly comparison
                _YearlyStackedChart(
                  currencySymbol: currencySymbol,
                  categories: categories,
                  accentColor: accentColor,
                ),
                // Space for bottom nav
                const SizedBox(height: 100),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _MonthlyStackedChart extends ConsumerStatefulWidget {
  final String currencySymbol;
  final List<Category> categories;
  final Color accentColor;

  const _MonthlyStackedChart({
    required this.currencySymbol,
    required this.categories,
    required this.accentColor,
  });

  @override
  ConsumerState<_MonthlyStackedChart> createState() => _MonthlyStackedChartState();
}

class _MonthlyStackedChartState extends ConsumerState<_MonthlyStackedChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(insightsLast6MonthsProvider);

    return expensesAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return _EmptyState(message: 'No data for monthly comparison');
        }

        final now = DateTime.now();
        final categoryMap = {for (var c in widget.categories) c.id: c};

        // Initialize last 6 months with category breakdowns
        final monthlyData = <DateTime, Map<int?, double>>{};
        for (var i = 5; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          monthlyData[month] = {};
        }

        // Group expenses by month and category
        for (final expense in expenses) {
          final month = DateTime(expense.createdAt.year, expense.createdAt.month, 1);
          if (monthlyData.containsKey(month)) {
            monthlyData[month]![expense.categoryId] =
                (monthlyData[month]![expense.categoryId] ?? 0) + expense.amount;
          }
        }

        final sortedMonths = monthlyData.keys.toList()..sort();

        // Get all unique categories used
        final usedCategoryIds = <int?>{};
        for (final monthData in monthlyData.values) {
          usedCategoryIds.addAll(monthData.keys);
        }
        final sortedCategoryIds = usedCategoryIds.toList();

        // Calculate max total for scaling
        double maxTotal = 0;
        for (final monthData in monthlyData.values) {
          final total = monthData.values.fold<double>(0, (sum, v) => sum + v);
          if (total > maxTotal) maxTotal = total;
        }

        return GestureDetector(
          onTap: () => _openExpandedView(
            context,
            monthlyData: monthlyData,
            sortedMonths: sortedMonths,
            sortedCategoryIds: sortedCategoryIds,
            categoryMap: categoryMap,
            maxTotal: maxTotal,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Spending',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last 6 months by category',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                    Icon(
                      PhosphorIcons.arrowsOut(),
                      size: 20,
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _buildBarChart(
                        monthlyData: monthlyData,
                        sortedMonths: sortedMonths,
                        sortedCategoryIds: sortedCategoryIds,
                        categoryMap: categoryMap,
                        maxTotal: maxTotal,
                        animationValue: _animation.value,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Legend
                _CategoryLegend(
                  categoryIds: sortedCategoryIds,
                  categoryMap: categoryMap,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildBarChart({
    required Map<DateTime, Map<int?, double>> monthlyData,
    required List<DateTime> sortedMonths,
    required List<int?> sortedCategoryIds,
    required Map<int, Category> categoryMap,
    required double maxTotal,
    required double animationValue,
  }) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxTotal * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey.shade800,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = sortedMonths[group.x.toInt()];
              final total = monthlyData[month]!.values.fold<double>(0, (sum, v) => sum + v);
              return BarTooltipItem(
                '${DateFormat('MMM').format(month)}\n${widget.currencySymbol}${NumberFormat('#,##0').format(total)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedMonths.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM').format(sortedMonths[index]),
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: sortedMonths.asMap().entries.map((entry) {
          final index = entry.key;
          final month = entry.value;
          final monthData = monthlyData[month]!;

          // Build stacked rod data
          final rodStackItems = <BarChartRodStackItem>[];
          double fromY = 0;

          for (final categoryId in sortedCategoryIds) {
            final value = (monthData[categoryId] ?? 0) * animationValue;
            if (value > 0) {
              final category = categoryMap[categoryId];
              final color = category != null
                  ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                  : Colors.grey;

              rodStackItems.add(BarChartRodStackItem(
                fromY,
                fromY + value,
                color,
              ));
              fromY += value;
            }
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: fromY,
                rodStackItems: rodStackItems,
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _openExpandedView(
    BuildContext context, {
    required Map<DateTime, Map<int?, double>> monthlyData,
    required List<DateTime> sortedMonths,
    required List<int?> sortedCategoryIds,
    required Map<int, Category> categoryMap,
    required double maxTotal,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return _MonthlyExpandedView(
            currencySymbol: widget.currencySymbol,
            monthlyData: monthlyData,
            sortedMonths: sortedMonths,
            sortedCategoryIds: sortedCategoryIds,
            categoryMap: categoryMap,
            maxTotal: maxTotal,
            accentColor: widget.accentColor,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _MonthlyExpandedView extends StatefulWidget {
  final String currencySymbol;
  final Map<DateTime, Map<int?, double>> monthlyData;
  final List<DateTime> sortedMonths;
  final List<int?> sortedCategoryIds;
  final Map<int, Category> categoryMap;
  final double maxTotal;
  final Color accentColor;

  const _MonthlyExpandedView({
    required this.currencySymbol,
    required this.monthlyData,
    required this.sortedMonths,
    required this.sortedCategoryIds,
    required this.categoryMap,
    required this.maxTotal,
    required this.accentColor,
  });

  @override
  State<_MonthlyExpandedView> createState() => _MonthlyExpandedViewState();
}

class _MonthlyExpandedViewState extends State<_MonthlyExpandedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedMonthIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
    // Select most recent month by default
    _selectedMonthIndex = widget.sortedMonths.length - 1;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate totals for all months
    final monthTotals = widget.sortedMonths.map((month) {
      return widget.monthlyData[month]!.values.fold<double>(0, (sum, v) => sum + v);
    }).toList();

    final grandTotal = monthTotals.fold<double>(0, (sum, v) => sum + v);
    final avgMonthly = grandTotal / widget.sortedMonths.length;

    // Get selected month data
    final selectedMonth = _selectedMonthIndex != null
        ? widget.sortedMonths[_selectedMonthIndex!]
        : null;
    final selectedMonthData = selectedMonth != null
        ? widget.monthlyData[selectedMonth]!
        : <int?, double>{};
    final selectedMonthTotal = selectedMonthData.values.fold<double>(0, (sum, v) => sum + v);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        PhosphorIcons.arrowLeft(),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Spending',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Last 6 months breakdown',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Summary cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total (6 mo)',
                      value: '${widget.currencySymbol}${NumberFormat('#,##0').format(grandTotal)}',
                      icon: PhosphorIcons.currencyCircleDollar(),
                      accentColor: widget.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Monthly Avg',
                      value: '${widget.currencySymbol}${NumberFormat('#,##0').format(avgMonthly)}',
                      icon: PhosphorIcons.chartLine(),
                      accentColor: widget.accentColor,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            // Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 220,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: widget.maxTotal * 1.1,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback: (event, response) {
                              if (event.isInterestedForInteractions &&
                                  response != null &&
                                  response.spot != null) {
                                setState(() {
                                  _selectedMonthIndex = response.spot!.touchedBarGroupIndex;
                                });
                              }
                            },
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.grey.shade800,
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final month = widget.sortedMonths[group.x.toInt()];
                                final total = widget.monthlyData[month]!.values.fold<double>(0, (sum, v) => sum + v);
                                return BarTooltipItem(
                                  '${DateFormat('MMM yyyy').format(month)}\n${widget.currencySymbol}${NumberFormat('#,##0').format(total)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < widget.sortedMonths.length) {
                                    final isSelected = index == _selectedMonthIndex;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        DateFormat('MMM').format(widget.sortedMonths[index]),
                                        style: TextStyle(
                                          color: isSelected
                                              ? widget.accentColor
                                              : AppColors.textSecondaryLight,
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: widget.sortedMonths.asMap().entries.map((entry) {
                            final index = entry.key;
                            final month = entry.value;
                            final monthData = widget.monthlyData[month]!;
                            final isSelected = index == _selectedMonthIndex;

                            // Build stacked rod data
                            final rodStackItems = <BarChartRodStackItem>[];
                            double fromY = 0;

                            for (final categoryId in widget.sortedCategoryIds) {
                              final value = (monthData[categoryId] ?? 0) * _animation.value;
                              if (value > 0) {
                                final category = widget.categoryMap[categoryId];
                                var color = category != null
                                    ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                                    : Colors.grey;
                                if (!isSelected) {
                                  color = color.withValues(alpha: 0.5);
                                }

                                rodStackItems.add(BarChartRodStackItem(
                                  fromY,
                                  fromY + value,
                                  color,
                                ));
                                fromY += value;
                              }
                            }

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: fromY,
                                  rodStackItems: rodStackItems,
                                  width: isSelected ? 36 : 28,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            // Selected month details
            if (selectedMonth != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(selectedMonth),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${widget.currencySymbol}${NumberFormat('#,##0').format(selectedMonthTotal)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.accentColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.sortedCategoryIds.length,
                          itemBuilder: (context, index) {
                            final categoryId = widget.sortedCategoryIds[index];
                            final amount = selectedMonthData[categoryId] ?? 0;
                            if (amount == 0) return const SizedBox.shrink();

                            final category = widget.categoryMap[categoryId];
                            final color = category != null
                                ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                                : Colors.grey;
                            final name = category?.name ?? 'Other';
                            final percentage = selectedMonthTotal > 0
                                ? (amount / selectedMonthTotal * 100)
                                : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    '${widget.currencySymbol}${NumberFormat('#,##0').format(amount)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textSecondaryLight,
                                          ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: (100 + index * 50).ms).slideX(begin: 0.1);
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: accentColor,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _YearlyStackedChart extends ConsumerStatefulWidget {
  final String currencySymbol;
  final List<Category> categories;
  final Color accentColor;

  const _YearlyStackedChart({
    required this.currencySymbol,
    required this.categories,
    required this.accentColor,
  });

  @override
  ConsumerState<_YearlyStackedChart> createState() => _YearlyStackedChartState();
}

class _YearlyStackedChartState extends ConsumerState<_YearlyStackedChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(insightsLast12MonthsProvider);

    return expensesAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return _EmptyState(message: 'No data for yearly comparison');
        }

        final now = DateTime.now();
        final categoryMap = {for (var c in widget.categories) c.id: c};

        // Initialize years with category breakdowns
        final yearlyData = <int, Map<int?, double>>{
          now.year - 1: {},
          now.year: {},
        };

        // Group expenses by year and category
        for (final expense in expenses) {
          final year = expense.createdAt.year;
          if (yearlyData.containsKey(year)) {
            yearlyData[year]![expense.categoryId] =
                (yearlyData[year]![expense.categoryId] ?? 0) + expense.amount;
          }
        }

        // Only show if there's data
        if (yearlyData.values.every((m) => m.isEmpty)) {
          return _EmptyState(message: 'No data for yearly comparison');
        }

        final sortedYears = yearlyData.keys.toList()..sort();

        // Get all unique categories used
        final usedCategoryIds = <int?>{};
        for (final yearData in yearlyData.values) {
          usedCategoryIds.addAll(yearData.keys);
        }
        final sortedCategoryIds = usedCategoryIds.toList();

        // Calculate max total for scaling
        double maxTotal = 0;
        for (final yearData in yearlyData.values) {
          final total = yearData.values.fold<double>(0, (sum, v) => sum + v);
          if (total > maxTotal) maxTotal = total;
        }

        // Calculate year-over-year change
        final currentYearTotal = yearlyData[now.year]!.values.fold<double>(0, (sum, v) => sum + v);
        final lastYearTotal = yearlyData[now.year - 1]!.values.fold<double>(0, (sum, v) => sum + v);
        final percentChange = lastYearTotal > 0
            ? ((currentYearTotal - lastYearTotal) / lastYearTotal * 100)
            : 0.0;

        return GestureDetector(
          onTap: () => _openExpandedView(
            context,
            yearlyData: yearlyData,
            sortedYears: sortedYears,
            sortedCategoryIds: sortedCategoryIds,
            categoryMap: categoryMap,
            maxTotal: maxTotal,
            percentChange: percentChange,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yearly Comparison',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This year vs last year',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (lastYearTotal > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: percentChange >= 0
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  percentChange >= 0
                                      ? PhosphorIcons.trendUp()
                                      : PhosphorIcons.trendDown(),
                                  size: 16,
                                  color: percentChange >= 0 ? Colors.red : Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${percentChange.abs().toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: percentChange >= 0 ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          PhosphorIcons.arrowsOut(),
                          size: 20,
                          color: AppColors.textSecondaryLight,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _buildBarChart(
                        yearlyData: yearlyData,
                        sortedYears: sortedYears,
                        sortedCategoryIds: sortedCategoryIds,
                        categoryMap: categoryMap,
                        maxTotal: maxTotal,
                        animationValue: _animation.value,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Year totals
                Row(
                  children: sortedYears.map((year) {
                    final total = yearlyData[year]!.values.fold<double>(0, (sum, v) => sum + v);
                    final isCurrentYear = year == now.year;
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${widget.currencySymbol}${NumberFormat('#,##0').format(total)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentYear ? widget.accentColor : AppColors.textSecondaryLight,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCurrentYear ? 'This Year' : 'Last Year',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Legend
                _CategoryLegend(
                  categoryIds: sortedCategoryIds,
                  categoryMap: categoryMap,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildBarChart({
    required Map<int, Map<int?, double>> yearlyData,
    required List<int> sortedYears,
    required List<int?> sortedCategoryIds,
    required Map<int, Category> categoryMap,
    required double maxTotal,
    required double animationValue,
  }) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxTotal * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey.shade800,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final year = sortedYears[group.x.toInt()];
              final total = yearlyData[year]!.values.fold<double>(0, (sum, v) => sum + v);
              return BarTooltipItem(
                '$year\n${widget.currencySymbol}${NumberFormat('#,##0').format(total)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedYears.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sortedYears[index].toString(),
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: sortedYears.asMap().entries.map((entry) {
          final index = entry.key;
          final year = entry.value;
          final yearData = yearlyData[year]!;

          // Build stacked rod data
          final rodStackItems = <BarChartRodStackItem>[];
          double fromY = 0;

          for (final categoryId in sortedCategoryIds) {
            final value = (yearData[categoryId] ?? 0) * animationValue;
            if (value > 0) {
              final category = categoryMap[categoryId];
              final color = category != null
                  ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                  : Colors.grey;

              rodStackItems.add(BarChartRodStackItem(
                fromY,
                fromY + value,
                color,
              ));
              fromY += value;
            }
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: fromY,
                rodStackItems: rodStackItems,
                width: 60,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _openExpandedView(
    BuildContext context, {
    required Map<int, Map<int?, double>> yearlyData,
    required List<int> sortedYears,
    required List<int?> sortedCategoryIds,
    required Map<int, Category> categoryMap,
    required double maxTotal,
    required double percentChange,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return _YearlyExpandedView(
            currencySymbol: widget.currencySymbol,
            yearlyData: yearlyData,
            sortedYears: sortedYears,
            sortedCategoryIds: sortedCategoryIds,
            categoryMap: categoryMap,
            maxTotal: maxTotal,
            percentChange: percentChange,
            accentColor: widget.accentColor,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _YearlyExpandedView extends StatefulWidget {
  final String currencySymbol;
  final Map<int, Map<int?, double>> yearlyData;
  final List<int> sortedYears;
  final List<int?> sortedCategoryIds;
  final Map<int, Category> categoryMap;
  final double maxTotal;
  final double percentChange;
  final Color accentColor;

  const _YearlyExpandedView({
    required this.currencySymbol,
    required this.yearlyData,
    required this.sortedYears,
    required this.sortedCategoryIds,
    required this.categoryMap,
    required this.maxTotal,
    required this.percentChange,
    required this.accentColor,
  });

  @override
  State<_YearlyExpandedView> createState() => _YearlyExpandedViewState();
}

class _YearlyExpandedViewState extends State<_YearlyExpandedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedYearIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
    // Select current year by default
    _selectedYearIndex = widget.sortedYears.length - 1;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // Calculate totals
    final currentYearTotal = widget.yearlyData[now.year]!.values.fold<double>(0, (sum, v) => sum + v);
    final lastYearTotal = widget.yearlyData[now.year - 1]!.values.fold<double>(0, (sum, v) => sum + v);

    // Get selected year data
    final selectedYear = _selectedYearIndex != null
        ? widget.sortedYears[_selectedYearIndex!]
        : null;
    final selectedYearData = selectedYear != null
        ? widget.yearlyData[selectedYear]!
        : <int?, double>{};
    final selectedYearTotal = selectedYearData.values.fold<double>(0, (sum, v) => sum + v);

    // Calculate category YoY changes
    final categoryChanges = <int?, double>{};
    for (final categoryId in widget.sortedCategoryIds) {
      final currentAmount = widget.yearlyData[now.year]![categoryId] ?? 0;
      final lastAmount = widget.yearlyData[now.year - 1]![categoryId] ?? 0;
      if (lastAmount > 0) {
        categoryChanges[categoryId] = ((currentAmount - lastAmount) / lastAmount * 100);
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        PhosphorIcons.arrowLeft(),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yearly Comparison',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Year-over-year breakdown',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (lastYearTotal > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.percentChange >= 0
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.percentChange >= 0
                                ? PhosphorIcons.trendUp()
                                : PhosphorIcons.trendDown(),
                            size: 18,
                            color: widget.percentChange >= 0 ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.percentChange.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: widget.percentChange >= 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Summary cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: '${now.year - 1}',
                      value: '${widget.currencySymbol}${NumberFormat('#,##0').format(lastYearTotal)}',
                      icon: PhosphorIcons.calendar(),
                      accentColor: widget.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: '${now.year}',
                      value: '${widget.currencySymbol}${NumberFormat('#,##0').format(currentYearTotal)}',
                      icon: PhosphorIcons.calendarCheck(),
                      accentColor: widget.accentColor,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            // Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 200,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: widget.maxTotal * 1.1,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchCallback: (event, response) {
                              if (event.isInterestedForInteractions &&
                                  response != null &&
                                  response.spot != null) {
                                setState(() {
                                  _selectedYearIndex = response.spot!.touchedBarGroupIndex;
                                });
                              }
                            },
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.grey.shade800,
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final year = widget.sortedYears[group.x.toInt()];
                                final total = widget.yearlyData[year]!.values.fold<double>(0, (sum, v) => sum + v);
                                return BarTooltipItem(
                                  '$year\n${widget.currencySymbol}${NumberFormat('#,##0').format(total)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < widget.sortedYears.length) {
                                    final isSelected = index == _selectedYearIndex;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        widget.sortedYears[index].toString(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? widget.accentColor
                                              : AppColors.textSecondaryLight,
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: widget.sortedYears.asMap().entries.map((entry) {
                            final index = entry.key;
                            final year = entry.value;
                            final yearData = widget.yearlyData[year]!;
                            final isSelected = index == _selectedYearIndex;

                            // Build stacked rod data
                            final rodStackItems = <BarChartRodStackItem>[];
                            double fromY = 0;

                            for (final categoryId in widget.sortedCategoryIds) {
                              final value = (yearData[categoryId] ?? 0) * _animation.value;
                              if (value > 0) {
                                final category = widget.categoryMap[categoryId];
                                var color = category != null
                                    ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                                    : Colors.grey;
                                if (!isSelected) {
                                  color = color.withValues(alpha: 0.5);
                                }

                                rodStackItems.add(BarChartRodStackItem(
                                  fromY,
                                  fromY + value,
                                  color,
                                ));
                                fromY += value;
                              }
                            }

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: fromY,
                                  rodStackItems: rodStackItems,
                                  width: isSelected ? 80 : 60,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            // Selected year details with YoY change
            if (selectedYear != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$selectedYear Breakdown',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${widget.currencySymbol}${NumberFormat('#,##0').format(selectedYearTotal)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.accentColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.sortedCategoryIds.length,
                          itemBuilder: (context, index) {
                            final categoryId = widget.sortedCategoryIds[index];
                            final amount = selectedYearData[categoryId] ?? 0;
                            if (amount == 0) return const SizedBox.shrink();

                            final category = widget.categoryMap[categoryId];
                            final color = category != null
                                ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
                                : Colors.grey;
                            final name = category?.name ?? 'Other';
                            final percentage = selectedYearTotal > 0
                                ? (amount / selectedYearTotal * 100)
                                : 0.0;
                            final yoyChange = categoryChanges[categoryId];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        if (yoyChange != null && selectedYear == now.year)
                                          Text(
                                            '${yoyChange >= 0 ? '+' : ''}${yoyChange.toStringAsFixed(0)}% vs last year',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: yoyChange >= 0 ? Colors.red : Colors.green,
                                                  fontSize: 11,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${widget.currencySymbol}${NumberFormat('#,##0').format(amount)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textSecondaryLight,
                                          ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: (100 + index * 50).ms).slideX(begin: 0.1);
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final List<int?> categoryIds;
  final Map<int, Category> categoryMap;

  const _CategoryLegend({
    required this.categoryIds,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryIds.take(6).map((categoryId) {
        final category = categoryMap[categoryId];
        final color = category != null
            ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
            : Colors.grey;
        final name = category?.name ?? 'Other';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              PhosphorIcons.chartBar(),
              size: 48,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
