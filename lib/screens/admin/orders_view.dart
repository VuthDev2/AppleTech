import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import 'admin_widgets.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String _filter = 'All';
  final _filters = ['All', 'Pending', 'Processing', 'Delivered', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const AdminSliverHeader(
            title: 'Orders',
            subtitle: 'Real-time order management.',
          ),
          
          // ── Order Stats / Quick Filter ──────────────────────────────────
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collectionGroup('orders').snapshots(),
              builder: (context, snapshot) {
                final counts = {
                  'All': 0, 'Pending': 0, 'Processing': 0, 'Delivered': 0, 'Cancelled': 0
                };
                if (snapshot.hasData) {
                  counts['All'] = snapshot.data!.docs.length;
                  for (final doc in snapshot.data!.docs) {
                    final status = (doc.data() as Map)['status'] ?? 'Pending';
                    if (counts.containsKey(status)) {
                      counts[status] = counts[status]! + 1;
                    }
                  }
                }

                return SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final f = _filters[i];
                      final selected = _filter == f;
                      final count = counts[f] ?? 0;

                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected 
                              ? AppColors.primary 
                              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: selected ? AppColors.primary : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                f,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: selected ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: selected ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          
          // ── Orders List ─────────────────────────────────────────────────
          _OrdersList(filter: _filter),
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final String filter;
  const _OrdersList({required this.filter});

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collectionGroup('orders')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No orders found.')),
          );
        }

        var docs = snapshot.data!.docs;
        if (filter != 'All') {
          docs = docs
              .where((d) =>
                  ((d.data() as Map)['status'] ?? '') == filter)
              .toList();
        }

        if (docs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text('No $filter orders.',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          );
        }

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl),
          sliver: SliverList.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final data =
                  docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;
              final status =
                  (data['status'] as String?) ?? 'Pending';
              final total =
                  (data['total'] as num?)?.toInt() ?? 0;
              final ts = data['createdAt'] as Timestamp?;
              final date = ts != null
                  ? DateFormat('MMM d, yyyy · h:mm a')
                      .format(ts.toDate())
                  : '—';
              final customerName =
                  (data['customerName'] as String?) ??
                      'Guest';
              final items =
                  (data['items'] as List?)?.length ?? 0;

              final statusColor = _color(status);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AdminGlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          statusColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(IconlyBold.buy,
                        color: statusColor, size: 20),
                  ),
                  title: Text(
                    '#${id.substring(0, id.length.clamp(0, 8)).toUpperCase()}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '$customerName • $items item${items == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$$total',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(
                                fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(
                              AppRadius.full),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(
                              height: AppSpacing.md),
                          _InfoRow(
                              label: 'Date', value: date),
                          if (data['customerPhone'] !=
                              null)
                            _InfoRow(
                              label: 'Phone',
                              value: data['customerPhone'],
                            ),
                          if (data['customerAddress'] !=
                              null)
                            _InfoRow(
                              label: 'Address',
                              value:
                                  data['customerAddress'],
                            ),
                          const SizedBox(
                              height: AppSpacing.md),
                          // Status update buttons
                          SingleChildScrollView(
                            scrollDirection:
                                Axis.horizontal,
                            child: Row(
                              children: [
                                'Processing',
                                'Delivered',
                                'Cancelled',
                              ].map((s) {
                                final isActive =
                                    status == s;
                                return Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(right: 8),
                                  child: OutlinedButton(
                                    onPressed: isActive
                                        ? null
                                        : () =>
                                            docs[i]
                                                .reference
                                                .update({
                                              'status': s
                                            }),
                                    style: OutlinedButton
                                        .styleFrom(
                                      foregroundColor:
                                          _color(s),
                                      side: BorderSide(
                                          color: _color(s)
                                              .withOpacity(
                                                  0.5)),
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                              horizontal:
                                                  12,
                                              vertical:
                                                  6),
                                      minimumSize:
                                          Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize
                                              .shrinkWrap,
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    AppRadius
                                                        .full),
                                      ),
                                    ),
                                    child: Text(
                                      s,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w700),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
            );
          },
          ),
        );
      },
    );
  }

  Color _color(String s) {
    switch (s.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'processing':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.accent;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox();
    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style:
                  Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
