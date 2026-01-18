import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/constants/constants.dart';
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
                      color: color.withValues(alpha: 0.15),
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
                          backgroundColor: color.withValues(alpha: 0.15),
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
