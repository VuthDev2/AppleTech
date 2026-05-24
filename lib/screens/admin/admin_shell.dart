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
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 15),
        (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildStatusBar(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? Colors.white : Colors.black87;
    final safeTop = MediaQuery.paddingOf(context).top;

    if (isIOS) {
      return SizedBox(
        height: safeTop > 0 ? safeTop : 20.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatTime(_now),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Signal bars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(4, (i) {
                        final active = i < 3;
                        return Container(
                          width: 2.8,
                          height: 3.5 + (i * 2.2),
                          margin: const EdgeInsets.only(left: 1.8),
                          decoration: BoxDecoration(
                            color: active
                                ? barColor
                                : barColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(0.5),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 5),
                    Icon(CupertinoIcons.wifi, size: 14, color: barColor),
                    const SizedBox(width: 5),
                    // Battery
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 11,
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: barColor.withValues(alpha: 0.8),
                                width: 1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 0.88,
                            child: Container(
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(1.2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 0.5),
                        Container(
                          width: 1,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: barColor.withValues(alpha: 0.8),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(0.8),
                              bottomRight: Radius.circular(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox(
        height: safeTop > 0 ? safeTop : 24.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                _formatTime(_now),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
              const Spacer(),
              Icon(Icons.wifi, size: 14, color: barColor),
              const SizedBox(width: 6),
              Icon(Icons.signal_cellular_4_bar_rounded,
                  size: 14, color: barColor),
              const SizedBox(width: 4),
              Container(
                width: 9,
                height: 13.5,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: barColor.withValues(alpha: 0.8), width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: const EdgeInsets.all(0.8),
                child: Container(color: barColor),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildHomeIndicator(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final barColor = isDark
        ? Colors.white.withValues(alpha: 0.82)
        : Colors.black.withValues(alpha: 0.72);

    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom:
            bottomInset > 0 ? math.max(bottomInset - 6, 4) : 12,
      ),
      child: Center(
        child: Container(
          width: isIOS ? 134 : 96,
          height: isIOS ? 5 : 3.5,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Status bar
          ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: _buildStatusBar(context),
          ),
          // Main content
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
            ),
          ),
          // Glassmorphic bottom nav
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
          _buildHomeIndicator(context),
        ],
      ),
    );
  }
}