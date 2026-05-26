import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';

import '../../core/app_colors.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: IconlyLight.chart,
                        activeIcon: IconlyBold.chart,
                        label: 'Dashboard',
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                        isDark: isDark,
                      ),
                      _NavItem(
                        icon: IconlyLight.buy,
                        activeIcon: IconlyBold.buy,
                        label: 'Orders',
                        isSelected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                        isDark: isDark,
                      ),
                      _NavItem(
                        icon: IconlyLight.bag,
                        activeIcon: IconlyBold.bag,
                        label: 'Products',
                        isSelected: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                        isDark: isDark,
                      ),
                      _NavItem(
                        icon: CupertinoIcons.gear_alt,
                        activeIcon: CupertinoIcons.gear_alt_fill,
                        label: 'Settings',
                        isSelected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? (isDark ? Colors.white : AppColors.primary)
        : (isDark ? Colors.white54 : AppColors.mediumGray);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? Colors.white.withOpacity(0.15) : AppColors.primary.withOpacity(0.1)) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
