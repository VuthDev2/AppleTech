part of '../main.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({required this.rating, this.size = 16, super.key});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.toInt()
              ? CupertinoIcons.star_fill
              : (index < rating ? CupertinoIcons.star_fill : CupertinoIcons.star),
          size: size,
          color: index < rating.toInt() ? const Color(0xFFFFB81C) : AppColors.lightGray,
        );
      }),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({required this.review, super.key});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkGray.withAlpha(50)
              : AppColors.lightGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.author,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        if (review.verified) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark,
                                  size: 10,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    RatingStars(rating: review.rating.toDouble(), size: 14),
                  ],
                ),
              ),
              Text(
                'May ${review.date.day}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            review.title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            review.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class SpecsComparison extends StatelessWidget {
  const SpecsComparison({
    required this.title,
    required this.specs,
    super.key,
  });

  final String title;
  final List<String> specs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkGray.withAlpha(50)
              : AppColors.lightGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(specs.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: AppSpacing.md, right: AppSpacing.md),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      specs[index],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ProductConfigurator extends StatelessWidget {
  const ProductConfigurator({
    required this.product,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final Product product;
  final Variant selected;
  final ValueChanged<Variant> onSelected;

  @override
  Widget build(BuildContext context) {
    final variants = product.variants;

    Variant pickBest({
      String? colorName,
      String? size,
      String? ram,
      String? storage,
    }) {
      Variant best = selected;
      var bestScore = -1;
      for (final v in variants) {
        if (colorName != null && v.colorName != colorName) continue;
        if (size != null && v.size != size) continue;
        if (ram != null && v.ram != ram) continue;
        if (storage != null && v.storage != storage) continue;
        final score =
            (v.colorName == selected.colorName ? 4 : 0) +
            (v.size == selected.size ? 3 : 0) +
            (v.ram == selected.ram ? 2 : 0) +
            (v.storage == selected.storage ? 1 : 0);
        if (score > bestScore) {
          bestScore = score;
          best = v;
        }
      }
      return best;
    }

    final uniqueColors = variants.map((v) => v.colorName).toSet().toList();
    final uniqueSizes = variants
        .map((v) => v.size)
        .where((v) => v != null && v.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    final uniqueRam = variants
        .map((v) => v.ram)
        .where((v) => v != null && v.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    final uniqueStorage = variants.map((v) => v.storage).toSet().toList();

    Widget buildChips(List<String> values, String current, void Function(String) onTap) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: values.map((value) {
          final selectedValue = value == current;
          return ChoiceChip(
            label: Text(value),
            selected: selectedValue,
            onSelected: (_) => onTap(value),
            selectedColor: AppColors.primary.withAlpha(30),
            side: BorderSide(
              color: selectedValue ? AppColors.primary : (isDark ? Colors.white24 : Colors.black12),
            ),
            labelStyle: TextStyle(
              color: selectedValue ? AppColors.primary : null,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Finish', trailing: selected.colorName),
        const SizedBox(height: AppSpacing.md),
        buildChips(
          uniqueColors,
          selected.colorName,
          (value) => onSelected(pickBest(colorName: value)),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (uniqueSizes.isNotEmpty) ...[
          SectionTitle(title: 'Size', trailing: selected.size),
          const SizedBox(height: AppSpacing.md),
          buildChips(
            uniqueSizes,
            selected.size ?? '',
            (value) => onSelected(pickBest(size: value)),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (uniqueRam.isNotEmpty) ...[
          SectionTitle(title: 'Memory', trailing: selected.ram),
          const SizedBox(height: AppSpacing.md),
          buildChips(
            uniqueRam,
            selected.ram ?? '',
            (value) => onSelected(pickBest(ram: value)),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        SectionTitle(title: 'Storage', trailing: selected.storage),
        const SizedBox(height: AppSpacing.md),
        buildChips(
          uniqueStorage,
          selected.storage,
          (value) => onSelected(pickBest(storage: value)),
        ),
      ],
    );
  }
}

class VariantSelector extends StatelessWidget {
  const VariantSelector({
    required this.variants,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Variant> variants;
  final Variant selected;
  final Function(Variant) onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter variants by selected color to show only relevant configurations
    final colorVariants = variants.where((v) => v.colorName == selected.colorName).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Configuration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '${colorVariants.length} Options',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            mainAxisExtent: 96,
          ),
          itemCount: colorVariants.length,
          itemBuilder: (context, index) {
            final variant = colorVariants[index];
            final isSelected = variant.id == selected.id;
            
            return GestureDetector(
              onTap: () => onSelected(variant),
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withAlpha(isDark ? 30 : 10) 
                      : (isDark ? AppColors.darkGray.withAlpha(50) : AppColors.white),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.darkGray : AppColors.lightGray),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          variant.configurationLabel,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            fontSize: 13,
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.white : AppColors.black),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '\$${variant.price}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.mediumGray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ColorSelector extends StatelessWidget {
  const ColorSelector({
    required this.variants,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Variant> variants;
  final Variant selected;
  final Function(Variant) onSelected;

  @override
  Widget build(BuildContext context) {
    final uniqueColors = <String, Variant>{};
    for (final v in variants) {
      if (!uniqueColors.containsKey(v.colorName)) {
        uniqueColors[v.colorName] = v;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Color: ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              selected.colorName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: uniqueColors.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) {
              final variant = uniqueColors.values.elementAt(index);
              final isSelected = variant.colorName == selected.colorName;
              
              return GestureDetector(
                onTap: () => onSelected(variant),
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: variant.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.trailing, super.key});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              trailing!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({required this.description, super.key});

  final String description;

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mediumGray,
                  height: 1.8,
                ),
          ),
          secondChild: Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mediumGray,
                  height: 1.8,
                ),
          ),
          crossFadeState:
              _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(
            _isExpanded ? 'Show less' : 'Read more',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}



