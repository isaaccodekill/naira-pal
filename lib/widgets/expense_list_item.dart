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
                color: color.withValues(alpha: 0.15),
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
          error: (_, _) => const SizedBox(width: 44, height: 44),
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
              error: (_, _) => const Text('Unknown'),
            ),
            if (expense.note != null && expense.note!.isNotEmpty)
              Text(
                expense.note!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
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
