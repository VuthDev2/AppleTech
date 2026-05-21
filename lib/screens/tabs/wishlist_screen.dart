part of '../../main.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final saved = store.wishlist.map(store.productById).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.wishlist ?? 'Wishlist'),
        actions: [
          if (saved.isNotEmpty)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              ),
              onPressed: () {
                for (final prod in saved) {
                  store.addToBag(prod, prod.variants.first);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added all ${saved.length} items to Bag'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'View Bag',
                      textColor: AppColors.primary,
                      onPressed: () => store.setTab(3),
                    ),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.bag_fill, size: 16),
              label: const Text(
                'Add All',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
        ],
      ),
      body: saved.isEmpty
          ? EmptyState(
              icon: CupertinoIcons.heart,
              title: AppLocalizations.of(context)?.emptyWishlist ?? 'Nothing Saved Yet',
              subtitle: AppLocalizations.of(context)?.wishlistEmptyDesc ?? 'Tap the heart on any product to save it here for later.',
              customArt: const WishlistEmptyArt(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final product = saved[index];
                return Dismissible(
                  key: ValueKey(product.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    store.toggleWishlist(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed ${product.name} from Wishlist'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade700,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(CupertinoIcons.trash, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: WishlistItemTile(product: product),
                );
              },
            ),
    );
  }
}

class WishlistItemTile extends StatelessWidget {
  const WishlistItemTile({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variant = product.variants.first;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkGray.withAlpha(80) : AppColors.lightGray,
        ),
        boxShadow: appShadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              SizedBox(
                width: 110,
                child: Hero(
                  tag: 'product-image-wishlist-${product.id}',
                  child: ProductImageBox(
                    imagePath: product.imagePath,
                    fit: BoxFit.contain,
                    animate: false,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Product details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${variant.price}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Add to Bag Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withAlpha(20),
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        onPressed: () {
                          store.addToBag(product, variant);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.success,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                              content: Row(
                                children: [
                                  const Icon(CupertinoIcons.checkmark_alt, color: AppColors.white),
                                  const SizedBox(width: AppSpacing.md),
                                  Text('Added ${product.name} to Bag'),
                                ],
                              ),
                              action: SnackBarAction(
                                label: 'View Bag',
                                textColor: AppColors.white,
                                onPressed: () => store.setTab(3),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(CupertinoIcons.bag_badge_plus, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
