import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/constants/constants.dart';
import '../../core/theme/theme.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../widgets/numpad.dart';

class EntrySheet extends ConsumerStatefulWidget {
  const EntrySheet({super.key});

  @override
  ConsumerState<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<EntrySheet> {
  String _amount = '0';
  int? _selectedCategoryId;
  String _note = '';
  String _currency = 'NGN';
  bool _showNoteField = false;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDefaultCurrency();
  }

  Future<void> _loadDefaultCurrency() async {
    final settings = await ref.read(settingsProvider.future);
    if (settings != null && mounted) {
      setState(() {
        _currency = settings.defaultCurrency;
      });
    }
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_amount == '0' && key != '.') {
        _amount = key;
      } else if (key == '.' && _amount.contains('.')) {
        return;
      } else if (_amount.contains('.') && _amount.split('.')[1].length >= 2) {
        return;
      } else {
        _amount += key;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _onClear() {
    setState(() {
      _amount = '0';
    });
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) {
      return;
    }

    final db = ref.read(databaseProvider);
    await db.expenseDao.insertExpense(ExpensesCompanion.insert(
      amount: amount,
      currency: _currency,
      categoryId: Value(_selectedCategoryId),
      note: Value(_note.isEmpty ? null : _note),
    ));

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = Currencies.fromCode(_currency).symbol;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),

                  // Amount display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencySymbol,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _amount,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ).animate().fadeIn(duration: 150.ms),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category chips - horizontally scrollable
                  SizedBox(
                    height: 44,
                    child: _HorizontalCategoryChips(
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: (id) {
                        setState(() {
                          _selectedCategoryId = id;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Note field toggle
                  if (!_showNoteField)
                    TextButton.icon(
                      onPressed: () => setState(() => _showNoteField = true),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add note'),
                    )
                  else
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) => _note = value,
                      autofocus: true,
                    ).animate().fadeIn().slideY(begin: -0.1),

                  const SizedBox(height: 20),

                  // Numpad
                  Numpad(
                    onKeyPressed: _onKeyPressed,
                    onBackspace: _onBackspace,
                    onClear: _onClear,
                  ),
                  const SizedBox(height: 16),

                  // Done button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _amount != '0' ? _saveExpense : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  SizedBox(height: bottomPadding + 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

void showEntrySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const EntrySheet(),
  );
}

class _HorizontalCategoryChips extends ConsumerWidget {
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const _HorizontalCategoryChips({
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fork_knife':
        return Icons.restaurant;
      case 'car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'file_text':
        return Icons.description;
      case 'film_strip':
        return Icons.movie;
      case 'pill':
        return Icons.medical_services;
      case 'book_open':
        return Icons.menu_book;
      case 'gift':
        return Icons.card_giftcard;
      case 'shopping_cart':
        return Icons.shopping_cart;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryId == category.id;
          final color = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

          return GestureDetector(
            onTap: () => onCategorySelected(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? color : color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(category.icon),
                    size: 18,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
