import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'core/theme/theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class NairaPalApp extends ConsumerWidget {
  const NairaPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    final screens = [
      const HomeScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return MaterialApp(
      title: 'NairaPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: IndexedStack(
          index: selectedTab,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: (index) {
            ref.read(selectedTabProvider.notifier).state = index;
          },
          destinations: [
            NavigationDestination(
              icon: Icon(PhosphorIcons.house()),
              selectedIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.clockCounterClockwise()),
              selectedIcon: Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill)),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIcons.gear()),
              selectedIcon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.fill)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
