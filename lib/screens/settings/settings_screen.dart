import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/constants/constants.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),

              // Currency
              Text(
                'Currency',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              settingsAsync.when(
                data: (settings) => _CurrencySelector(
                  currentCurrency: settings?.defaultCurrency ?? 'NGN',
                  onChanged: (currency) async {
                    final db = ref.read(databaseProvider);
                    await db.settingsDao.updateSettings(
                      UserSettingsCompanion(defaultCurrency: Value(currency)),
                    );
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Categories
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(PhosphorIcons.squaresFour()),
                title: const Text('Categories'),
                subtitle: const Text('Manage expense categories'),
                trailing: Icon(PhosphorIcons.caretRight()),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _CategoriesScreen()),
                  );
                },
              ),
              const Divider(),

              // Premium
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(PhosphorIcons.crown()),
                title: const Text('Premium'),
                subtitle: const Text('Unlock budgets and more'),
                trailing: Icon(PhosphorIcons.caretRight()),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
              const Divider(),

              // Export
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(PhosphorIcons.export()),
                title: const Text('Export Data'),
                subtitle: const Text('Download your expenses'),
                trailing: Icon(PhosphorIcons.caretRight()),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                },
              ),
              const Divider(),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'NairaPal v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final String currentCurrency;
  final Function(String) onChanged;

  const _CurrencySelector({
    required this.currentCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Currencies.all.map((currency) {
        final isSelected = currency.code == currentCurrency;
        return ChoiceChip(
          selected: isSelected,
          onSelected: (_) => onChanged(currency.code),
          label: Text('${currency.symbol} ${currency.code}'),
        );
      }).toList(),
    );
  }
}

class _CategoriesScreen extends ConsumerWidget {
  const _CategoriesScreen();

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
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoriesAsync.when(
        data: (categories) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final color = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(category.icon),
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(category.name),
              trailing: category.isDefault
                  ? null
                  : IconButton(
                      icon: Icon(PhosphorIcons.trash()),
                      onPressed: () async {
                        final db = ref.read(databaseProvider);
                        await db.categoryDao.archiveCategory(category.id);
                      },
                    ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
