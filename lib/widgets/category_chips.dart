import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/database/database.dart';
import '../providers/providers.dart';

class CategoryChips extends ConsumerWidget {
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...categories.map((cat) => _CategoryChip(
                category: cat,
                isSelected: selectedCategoryId == cat.id,
                onTap: () => onCategorySelected(cat.id),
              )),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
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
    final color = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        _getIcon(category.icon),
        size: 18,
        color: isSelected ? Colors.white : color,
      ),
      label: Text(category.name),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }
}
