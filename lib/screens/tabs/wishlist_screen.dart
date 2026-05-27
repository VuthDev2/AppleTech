part of '../../main.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    // AppScope.of(context) ensures this widget rebuilds whenever the wishlist changes
    final store = AppScope.of(context);
    final saved = store.wishlist
        .map((id) => store.products.any((p) => p.id == id) ? store.productById(id) : null)
        .whereType<Product>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.wishlist ?? 'Favorites'),
        actions: [
          if (saved.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withAlpha(20),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
                onPressed: () {
                  for (final prod in saved) {
                    store.addToBag(prod, prod.variants.first);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)?.addedItemsToCart(saved.length.toString()) ?? 'Added ${saved.length} items to Cart'),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: AppColors.primary,
                        onPressed: () => store.setTab(2),
                      ),
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.add_circled_solid, size: 16),
                label: const Text(
                  'Add All to Cart',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: saved.isEmpty
            ? Center(
                key: const ValueKey('empty'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyState(
                      icon: CupertinoIcons.heart_fill,
                      title: 'Your Heart is Empty',
                      subtitle: 'Tap the heart on any product to see it listed here.',
                      customArt: WishlistEmptyArt(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: () => store.setTab(1),
                      child: Text(AppLocalizations.of(context)?.exploreProducts ?? 'Explore Products'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                  key: const ValueKey('list'),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
                  itemCount: saved.length,
                  itemBuilder: (context, index) {
                    final product = saved[index];
                    return Dismissible(
                      key: ValueKey('wish-${product.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        final name = product.name;
                        store.toggleWishlist(product.id);
                        store.pushNotification(AppNotification(
                          id: 'wishlist-remove-${product.id}-${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Removed from Wishlist',
                          body: 'You have removed "$name" from your wishlist.',
                          createdAt: DateTime.now(),
                          kind: NotificationKind.product,
                        ));
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('You have removed "$name"'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      background: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.shade700,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Icon(CupertinoIcons.trash, color: Colors.white),
                      ),
                      child: WishlistItemTile(product: product),
                    );
                  },
                ),
      ),
    );
  }
}

class WishlistItemTile extends StatelessWidget {
  const WishlistItemTile({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variant = product.variants.first;

    return GestureDetector(
      onTap: () => openProduct(context, product),
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.darkGray.withAlpha(80) : AppColors.lightGray,
          ),
          boxShadow: appShadowSm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Row(
            children: [
              // Image
              Container(
                width: 120,
                padding: const EdgeInsets.all(AppSpacing.md),
                color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                child: ProductImageBox(
                  imagePath: product.imagePath,
                  category: product.category,
                  fit: BoxFit.contain,
                  animate: false,
                ),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.mediumGray,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${variant.price}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        final store = AppScope.of(context);
                        final name = product.name;
                        store.toggleWishlist(product.id);
                        store.pushNotification(AppNotification(
                          id: 'wishlist-remove-${product.id}-${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Removed from Wishlist',
                          body: 'You have removed "$name" from your wishlist.',
                          createdAt: DateTime.now(),
                          kind: NotificationKind.product,
                        ));
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('You have removed "$name"'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.heart_fill, color: Colors.redAccent),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.redAccent.withAlpha(20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        onPressed: () {
                          final store = AppScope.of(context);
                          store.addToBag(product, variant);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.addedProductToCart(product.name) ?? 'Added ${product.name} to Cart'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withAlpha(20),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        ),
                        icon: const Icon(CupertinoIcons.plus, size: 20),
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
  }
}
