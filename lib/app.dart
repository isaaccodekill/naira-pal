import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/theme/theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class NairaPalApp extends ConsumerWidget {
  const NairaPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NairaPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const _MainShell(),
    );
  }
}

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeScreen(),
          HistoryScreen(),
          SettingsScreen(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: selectedTab,
        onTap: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: bottomPadding + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: PhosphorIcons.house(),
              selectedIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
              label: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: PhosphorIcons.clockCounterClockwise(),
              selectedIcon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill),
              label: 'History',
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: PhosphorIcons.gear(),
              selectedIcon: PhosphorIcons.gear(PhosphorIconsStyle.fill),
              label: 'Settings',
              isSelected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                size: 24,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.2)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
