import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconly/iconly.dart';

import '../../main.dart';
import 'admin_widgets.dart';
import 'package:appletech/l10n/app_localizations.dart';

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
            subtitle: 'Configure your administration.',
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Admin profile card
                _buildProfileCard(context, store, isDark),
                const SizedBox(height: AppSpacing.xxxl),

                // Appearance section
                _SectionTitle(title: 'Appearance'),
                const SizedBox(height: AppSpacing.md),
                _SettingRow(
                  icon: isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                  iconColor: isDark ? const Color(0xFFFFB81C) : AppColors.primary,
                  title: 'Dark Mode',
                  subtitle: isDark ? 'Brighter interface' : 'Battery saving mode',
                  trailing: Switch.adaptive(
                    value: isDark,
                    onChanged: (_) => store.toggleTheme(),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Store Configuration
                _SectionTitle(title: 'Store Configuration'),
                const SizedBox(height: AppSpacing.md),
                _SettingRow(
                  icon: IconlyBold.shield_done,
                  iconColor: AppColors.success,
                  title: 'Store Status',
                  subtitle: 'Online and accepting orders',
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.mediumGray),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SettingRow(
                  icon: IconlyBold.notification,
                  iconColor: AppColors.primary,
                  title: 'Push Notifications',
                  subtitle: 'Alerts for new customer orders',
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.mediumGray),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Account
                _SectionTitle(title: 'Account Management'),
                const SizedBox(height: AppSpacing.md),
                _SettingRow(
                  icon: IconlyBold.lock,
                  iconColor: AppColors.accent,
                  title: 'Security',
                  subtitle: 'Update password and keys',
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.mediumGray),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SettingRow(
                  icon: IconlyBold.logout,
                  iconColor: AppColors.error,
                  title: 'Sign Out',
                  subtitle: 'Exit the administration portal',
                  trailing: const SizedBox.shrink(),
                  onTap: () => _confirmSignOut(context),
                ),
                
                const SizedBox(height: 140),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppStore store, bool isDark) {
    final theme = Theme.of(context);
    final user = store.user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          StoreUserAvatar(
            name: user?.name ?? 'Admin',
            photoUrl: user?.photoUrl,
            size: 60,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Administrator',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'admin@appletech.com',
                  style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'System Administrator',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
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
        title: Text(AppLocalizations.of(context)?.signOut ?? 'Sign Out'),
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
            child: Text(AppLocalizations.of(context)?.signOut ?? 'Sign Out'),
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
