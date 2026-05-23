part of '../main.dart';

void showNotificationsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = List<AppNotification>.from(store.notifications)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + AppSpacing.lg,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: isDark ? AppColors.darkGray : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xxl),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: maxHeight,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.mediumGray.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n?.notifications ?? 'Notifications',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (store.unreadNotificationCount > 0)
                            TextButton(
                              onPressed: store.markAllNotificationsRead,
                              child: const Text('Mark all read'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xxl),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.bell_slash,
                                      size: 48,
                                      color: AppColors.mediumGray.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Text(
                                      l10n?.noNotifications ??
                                          'You have no notifications right now.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: AppColors.mediumGray),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.xxxl,
                              ),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final notification = items[index];
                                return _NotificationTile(
                                  notification: notification,
                                  onTap: () => store.markNotificationRead(
                                    notification.id,
                                  ),
                                  onDismiss: () => store.removeNotification(
                                    notification.id,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _kindColor(notification.kind);

    return Dismissible(
      key: ValueKey<String>(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(
          CupertinoIcons.delete,
          color: AppColors.error,
        ),
      ),
      child: Material(
        color: notification.isRead
            ? (isDark ? AppColors.black : AppColors.lightGray.withAlpha(60))
            : accent.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _kindIcon(notification.kind),
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                  ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mediumGray,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatNotificationTime(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _kindIcon(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.order:
        return CupertinoIcons.cube_box_fill;
      case NotificationKind.promo:
        return CupertinoIcons.tag_fill;
      case NotificationKind.product:
        return CupertinoIcons.gift_fill;
      case NotificationKind.system:
        return CupertinoIcons.gear_alt_fill;
    }
  }

  static Color _kindColor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.order:
        return AppColors.primary;
      case NotificationKind.promo:
        return const Color(0xFFFF9500);
      case NotificationKind.product:
        return const Color(0xFF5856D6);
      case NotificationKind.system:
        return AppColors.mediumGray;
    }
  }
}

String formatNotificationTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat.yMMMd().format(time);
}
