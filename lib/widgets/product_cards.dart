part of '../main.dart';

class HeroProductCard extends StatefulWidget {
  const HeroProductCard({required this.product, super.key});

  final Product product;

  @override
  State<HeroProductCard> createState() => _HeroProductCardState();
}

class _HeroProductCardState extends State<HeroProductCard> {
  bool _isHovered = false;

  /// Prefer bundled hero assets for a clean product shot in the carousel.
  String get _heroImagePath {
    switch (widget.product.category) {
      case 'Mac':
        return 'assets/images/macbook_pro.png';
      case 'iPhone':
        return 'assets/images/iphone_16_pro.png';
      case 'iPad':
        return 'assets/images/ipad_pro.png';
      case 'Watch':
        return 'assets/images/watch_ultra.png';
      case 'AirPods':
        return 'assets/images/airpods_pro.png';
      default:
        return widget.product.imagePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

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
            boxShadow: _isHovered ? appShadowMd : appShadowSm,
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.primary.withValues(alpha: 0.22),
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
                      imagePath: _heroImagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  widget.product.featured ? 'FEATURED' : widget.product.category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
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
                  color: AppColors.mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  RatingStars(rating: widget.product.rating, size: 12),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${widget.product.rating.toStringAsFixed(2)} (${widget.product.reviewCount})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
                      color: AppColors.black,
                      shape: BoxShape.circle,
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.25),
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
    final store = AppScope.of(context);
    final isSaved = store.wishlist.contains(widget.product.id);

    return GestureDetector(
      onTap: () => openProduct(context, widget.product),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: _isHovered ? AppColors.primary.withAlpha(100) : AppColors.lightGray,
              width: 1.5,
            ),
            boxShadow: _isHovered ? appShadowMd : appShadowSm,
          ),
          child: Row(
            children: [
              // Product Image
              SizedBox(
                width: 110,
                height: 110,
                child: Hero(
                  tag: 'product-image-${widget.product.id}',
                  child: AnimatedScale(
                    scale: _isHovered ? 1.06 : 1.0,
                    duration: AppAnimations.normal,
                    curve: AppAnimations.smooth,
                    child: ProductImageBox(
                      imagePath: widget.product.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        widget.product.category.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Product Name
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Tagline
                    Text(
                      widget.product.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Rating
                    Row(
                      children: [
                        RatingStars(rating: widget.product.rating, size: 12),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${widget.product.rating} (${widget.product.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Price
                    Text(
                      'From \$${widget.product.basePrice}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions Column
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightGray, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () => store.toggleWishlist(widget.product.id),
                      icon: Icon(
                        isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: isSaved ? AppColors.primary : AppColors.mediumGray,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => openProduct(context, widget.product),
                      icon: const Icon(
                        CupertinoIcons.arrow_right,
                        color: AppColors.white,
                        size: 16,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
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
