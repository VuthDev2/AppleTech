part of '../../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    final Map<String, Product> uniqueCategoryProducts = {};
    for (final p in store.products.where((p) => p.featured)) {
      if (!uniqueCategoryProducts.containsKey(p.category)) {
        uniqueCategoryProducts[p.category] = p;
      }
    }

    final preferredOrder = ['Mac', 'iPad', 'AirPods', 'iPhone', 'Watch'];
    final featured = <Product>[];
    for (final category in preferredOrder) {
      if (uniqueCategoryProducts.containsKey(category)) {
        featured.add(uniqueCategoryProducts[category]!);
      }
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoreHeader(onToggleTheme: store.toggleTheme),
                    const SizedBox(height: AppSpacing.md),
                    const HomeSearchField(),
                  ],
                ),
              ),
            ),

            // Promo Carousel
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl),
                child: PromoBannerCarousel(),
              ),
            ),

            // Categories Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  AppSpacing.md,
                ),
                child: Text(
                  AppLocalizations.of(context)?.recentCategories ??
                      'Recent Categories',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Categories Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final recentCategories = [
                      'iPhone',
                      'Mac',
                      'iPad',
                      'Watch',
                      'AirPods',
                      'Home',
                      'Vision',
                    ];
                    final category = recentCategories[index];
                    return StoreCategoryBubble(category: category);
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SectionHeader(
                title: AppLocalizations.of(context)?.theLatest ?? 'The latest.',
                subtitle:
                    AppLocalizations.of(context)?.takeCloserLook ??
                    'Take a closer look at what is new.',
              ),
            ),

            // Featured Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 388,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.sm,
                    AppSpacing.xxl,
                    AppSpacing.xxxl,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      key: ValueKey(featured[index].id),
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 420 + (index * 90)),
                      curve: AppAnimations.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: HeroProductCard(product: featured[index]),
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SectionHeader(
                title:
                    AppLocalizations.of(context)?.appleDifference ??
                    'Apple Difference.',
                subtitle:
                    AppLocalizations.of(context)?.moreReasonsToShop ??
                    'More reasons to shop with us.',
              ),
            ),

            // Difference Cards Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.xxxl,
                  ),
                  scrollDirection: Axis.horizontal,
                  children: [
                    StoreDifferenceCard(
                      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                      title:
                          AppLocalizations.of(context)?.shopOneOnOne ??
                          'Shop one on one',
                      body:
                          AppLocalizations.of(context)?.getHelpChoosing ??
                          'Get help choosing the right device.',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    StoreDifferenceCard(
                      icon: CupertinoIcons.slider_horizontal_3,
                      title:
                          AppLocalizations.of(context)?.customizeYours ??
                          'Customize yours',
                      body:
                          AppLocalizations.of(context)?.pickFinishes ??
                          'Pick finishes, storage, and bands.',
                      color: Color(0xFFAF52DE),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    StoreDifferenceCard(
                      icon: CupertinoIcons.cube_box,
                      title:
                          AppLocalizations.of(context)?.easyDelivery ??
                          'Easy delivery',
                      body:
                          AppLocalizations.of(context)?.trackEveryOrder ??
                          'Track every order from checkout.',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ),

            // All Products List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xxxl,
              ),
              sliver: SliverList.separated(
                itemCount: store.products.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.lg),
                itemBuilder: (context, index) =>
                    ProductListTile(product: store.products[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreHeader extends StatelessWidget {
  const StoreHeader({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final store = AppScope.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipBg = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.lightGray.withAlpha(100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const StoreBrandMark(height: 34),
            Row(    
              mainAxisSize: MainAxisSize.min,
              children: [
                _StoreHeaderIconButton(
                  onPressed: () => showNotificationsSheet(context),
                  backgroundColor: chipBg,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(CupertinoIcons.bell_fill, size: 20),
                      if (store.unreadNotificationCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              store.unreadNotificationCount > 9
                                  ? '9+'
                                  : '${store.unreadNotificationCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _StoreHeaderIconButton(
                  onPressed: onToggleTheme,
                  backgroundColor: chipBg,
                  icon: Icon(
                    isDark
                        ? CupertinoIcons.sun_max_fill
                        : CupertinoIcons.moon_fill,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _StoreHeaderIconButton(
                  onPressed: () {
                    final store = AppScope.of(context);
                    final current = store.locale?.languageCode ?? 'en';
                    if (current == 'en') {
                      store.setLocale(const Locale('km'));
                    } else if (current == 'km') {
                      store.setLocale(const Locale('ch'));
                    } else {
                      store.setLocale(const Locale('en'));
                    }
                  },
                  backgroundColor: chipBg,
                  icon: Text(
                    store.locale?.languageCode == 'km'
                        ? '🇰🇭'
                        : store.locale?.languageCode == 'ch'
                        ? '🇨🇳'
                        : '🇺🇸',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),


        const SizedBox(height: AppSpacing.md),
        Text(
          store.user?.name != null
              ? (AppLocalizations.of(context)?.welcome != null
                  ? '${AppLocalizations.of(context)!.welcome}, ${store.user!.name.split(' ').first}'
                  : 'Welcome, ${store.user!.name.split(' ').first}')
              : (AppLocalizations.of(context)?.welcome ?? 'Welcome'),
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            height: 1.1,
            letterSpacing: -0.8,
            color: onSurface,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class StoreCategoryBubble extends StatelessWidget {
  const StoreCategoryBubble({required this.category, super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CategoryScreen(category: category)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              boxShadow: isDark ? null : appShadowSm,
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Icon(
              categoryIcon(category),
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            category,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({required this.category, super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final products = store.products
        .where((p) => p.category == category)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) =>
            ProductListTile(product: products[index]),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.sm,
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          children: [
            TextSpan(
              text: title,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            TextSpan(
              text: ' $subtitle',
              style: const TextStyle(
                color: AppColors.mediumGray,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreDifferenceCard extends StatelessWidget {
  const StoreDifferenceCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: isDark ? null : appShadowSm,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeSearchField extends StatefulWidget {
  const HomeSearchField({super.key});

  @override
  State<HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends State<HomeSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalTextField(
      controller: _controller,
      hintText:
          AppLocalizations.of(context)?.searchHint ??
          'Search products…',
      prefixIcon: CupertinoIcons.search,
      onFieldSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          final store = AppScope.of(context);
          store.setTab(1, searchQuery: value.trim());
          _controller.clear();
        }
      },
    );
  }
}

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  final List<PromoBannerData> _banners = [
    PromoBannerData(
      title: 'MacBook Pro',
      subtitle: 'Mind-blowing. Head-turning.',
      imagePath: 'assets/images/macbook_pro.png',
      colors: [const Color(0xFF2E2E3A), const Color(0xFF0F0F14)],
      actionText: 'Shop MacBook',
    ),
    PromoBannerData(
      title: 'iPhone 16 Pro',
      subtitle: 'Hello, Apple Intelligence.',
      imagePath: 'assets/images/iphone_16_pro.png',
      colors: [const Color(0xFF3C3B3F), const Color(0xFF605C5E)],
      actionText: 'Learn More',
    ),
    PromoBannerData(
      title: 'Watch Ultra 2',
      subtitle: 'New finish. Never finished.',
      imagePath: 'assets/images/watch_ultra.png',
      colors: [const Color(0xFFD35400), const Color(0xFF2C3E50)],
      actionText: 'Explore Ultra',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 188,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index).abs();
                    value = (1 - (value * 0.15)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: banner.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: appShadowMd,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withAlpha(20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.xl,
                            148,
                            AppSpacing.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withAlpha(50),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)?.latestRelease ??
                                      'LATEST RELEASE',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                banner.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banner.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.white.withAlpha(200),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              InkWell(
                                onTap: () {
                                  final store = AppScope.of(context);
                                  store.setTab(1, searchQuery: banner.title);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                  child: Text(
                                    banner.actionText == 'Shop MacBook'
                                        ? AppLocalizations.of(context)?.shopMacBook ??
                                            banner.actionText
                                        : banner.actionText == 'Learn More'
                                            ? AppLocalizations.of(context)?.learnMore ??
                                                banner.actionText
                                            : banner.actionText == 'Explore Ultra'
                                                ? AppLocalizations.of(context)?.exploreUltra ??
                                                    banner.actionText
                                                : banner.actionText,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: banner.colors.first,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 155,
                          child: Image.asset(
                            banner.imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            filterQuality: FilterQuality.high,
                            gaplessPlayback: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 18 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primary
                    : AppColors.mediumGray.withAlpha(100),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PromoBannerData {
  PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.colors,
    required this.actionText,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> colors;
  final String actionText;
}

class _StoreHeaderIconButton extends StatelessWidget {
  const _StoreHeaderIconButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: icon,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

void showNotificationsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final store = AppScope.of(sheetContext);
      final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.82;

      return ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(sheetContext).top + AppSpacing.lg,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: isDark ? AppColors.darkGray : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xxl),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: maxHeight,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.mediumGray.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.xl,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Notifications',
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (store.unreadNotificationCount > 0)
                              TextButton(
                                onPressed: store.markAllNotificationsRead,
                                child: const Text('Mark all read'),
                              ),
                            IconButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              icon: const Icon(CupertinoIcons.xmark, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: store.notifications.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(AppSpacing.xxxl),
                                child: EmptyState(
                                  icon: CupertinoIcons.bell_slash,
                                  title: 'All caught up',
                                  subtitle:
                                      'You have no notifications right now.',
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xxl,
                                  AppSpacing.lg,
                                  AppSpacing.xxl,
                                  AppSpacing.xxxl,
                                ),
                                itemCount: store.notifications.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.md),
                                itemBuilder: (context, index) {
                                  final notification =
                                      store.notifications[index];
                                  return _NotificationTile(
                                    notification: notification,
                                    onTap: () {
                                      store.markNotificationRead(
                                        notification.id,
                                      );
                                      if (notification.kind ==
                                          NotificationKind.order) {
                                        store.setTab(4);
                                        Navigator.pop(sheetContext);
                                      }
                                    },
                                    onDismiss: () => store.removeNotification(
                                      notification.id,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = _notificationAccent(notification.kind);

    return Material(
      color: notification.isRead
          ? theme.cardColor
          : AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _notificationIcon(notification.kind),
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: AppSpacing.sm),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGray,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _formatNotificationTime(notification.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 20,
                  color: AppColors.mediumGray.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _notificationIcon(NotificationKind kind) {
  return switch (kind) {
    NotificationKind.order => CupertinoIcons.cube_box_fill,
    NotificationKind.promo => CupertinoIcons.tag_fill,
    NotificationKind.product => CupertinoIcons.device_phone_portrait,
    NotificationKind.system => CupertinoIcons.shield_lefthalf_fill,
  };
}

Color _notificationAccent(NotificationKind kind) {
  return switch (kind) {
    NotificationKind.order => AppColors.success,
    NotificationKind.promo => AppColors.accent,
    NotificationKind.product => AppColors.primary,
    NotificationKind.system => AppColors.secondary,
  };
}

String _formatNotificationTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${time.month}/${time.day}/${time.year}';
}
