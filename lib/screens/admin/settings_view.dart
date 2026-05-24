import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconly/iconly.dart';

import '../../main.dart';
import 'admin_widgets.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const AdminSliverHeader(
            title: 'Settings',
            subtitle: 'Manage admin preferences.',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin profile card
                  _buildProfileCard(context, store, isDark),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Appearance section
                  _SectionTitle(title: 'Appearance'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingRow(
                    icon: isDark
                        ? CupertinoIcons.sun_max_fill
                        : CupertinoIcons.moon_fill,
                    iconColor: isDark
                        ? AppColors.accent
                        : AppColors.primary,
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Enabled' : 'Disabled',
                    trailing: Switch.adaptive(
                      value: isDark,
                      onChanged: (_) => store.toggleTheme(),
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Store section
                  _SectionTitle(title: 'Store'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingRow(
                    icon: IconlyLight.bag,
                    iconColor: AppColors.primary,
                    title: 'Products',
                    subtitle: 'Manage your product catalog',
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface
                          .withOpacity(0.3),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingRow(
                    icon: IconlyLight.buy,
                    iconColor: AppColors.accent,
                    title: 'Orders',
                    subtitle: 'View and process orders',
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface
                          .withOpacity(0.3),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Danger zone
                  _SectionTitle(title: 'Account'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingRow(
                    icon: IconlyLight.logout,
                    iconColor: AppColors.error,
                    title: 'Sign Out',
                    subtitle: 'Log out of admin portal',
                    trailing: const SizedBox.shrink(),
                    onTap: () => _confirmSignOut(context),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, AppStore store, bool isDark) {
    final theme = Theme.of(context);
    final user = store.user;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.14),
            AppColors.primary.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5EB0FF),
                  AppColors.primary,
                  Color(0xFF0055CC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'A'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Administrator',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'admin@appletech.com',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    '● Admin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
            'Are you sure you want to sign out of the admin portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseAuth.instance.signOut();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.mediumGray,
          ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor.withOpacity(0.8) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: isDark ? [] : appShadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
