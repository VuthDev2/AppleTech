import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'dashboard_view.dart';
import 'orders_view.dart';
import 'products_view.dart';
import 'settings_view.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    DashboardView(),
    OrdersView(),
    ProductsView(),
    AdminSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark
          ? const Color(0xFF050505)
          : const Color(0xFFF5F5F7),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            height: 68,
            elevation: 0,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.96),
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.16),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(IconlyLight.chart),
                selectedIcon: Icon(IconlyBold.chart),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(IconlyLight.buy),
                selectedIcon: Icon(IconlyBold.buy),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(IconlyLight.bag),
                selectedIcon: Icon(IconlyBold.bag),
                label: 'Products',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.gear_alt),
                selectedIcon: Icon(CupertinoIcons.gear_alt_fill),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
