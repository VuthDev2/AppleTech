import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import 'admin_widgets.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

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
            title: 'Dashboard',
            subtitle: 'Insights and performance.',
          ),
          
          // ── Store Health Section ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: _StoreHealthCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // ── Stat Cards ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _StatCard(
                    title: 'Total Revenue',
                    stream: FirebaseFirestore.instance
                        .collectionGroup('orders')
                        .snapshots(),
                    icon: IconlyBold.chart,
                    color: AppColors.success,
                    isRevenue: true,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _StatCard(
                    title: 'Active Orders',
                    stream: FirebaseFirestore.instance
                        .collectionGroup('orders')
                        .where('status', isNotEqualTo: 'Delivered')
                        .snapshots(),
                    icon: IconlyBold.buy,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _StatCard(
                    title: 'Inventory',
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),
                    icon: IconlyBold.bag,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _StatCard(
                    title: 'Customers',
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    icon: IconlyBold.user_2,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),

          // ── Section Label: Trends ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'Order Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const Spacer(),
                  const Text(
                    'Last 7 Days',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Orders Chart ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: _OrderChart(),
            ),
          ),

          // ── Section Label: Recent Activity ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.lg),
              child: Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
          ),

          // ── Recent Orders List ──────────────────────────────────────────
          _RecentOrdersList(),

          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Store Health Card
// ─────────────────────────────────────────────────────────────────────────────

class _StoreHealthCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminGlassCard(
      child: Row(
        children: [
          // Visual Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: 0.94,
                  strokeWidth: 6,
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  color: AppColors.success,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.success, size: 24),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Status: Excellent',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                SizedBox(height: 2),
                Text(
                  'All systems operational. Performance is up 12% from last month.',
                  style: TextStyle(
                    color: AppColors.mediumGray,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Redesigned Stat Card (Apple Card Style)
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final Stream<QuerySnapshot> stream;
  final IconData icon;
  final Color color;
  final bool isRevenue;

  const _StatCard({
    required this.title,
    required this.stream,
    required this.icon,
    required this.color,
    this.isRevenue = false,
  });

  @override
  Widget build(BuildContext context) {
    return AdminGlassCard(
      width: 156,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              String value = '—';
              if (snapshot.hasData) {
                if (isRevenue) {
                  int total = 0;
                  for (final doc in snapshot.data!.docs) {
                    final d = doc.data() as Map<String, dynamic>;
                    total += (d['total'] as num?)?.toInt() ?? 0;
                  }
                  value = '\$${NumberFormat.compact().format(total)}';
                } else {
                  value = NumberFormat.compact().format(snapshot.data!.docs.length);
                }
              }
              return Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order chart (7-day line chart from Firestore)
// ─────────────────────────────────────────────────────────────────────────────

class _OrderChart extends StatelessWidget {
  final now = DateTime.now();

  _OrderChart();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final last7Days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    return AdminGlassCard(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      height: 240,

      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('orders')
            .snapshots(),
        builder: (context, snapshot) {
          final Map<DateTime, int> counts = {
            for (final d in last7Days) d: 0
          };

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final ts = data['createdAt'] as Timestamp?;
              if (ts != null) {
                final d = ts.toDate();
                final day = DateTime(d.year, d.month, d.day);
                if (counts.containsKey(day)) counts[day] = counts[day]! + 1;
              }
            }
          }

          final spots = last7Days.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), counts[e.value]!.toDouble());
          }).toList();

          double maxY = 5;
          for (final v in counts.values) {
            if (v > maxY) maxY = v.toDouble() + 2;
          }

          return LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outline.withOpacity(
                      isDark ? 0.1 : 0.15),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= last7Days.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('E').format(last7Days[i]),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  barWidth: 3.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 4.5,
                      color: isDark
                          ? AppColors.darkSurface1
                          : Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: AppColors.primary,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.28),
                        AppColors.primary.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Orders List
// ─────────────────────────────────────────────────────────────────────────────

class _RecentOrdersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyState(
              icon: IconlyLight.buy,
              message: 'No recent orders',
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          sliver: SliverList.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final status = (data['status'] as String?) ?? 'Pending';
              final total = (data['total'] as num?)?.toInt() ?? 0;
              final ts = data['createdAt'] as Timestamp?;
              final date = ts != null
                  ? DateFormat('MMM d, h:mm a').format(ts.toDate())
                  : 'Unknown';
              final orderId = docs[i].id;

              final statusColor = _statusColor(status);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                        ),
                        boxShadow: isDark ? [] : appShadowSm,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(IconlyBold.buy, color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          '#${orderId.substring(0, orderId.length.clamp(0, 8)).toUpperCase()}',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(date, style: theme.textTheme.bodySmall),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$$total',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppRadius.full),
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
                      ),
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}