part of '../main.dart';

class ProductGridCard extends StatefulWidget {
  const ProductGridCard({required this.product, super.key});

  final Product product;

  @override
  State<ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<ProductGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => openProduct(context, widget.product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered 
                  ? primary.withValues(alpha: isDark ? 0.6 : 0.4) 
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: _isHovered ? 24 : 12,
                offset: Offset(0, _isHovered ? 12 : 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with refined container
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.03) 
                        : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Hero(
                    tag: 'product-image-${widget.product.id}',
                    child: AnimatedScale(
                      scale: _isHovered ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ProductImageBox(
                          imagePath: widget.product.imagePath,
                          category: widget.product.category,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Product Details
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.product.category.toUpperCase(),
                        style: TextStyle(
                          color: primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Product Name
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        height: 1.2,
                        letterSpacing: -0.3,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Price and Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${widget.product.basePrice}',
                              style: TextStyle(
                                color: onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _SmallHeartButton(product: widget.product),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _isHovered ? primary : primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.arrow_right,
                                color: _isHovered ? Colors.white : primary,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _SmallHeartButton extends StatelessWidget {
  const _SmallHeartButton({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isSaved = store.wishlist.contains(product.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        store.toggleWishlist(product.id);
        final isSavedNow = store.wishlist.contains(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSavedNow ? 'Added ${product.name} to Favorites' : 'Removed from Favorites'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSaved 
              ? Colors.redAccent.withAlpha(30) 
              : (isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: isSaved ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black54),
          size: 16,
        ),
      ),
    );
  }
}
