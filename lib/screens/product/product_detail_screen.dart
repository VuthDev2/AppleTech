part of '../../main.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late Variant selected = widget.product.variants.first;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isSaved = store.wishlist.contains(widget.product.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withAlpha(200),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(CupertinoIcons.back, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withAlpha(200),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: isSaved ? 'Remove from wishlist' : 'Add to wishlist',
              onPressed: () => store.toggleWishlist(widget.product.id),
              icon: Icon(
                isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: isSaved ? AppColors.primary : null,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: AppAnimations.slow,
                    curve: AppAnimations.smooth,
                    height: 420,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          selected.color.withValues(alpha: 0.12),
                          Colors.transparent,
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxxl,
                        72,
                        AppSpacing.xxxl,
                        AppSpacing.lg,
                      ),
                      child: Hero(
                        tag: 'product-image-${widget.product.id}',
                        child: AnimatedSwitcher(
                          duration: AppAnimations.slow,
                          switchInCurve: AppAnimations.easeOut,
                          switchOutCurve: AppAnimations.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: ProductImageBox(
                            key: ValueKey(selected.colorName),
                            imagePath: widget.product.imagePath,
                            category: widget.product.category,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: AppSpacing.xl,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withAlpha(200),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.lightGray.withAlpha(100)),
                        ),
                        child: Text(
                          widget.product.category.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'From \$${widget.product.basePrice}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        RatingStars(rating: widget.product.rating),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${widget.product.rating}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '(${widget.product.reviewCount} reviews)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.product.tagline,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, AppSpacing.xxl, 0, 0),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.mediumGray,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Details'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Overview Tab
            _buildOverviewTab(context, store),
            // Reviews Tab
            _buildReviewsTab(context),
            // Details Tab
            _buildDetailsTab(context),
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(240),
          border: const Border(
            top: BorderSide(color: AppColors.lightGray, width: 1),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.xxl,
          MediaQuery.of(context).padding.bottom + AppSpacing.lg,
        ),
        child: FilledButton(
          onPressed: selected.stock == 0
              ? null
              : () {
                  store.addToBag(widget.product, selected);
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
                          Text('${widget.product.name} added to Bag'),
                        ],
                      ),
                    ),
                  );
                },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.bag_badge_plus, size: 20),
              const SizedBox(width: AppSpacing.md),
              Text('Add to Bag - \$${selected.price}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, AppStore store) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          ExpandableDescription(description: widget.product.detailedDescription),
          const SizedBox(height: AppSpacing.xxxl),

          // Key Features
          Text(
            'Key Features',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final feature in widget.product.keyFeatures)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_alt,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xxxl),

          // Selection Section
          Text(
            'Selection Section',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ColorSelector(
            variants: widget.product.variants,
            selected: selected,
            onSelected: (variant) => setState(() => selected = variant),
          ),
          const SizedBox(height: AppSpacing.xxl),
          VariantSelector(
            variants: widget.product.variants,
            selected: selected,
            onSelected: (variant) => setState(() => selected = variant),
          ),
          const SizedBox(height: AppSpacing.xxl),


          // Stock Status
          const SizedBox(height: AppSpacing.xxxl),

          // Warranty
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primary.withAlpha(30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.shield,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Warranty & Protection',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.product.warranty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary
          Container(
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
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.product.rating}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    RatingStars(rating: widget.product.rating),
                  ],
                ),
                const SizedBox(width: AppSpacing.xxxl),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Based on ${widget.product.reviewCount} reviews',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (int i = 5; i >= 1; i--)
                        _buildRatingBar(context, i),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Reviews List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Reviews',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showWriteReviewSheet(context),
                icon: const Icon(CupertinoIcons.pencil, size: 16),
                label: const Text('Write a Review'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...widget.product.reviews.map((review) {
            return Column(
              children: [
                ReviewCard(review: review),
                const SizedBox(height: AppSpacing.lg),
              ],
            );
          }),

          // CTA for more reviews
          if (widget.product.reviewCount > widget.product.reviews.length)
            FilledButton.tonal(
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text('View all ${widget.product.reviewCount} reviews'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpecsComparison(
            title: 'Technical Specifications',
            specs: widget.product.specs,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Release Info
          Container(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.calendar,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Release Date',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${widget.product.releaseDate.year} ${_monthName(widget.product.releaseDate.month)} ${widget.product.releaseDate.day}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Availability
          Container(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_alt,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Availability',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.product.inStock ? 'In Stock' : 'Out of Stock',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.product.inStock ? AppColors.primary : AppColors.mediumGray,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildRatingBar(BuildContext context, int stars) {
    final reviews = widget.product.reviews;
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '$stars',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: const LinearProgressIndicator(
                  value: 0.0,
                  minHeight: 6,
                  backgroundColor: AppColors.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final count = reviews.where((r) => r.rating == stars).length;
    final percent = (count / reviews.length) * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$stars',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
                backgroundColor: AppColors.lightGray,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 30,
            child: Text(
              '${percent.round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mediumGray,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _WriteReviewSheet(
          product: widget.product,
          onSubmitted: (review) {
            AppScope.of(context).addReview(widget.product.id, review);
          },
        );
      },
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet({
    required this.product,
    required this.onSubmitted,
  });

  final Product product;
  final ValueChanged<Review> onSubmitted;

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    // Premium delay to represent network processing
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final newReview = Review(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      author: _authorController.text.trim().isEmpty ? 'Anonymous' : _authorController.text.trim(),
      rating: _rating,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: DateTime.now(),
      verified: true,
    );
    
    widget.onSubmitted(newReview);
    
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });
    }
    
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isSuccess) {
      return Container(
        height: 380,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _isSuccess ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              child: const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppColors.success,
                size: 80,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Thank You!',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your review has been added successfully.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mediumGray),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Write a Review',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          widget.product.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.mediumGray, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              // Star Selector
              Center(
                child: Column(
                  children: [
                    Text(
                      'How would you rate it?',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isFilled = starValue <= _rating;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = starValue),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            child: Icon(
                              isFilled ? CupertinoIcons.star_fill : CupertinoIcons.star,
                              color: isFilled ? const Color(0xFFFFCC00) : AppColors.mediumGray.withAlpha(100),
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _ratingDescription(_rating),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Inputs
              ProfessionalTextField(
                controller: _authorController,
                hintText: 'e.g. John Doe',
                label: 'Your Name',
                prefixIcon: CupertinoIcons.person,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              ProfessionalTextField(
                controller: _titleController,
                hintText: 'Summarize your experience...',
                label: 'Review Title',
                prefixIcon: CupertinoIcons.info,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('Your Review', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What did you like or dislike? How does it perform?',
                  filled: true,
                  fillColor: AppColors.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please write your review' : null,
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ratingDescription(int rating) {
    switch (rating) {
      case 1: return 'Poor 😟';
      case 2: return 'Fair 😐';
      case 3: return 'Average 🙂';
      case 4: return 'Good 😊';
      case 5: return 'Excellent 😍';
      default: return '';
    }
  }
}
