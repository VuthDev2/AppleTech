part of '../main.dart';

class HeroProductCard extends StatefulWidget {
  const HeroProductCard({required this.product, super.key});

  final Product product;

  @override
  State<HeroProductCard> createState() => _HeroProductCardState();
}

class _HeroProductCardState extends State<HeroProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;
    final secondaryText =
        theme.textTheme.bodySmall?.color ?? AppColors.mediumGray;

    return GestureDetector(
      onTap: () => openProduct(context, widget.product),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          width: 280,
          height: 360,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: isDark ? null : (_isHovered ? appShadowMd : appShadowSm),
            border: Border.all(
              color: _isHovered
                  ? primary.withValues(alpha: isDark ? 0.55 : 0.45)
                  : primary.withValues(alpha: isDark ? 0.28 : 0.22),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 148,
                width: double.infinity,
                child: Hero(
                  tag: 'product-image-${widget.product.id}',
                  child: AnimatedScale(
                    scale: _isHovered ? 1.05 : 1.0,
                    duration: AppAnimations.normal,
                    curve: AppAnimations.smooth,
                    child: ProductImageBox(
                      imagePath: widget.product.imagePath,
                      category: widget.product.category,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  widget.product.featured
                      ? 'FEATURED'
                      : widget.product.category.toUpperCase(),
                  style: TextStyle(
                    color: primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.15,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.product.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  RatingStars(rating: widget.product.rating, size: 12),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${widget.product.rating} (${widget.product.reviewCount})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'From \$${widget.product.basePrice}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                  AnimatedContainer(
                    duration: AppAnimations.fast,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? primary : AppColors.black,
                      shape: BoxShape.circle,
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: (isDark ? primary : AppColors.black)
                                    .withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_right,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductListTile extends StatefulWidget {
  const ProductListTile({required this.product, super.key});

  final Product product;

  @override
  State<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final store = AppScope.of(context);
    final isSaved = store.wishlist.contains(widget.product.id);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final secondaryText =
        theme.textTheme.bodySmall?.color ?? AppColors.mediumGray;

    return GestureDetector(
      onTap: () => openProduct(context, widget.product),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered
                  ? primary.withValues(alpha: isDark ? 0.5 : 0.3)
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Premium Product Image Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Hero(
                  tag: 'product-image-${widget.product.id}',
                  child: AnimatedScale(
                    scale: _isHovered ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuart,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ProductImageBox(
                        imagePath: widget.product.imagePath,
                        category: widget.product.category,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.product.category.toUpperCase(),
                        style: TextStyle(
                          color: primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Product Name
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: -0.3,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Tagline (only if not too crowded)
                    Text(
                      widget.product.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Text(
                      '\$${widget.product.basePrice}',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions Column
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SmallCircleButton(
                      onPressed: () => store.toggleWishlist(widget.product.id),
                      icon: isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      color: isSaved ? Colors.redAccent : secondaryText.withValues(alpha: 0.7),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _SmallCircleButton(
                      onPressed: () => openProduct(context, widget.product),
                      icon: CupertinoIcons.arrow_right,
                      color: primary,
                      isDark: isDark,
                      isPrimary: true,
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

class _SmallCircleButton extends StatelessWidget {
  const _SmallCircleButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.isDark,
    this.isPrimary = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isPrimary 
              ? color 
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.white : color,
          size: 16,
        ),
      ),
    );
  }
}
