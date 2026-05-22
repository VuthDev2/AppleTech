part of '../../main.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final saved = store.wishlist.map(store.productById).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.wishlist ?? 'Wishlist'),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView
                  ? CupertinoIcons.list_bullet
                  : CupertinoIcons.square_grid_2x2,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          if (saved.isNotEmpty)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              ),
              onPressed: () {
                for (final prod in saved) {
                  store.addToBag(prod, prod.variants.first);
                  store.toggleWishlist(prod.id);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Moved all ${saved.length} items to Bag'),
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
                'Move All',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
        ],
      ),
      body: saved.isEmpty
          ? EmptyState(
              icon: CupertinoIcons.heart,
              title:
                  AppLocalizations.of(context)?.emptyWishlist ??
                  'Nothing Saved Yet',
              subtitle:
                  AppLocalizations.of(context)?.wishlistEmptyDesc ??
                  'Tap the heart on any product to save it here for later.',
              customArt: const WishlistEmptyArt(),
            )
          : _isGridView
          ? GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
              ),
              itemCount: saved.length,
              itemBuilder: (context, index) =>
                  WishlistGridTile(product: saved[index]),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                    ),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade700,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          CupertinoIcons.trash,
                          color: Colors.white,
                          size: 20,
                        ),
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

void _showVariantSelector(BuildContext context, Product product) {
  final store = AppScope.of(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
      return Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xxl,
          MediaQuery.of(sheetContext).padding.bottom + AppSpacing.xxl,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGray : AppColors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.mediumGray.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Select Variant',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.md),
              ...product.variants.map(
                (v) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${v.colorName} • ${v.storage}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '\$${v.price}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: FilledButton.icon(
                    onPressed: () {
                      store.addToBag(product, v);
                      store.toggleWishlist(product.id);
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Moved ${product.name} to Bag'),
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'View Bag',
                            textColor: AppColors.primary,
                            onPressed: () => store.setTab(3),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.bag_badge_plus, size: 16),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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
          color: isDark
              ? AppColors.darkGray.withAlpha(80)
              : AppColors.lightGray,
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
                    category: product.category,
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
                        onPressed: () => _showVariantSelector(context, product),
                        icon: const Icon(
                          CupertinoIcons.bag_badge_plus,
                          size: 20,
                        ),
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

class WishlistGridTile extends StatelessWidget {
  const WishlistGridTile({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final variant = product.variants.first;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? AppColors.darkGray.withAlpha(80)
              : AppColors.lightGray,
        ),
        boxShadow: appShadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'product-image-wishlist-grid-${product.id}',
                    child: ProductImageBox(
                      imagePath: product.imagePath,
                      category: product.category,
                      fit: BoxFit.contain,
                      animate: false,
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: IconButton.filledTonal(
                      onPressed: () {
                        store.toggleWishlist(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Removed ${product.name} from Wishlist',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.trash, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.lightGray.withAlpha(200),
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${variant.price}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withAlpha(20),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(8),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () => _showVariantSelector(context, product),
                      icon: const Icon(CupertinoIcons.bag_badge_plus, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
