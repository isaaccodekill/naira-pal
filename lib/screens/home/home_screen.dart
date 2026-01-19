import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/constants.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';
import '../entry/entry_sheet.dart';

// Provider for last 30 days data
final last30DaysProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final thirtyDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
  // Use end of today to include all expenses added today
  final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return db.expenseDao.watchExpensesBetween(thirtyDaysAgo, endOfToday);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(last30DaysProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final settings = ref.watch(settingsProvider);

    final currencySymbol = settings.maybeWhen(
      data: (s) => Currencies.fromCode(s?.defaultCurrency ?? 'NGN').symbol,
      orElse: () => '₦',
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total spent card with Add button
              expensesAsync.when(
                data: (expenses) {
                  final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
                  final accentColor = ref.watch(accentColorProvider);
                  return _TotalSpentCard(
                    total: total,
                    currencySymbol: currencySymbol,
                    onAddTap: () => showEntrySheet(context),
                    categoryColor: expenses.isNotEmpty ? accentColor : null,
                  );
                },
                loading: () => _TotalSpentCard(
                  total: 0,
                  currencySymbol: currencySymbol,
                  onAddTap: () => showEntrySheet(context),
                  isLoading: true,
                ),
                error: (_, _) => _TotalSpentCard(
                  total: 0,
                  currencySymbol: currencySymbol,
                  onAddTap: () => showEntrySheet(context),
                ),
              ),
              const SizedBox(height: 20),

              // Top Category Card
              expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) return const SizedBox.shrink();
                  return categoriesAsync.when(
                    data: (categories) => _TopCategoryCard(
                      expenses: expenses,
                      categories: categories,
                      currencySymbol: currencySymbol,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Recent expenses header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recent expenses list
              expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
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
                              PhosphorIcons.receipt(),
                              size: 48,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No expenses yet',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap Add Expense to get started',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return categoriesAsync.when(
                    data: (categories) => _RecentExpensesList(
                      expenses: expenses.take(5).toList(),
                      categories: categories,
                      currencySymbol: currencySymbol,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Text('Error'),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Text('Error loading expenses'),
              ),

              // Space for bottom nav
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalSpentCard extends StatelessWidget {
  final double total;
  final String currencySymbol;
  final VoidCallback onAddTap;
  final bool isLoading;
  final Color? categoryColor;

  const _TotalSpentCard({
    required this.total,
    required this.currencySymbol,
    required this.onAddTap,
    this.isLoading = false,
    this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use category color or fallback to primary, with lighter pastel appearance
    final baseColor = categoryColor ?? AppColors.primary;
    // Create a more muted/lighter version for the background
    final cardColor = HSLColor.fromColor(baseColor)
        .withSaturation(0.35)
        .withLightness(0.65)
        .toColor();
    final cardColorDark = HSLColor.fromColor(baseColor)
        .withSaturation(0.30)
        .withLightness(0.60)
        .toColor();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColorDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Spent',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
              Text(
                'Last 30 days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          isLoading
              ? const SizedBox(
                  height: 48,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : Text(
                  '$currencySymbol${NumberFormat('#,##0').format(total)}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 20),
          // Add Button with semi-transparent white background
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAddTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                foregroundColor: cardColorDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold)),
              label: const Text(
                'Add Expense',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

class _TopCategoryCard extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;

  const _TopCategoryCard({
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
    for (final expense in expenses) {
      byCategory[expense.categoryId] = (byCategory[expense.categoryId] ?? 0) + expense.amount;
    }

    if (byCategory.isEmpty) return const SizedBox.shrink();

    // Find top category
    final sortedEntries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntry = sortedEntries.first;
    final total = byCategory.values.fold<double>(0, (sum, v) => sum + v);
    final percentage = (topEntry.value / total * 100).toStringAsFixed(0);

    final categoryMap = {for (var c in categories) c.id: c};
    final topCategory = categoryMap[topEntry.key];
    final color = topCategory != null
        ? Color(int.parse(topCategory.color.replaceFirst('#', '0xFF')))
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(topCategory?.icon ?? 'dots_three'),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Category',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  topCategory?.name ?? 'Uncategorized',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currencySymbol${NumberFormat('#,##0').format(topEntry.value)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(
                '$percentage% of total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05);
  }
}

class _RecentExpensesList extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;

  const _RecentExpensesList({
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
    final categoryMap = {for (var c in categories) c.id: c};
    final timeFormat = DateFormat.jm();
    final dateFormat = DateFormat.MMMd();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: expenses.asMap().entries.map((entry) {
          final index = entry.key;
          final expense = entry.value;
          final category = categoryMap[expense.categoryId];
          final color = category != null
              ? Color(int.parse(category.color.replaceFirst('#', '0xFF')))
              : Colors.grey;

          final isToday = DateUtils.isSameDay(expense.createdAt, DateTime.now());
          final dateStr = isToday
              ? timeFormat.format(expense.createdAt)
              : dateFormat.format(expense.createdAt);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIcon(category?.icon ?? 'dots_three'),
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? 'Uncategorized',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          if (expense.note != null && expense.note!.isNotEmpty)
                            Text(
                              expense.note!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currencySymbol${NumberFormat('#,##0').format(expense.amount)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          dateStr,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (index < expenses.length - 1)
                Divider(height: 1, indent: 72, color: Colors.grey.withValues(alpha: 0.1)),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}
