import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appletech/core/app_colors.dart';
import 'package:appletech/l10n/app_localizations.dart';

/// Shows a draggable bottom sheet with recent orders for admin notifications.
void showAdminNotificationsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _AdminNotificationSheet(),
  );
}

class _AdminNotificationSheet extends StatefulWidget {
  const _AdminNotificationSheet({Key? key}) : super(key: key);

  @override
  State<_AdminNotificationSheet> createState() => _AdminNotificationSheetState();
}

class _AdminNotificationSheetState extends State<_AdminNotificationSheet> {
  bool _markAllLoading = false;

  Future<void> _markAllRead() async {
    setState(() => _markAllLoading = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('read', isEqualTo: false)
          .get();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } finally {
      if (mounted) setState(() => _markAllLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface1 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)?.notificationsTitle ?? 'Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    _markAllLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : TextButton(onPressed: _markAllRead, child: Text(AppLocalizations.of(context)?.markAllRead ?? 'Mark all as read')),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .orderBy('createdAt', descending: true)
                      .limit(30)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(child: Text(AppLocalizations.of(context)?.noRecentNotifications ?? 'No recent notifications'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: docs.length,
                      itemBuilder: (_, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final title = data['title'] ?? 'Order';
                        final time = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final unread = (data['read'] as bool?) ?? false;
                        return ListTile(
                          leading: Icon(CupertinoIcons.bell, color: unread ? AppColors.error : null),
                          title: Text(title),
                          subtitle: Text('${time.toLocal()}'),
                          trailing: unread
                              ? const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12)
                              : null,
                          onTap: () async {
                            // Mark as read when opened
                            if (unread) {
                              await docs[index].reference.update({'read': true});
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
