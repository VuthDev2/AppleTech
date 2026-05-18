part of '../../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: store.logout,
            icon: const Icon(CupertinoIcons.square_arrow_right),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'AppleTech Customer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Order History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              Switch(
                value: store.isDarkMode,
                onChanged: (_) => store.toggleTheme(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (store.orders.isEmpty)
            const EmptyState(
              icon: CupertinoIcons.clock,
              title: 'No orders yet',
              subtitle: 'Completed checkouts will appear here.',
            )
          else
            for (final order in store.orders) OrderTile(order: order),
        ],
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  const OrderTile({required this.order, super.key});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '\$${order.total}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${order.items.length} item type(s) - ${order.status}'),
          const SizedBox(height: 14),
          const DeliveryTimeline(),
        ],
      ),
    );
  }
}

class DeliveryTimeline extends StatelessWidget {
  const DeliveryTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        TimelineDot(label: 'Paid', color: active),
        Expanded(child: Divider(color: active)),
        TimelineDot(label: 'Packed', color: active),
        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
        TimelineDot(label: 'Delivered', color: Theme.of(context).dividerColor),
      ],
    );
  }
}

class TimelineDot extends StatelessWidget {
  const TimelineDot({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
