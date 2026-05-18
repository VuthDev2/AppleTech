part of '../main.dart';

class HeroProductCard extends StatelessWidget {
  const HeroProductCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final textColor = product.accent.computeLuminance() > 0.6
        ? Colors.black
        : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => openProduct(context, product),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: product.accent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                product.icon,
                size: 122,
                color: textColor.withAlpha(62),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: TextStyle(
                    color: textColor.withAlpha(204),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'From \$${product.basePrice}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  const ProductListTile({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isSaved = store.wishlist.contains(product.id);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => openProduct(context, product),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            ProductGlyph(product: product, size: 72),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From \$${product.basePrice}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: isSaved ? 'Remove from wishlist' : 'Add to wishlist',
              onPressed: () => store.toggleWishlist(product.id),
              icon: Icon(
                isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: isSaved ? Colors.redAccent : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
