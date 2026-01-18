import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/constants/constants.dart';
import '../../core/theme/theme.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../widgets/numpad.dart';
import '../../widgets/category_chips.dart';

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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

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
              Text(
                _amount,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ).animate().fadeIn(duration: 150.ms),
            ],
          ),
          const SizedBox(height: 24),

          // Category chips
          CategoryChips(
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (id) {
              setState(() {
                _selectedCategoryId = id;
              });
            },
          ),
          const SizedBox(height: 16),

          // Note field toggle
          if (!_showNoteField)
            TextButton.icon(
              onPressed: () => setState(() => _showNoteField = true),
              icon: const Icon(Icons.add),
              label: const Text('Add note'),
            )
          else
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _note = value,
              autofocus: true,
            ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 24),

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
          SizedBox(height: MediaQuery.of(context).padding.bottom),
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
