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
    final saved = store.wishlist.map(store.productById).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.wishlist ?? 'Favorites'),
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
                    content: Text('Added all ${saved.length} items to Store Selection'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'View Selection',
                      textColor: AppColors.primary,
                      onPressed: () => store.setTab(3),
                    ),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.add_circled_solid, size: 16),
              label: const Text(
                'Add All to Selection',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
                      child: const Text('Explore Products'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                key: const ValueKey('list'),
                padding: const EdgeInsets.all(AppSpacing.xxl),
                itemCount: saved.length,
                itemBuilder: (context, index) {
                  final product = saved[index];
                  return Dismissible(
                    key: ValueKey('wish-${product.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      store.toggleWishlist(product.id);
                    },
                    background: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade700,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
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
              // 1. PRODUCT IMAGE
              Container(
                width: 120,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                ),
                child: ProductImageBox(
                  imagePath: product.imagePath,
                  category: product.category,
                  fit: BoxFit.contain,
                  animate: false,
                ),
              ),
              
              // 2. DESCRIPTIVE TEXT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          letterSpacing: -0.5,
                        ),
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

              // 3. ACTION BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  child: IconButton.filledTonal(
                    onPressed: () {
                      final store = AppScope.of(context);
                      store.addToBag(product, variant);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${product.name} to Visit'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.plus_circle, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withAlpha(20),
                      foregroundColor: AppColors.primary,
                    ),
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
