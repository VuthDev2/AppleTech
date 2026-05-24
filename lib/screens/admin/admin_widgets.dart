import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../main.dart';

/// Shared glassmorphic SliverAppBar used by all admin views.
class AdminSliverHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? trailingActions;

  const AdminSliverHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailingActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 148,
      collapsedHeight: 72,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface0.withOpacity(0.82)
                  : Colors.white.withOpacity(0.88),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: branding + actions
                  Row(
                    children: [
                      // Apple logo badge
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5EB0FF), AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.apple, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Admin Portal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      // Theme toggle button wired to AppScope
                      _AdminIconButton(
                        icon: isDark
                            ? CupertinoIcons.sun_max_fill
                            : CupertinoIcons.moon_fill,
                        onTap: () => AppScope.of(context).toggleTheme(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (trailingActions != null) ...trailingActions!,
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Page title + subtitle
                  Text(
                    title,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable circular icon button for admin headers.
class _AdminIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AdminIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.07),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
