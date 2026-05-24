import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconly/iconly.dart';

import '../../main.dart';
import 'dashboard_view.dart';
import 'products_view.dart';
import 'orders_view.dart';
import 'settings_view.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = <Widget>[
      const DashboardView(),
      const ProductsView(),
      const OrdersView(),
      const AdminSettingsView(),
    ];

    final icons = <IconData>[
      IconlyLight.graph,
      IconlyLight.bag,
      IconlyLight.buy,
      IconlyLight.setting,
    ];
    final activeIcons = <IconData>[
      IconlyBold.graph,
      IconlyBold.bag,
      IconlyBold.buy,
      IconlyBold.setting,
    ];

    final fillColor = isDark
        ? const Color(0xFF2A2A2E).withValues(alpha: 0.42)
        : Colors.white.withValues(alpha: 0.58);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.92);
    final activeRingColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.95);

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
        backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7),
        body: Stack(
          children: [
            // Background Gradient for depth
            if (isDark)
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.08),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            
            Column(
              children: [
                // Main content
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: screens,
                  ),
                ),
                // Glassmorphic bottom nav
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tabWidth = constraints.maxWidth / 4;
                        final targetLeft =
                            (tabWidth * _selectedIndex) +
                                (tabWidth - 56) / 2;

                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: targetLeft),
                          duration:
                              const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          builder: (ctx, animLeft, _) {
                            final activeX = animLeft + 28.0;
                            return SizedBox(
                              height: 68,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomCenter,
                                children: [
                                  // Bar body
                                  ClipPath(
                                    clipper:
                                        TabBarClipper(activeX: activeX),
                                    child: SizedBox(
                                      height: 68,
                                      width: double.infinity,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 40, sigmaY: 40),
                                              child: const ColoredBox(
                                                  color:
                                                      Color(0x01FFFFFF)),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin:
                                                    Alignment.topCenter,
                                                end: Alignment
                                                    .bottomCenter,
                                                colors: isDark
                                                    ? [
                                                        Colors.white
                                                            .withValues(
                                                                alpha: 0.14),
                                                        Colors.white
                                                            .withValues(
                                                                alpha: 0.04),
                                                        Colors.black
                                                            .withValues(
                                                                alpha: 0.18),
                                                      ]
                                                    : [
                                                        Colors.white
                                                            .withValues(
                                                                alpha: 0.78),
                                                        Colors.white
                                                            .withValues(
                                                                alpha: 0.52),
                                                        Colors.white
                                                            .withValues(
                                                                alpha: 0.38),
                                                      ],
                                                stops: const [
                                                  0.0,
                                                  0.42,
                                                  1.0
                                                ],
                                              ),
                                            ),
                                          ),
                                          CustomPaint(
                                            painter: TabBarPainter(
                                              activeX: activeX,
                                              isDark: isDark,
                                              borderColor: borderColor,
                                              fillColor: fillColor,
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(4,
                                                (idx) {
                                              final sel =
                                                  _selectedIndex == idx;
                                              final inactive = isDark
                                                  ? Colors.white
                                                      .withValues(alpha: 0.42)
                                                  : const Color(
                                                      0xFF8E8E93);
                                              return Expanded(
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .opaque,
                                                  onTap: () => setState(() =>
                                                      _selectedIndex = idx),
                                                  child: Center(
                                                    child: sel
                                                        ? const SizedBox
                                                            .shrink()
                                                        : Icon(icons[idx],
                                                            size: 24,
                                                            color: inactive),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Floating active bubble
                                  Positioned(
                                    left: animLeft,
                                    top: -14,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(
                                          () => _selectedIndex =
                                              _selectedIndex),
                                      child: Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF5EB0FF),
                                              AppColors.primary,
                                              Color(0xFF0055CC),
                                            ],
                                            stops: [0.0, 0.5, 1.0],
                                          ),
                                          border: Border.all(
                                              color: activeRingColor,
                                              width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.45),
                                              blurRadius: 22,
                                              offset: const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: Colors.white
                                                  .withValues(
                                                      alpha: isDark
                                                          ? 0.12
                                                          : 0.55),
                                              blurRadius: 6,
                                              offset:
                                                  const Offset(-2, -3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            activeIcons[_selectedIndex],
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}