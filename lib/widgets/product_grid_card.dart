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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: _isHovered ? appShadowMd : appShadowSm,
          border: Border.all(
            color: _isHovered 
                ? AppColors.primary.withAlpha(100) 
                : (isDark ? AppColors.darkGray.withAlpha(50) : AppColors.lightGray),
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () => openProduct(context, widget.product),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    widget.product.category.toUpperCase(),
                    style: TextStyle(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'From \$${widget.product.basePrice}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.plus_circle_fill,
                      color: _isHovered ? AppColors.primary : AppColors.mediumGray.withAlpha(100),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
