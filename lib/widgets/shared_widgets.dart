part of '../main.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 58,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGlyph extends StatelessWidget {
  const ProductGlyph({
    required this.product,
    required this.size,
    this.overrideColor,
    super.key,
  });

  final Product product;
  final double size;
  final Color? overrideColor;

  @override
  Widget build(BuildContext context) {
    final color = overrideColor ?? product.accent;
    return Hero(
      tag: 'product-${product.id}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha(58),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(product.icon, color: color, size: size * 0.55),
      ),
    );
  }
}

IconData categoryIcon(String category) {
  return switch (category) {
    'Mac' => CupertinoIcons.device_laptop,
    'iPhone' => CupertinoIcons.device_phone_portrait,
    'iPad' => Icons.tablet_mac,
    'Watch' => Icons.watch,
    'AirPods' => Icons.earbuds,
    _ => CupertinoIcons.square_grid_2x2,
  };
}

void openProduct(BuildContext context, Product product) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
  );
}
