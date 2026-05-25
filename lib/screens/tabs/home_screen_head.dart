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
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.lg,
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
                    return StaggeredFadeSlide(
                      index: index,
                      child: StoreCategoryBubble(category: category),
                    );
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
                    return StaggeredFadeSlide(
                      index: index,
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
                      color: const Color(0xFFAF52DE),
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

class AutomatedTextLoop extends StatefulWidget {
  const AutomatedTextLoop({
    required this.texts,
    this.style,
    this.duration = const Duration(seconds: 3),
    super.key,
  });

  final List<String> texts;
  final TextStyle? style;
  final Duration duration;

  @override
  State<AutomatedTextLoop> createState() => _AutomatedTextLoopState();
}

class _AutomatedTextLoopState extends State<AutomatedTextLoop> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.texts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: Text(
        widget.texts[_currentIndex],
        key: ValueKey(widget.texts[_currentIndex]),
        style: widget.style,
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

    final l10n = AppLocalizations.of(context);
    final greetings = [l10n?.welcome ?? 'Welcome'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const StoreBrandMark(height: 38),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.lightGray.withAlpha(80),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: isDark
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StoreHeaderIconButton(
                    onPressed: () => showNotificationsSheet(context),
                    backgroundColor: Colors.transparent,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          CupertinoIcons.bell_fill,
                          size: 19,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        if (store.unreadNotificationCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                store.unreadNotificationCount > 9
                                    ? '9+'
                                    : '${store.unreadNotificationCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 1,
                      height: 14,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  _StoreHeaderIconButton(
                    onPressed: onToggleTheme,
                    backgroundColor: Colors.transparent,
                    icon: Icon(
                      isDark
                          ? CupertinoIcons.sun_max_fill
                          : CupertinoIcons.moon_fill,
                      size: 19,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 1,
                      height: 14,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  _StoreHeaderIconButton(
                    onPressed: () {
                      final store = AppScope.of(context);
                      final current = store.locale?.languageCode ?? 'en';
                      if (current == 'en') {
                        store.setLocale(const Locale('km'));
                      } else if (current == 'km') {
                        store.setLocale(const Locale('zh'));
                      } else {
                        store.setLocale(const Locale('en'));
                      }
                    },
                    backgroundColor: Colors.transparent,
                    icon: Container(
                      decoration: isDark ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          )
                        ]
                      ) : null,
                      child: Text(
                        store.locale?.languageCode == 'km'
                            ? '🇰🇭'
                            : store.locale?.languageCode == 'zh'
                            ? '🇨🇳'
                            : '🇺🇸',
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),
        AutomatedTextLoop(
          texts: greetings
              .map(
                (g) => store.user?.name != null
                    ? '$g, ${store.user!.name.split(' ').first}'
                    : g,
              )
              .toList(),
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            height: 1.1,
            letterSpacing: -1.0,
            color: onSurface,
          ),
        ),
        const SizedBox(height: 4),
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
      appBar: AppBar(title: Text(category)),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
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
              style: const TextStyle(color: AppColors.mediumGray, height: 1.4),
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

class AnimatedHintTextField extends StatefulWidget {
  const AnimatedHintTextField({
    required this.controller,
    required this.hints,
    this.onFieldSubmitted,
    this.prefixIcon,
    super.key,
  });

  final TextEditingController controller;
  final List<String> hints;
  final ValueChanged<String>? onFieldSubmitted;
  final IconData? prefixIcon;

  @override
  State<AnimatedHintTextField> createState() => _AnimatedHintTextFieldState();
}

class _AnimatedHintTextFieldState extends State<AnimatedHintTextField> {
  int _currentHintIndex = 0;
  String _displayedHint = '';
  Timer? _typingTimer;
  Timer? _cycleTimer;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _startTyping();

    widget.controller.addListener(() {
      final shouldShow = widget.controller.text.isEmpty;
      if (shouldShow != _showHint) {
        setState(() {
          _showHint = shouldShow;
          if (_showHint) {
            _startTyping();
          } else {
            _stopTyping();
          }
        });
      }
    });
  }

  void _startTyping() {
    _stopTyping();
    _displayedHint = '';
    int charIndex = 0;
    final currentFullHint = widget.hints[_currentHintIndex];

    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (charIndex < currentFullHint.length) {
        if (mounted) {
          setState(() {
            _displayedHint = currentFullHint.substring(0, charIndex + 1);
          });
        }
        charIndex++;
      } else {
        timer.cancel();
        // Wait 2 seconds before starting the next hint
        _cycleTimer = Timer(const Duration(seconds: 2), () {
          if (mounted && _showHint) {
            setState(() {
              _currentHintIndex = (_currentHintIndex + 1) % widget.hints.length;
              _startTyping();
            });
          }
        });
      }
    });
  }

  void _stopTyping() {
    _typingTimer?.cancel();
    _cycleTimer?.cancel();
  }

  @override
  void dispose() {
    _stopTyping();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        ProfessionalTextField(
          controller: widget.controller,
          hintText: '',
          prefixIcon: widget.prefixIcon,
          onFieldSubmitted: widget.onFieldSubmitted,
        ),
        if (_showHint)
          Positioned(
            left: 48,
            child: IgnorePointer(
              child: Row(
                children: [
                  Text(
                    _displayedHint,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Blinking cursor
                  _BlinkingCursor(isDark: isDark),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({required this.isDark});
  final bool isDark;

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 18,
        color: widget.isDark ? Colors.white38 : Colors.black38,
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
    final l10n = AppLocalizations.of(context);
    final hints = [
      l10n?.searchHint ?? 'Search products…',
      'Search MacBook Pro…',
      'Search iPhone 16…',
      'Search Apple Watch…',
      'Search AirPods…',
    ];

    return AnimatedHintTextField(
      controller: _controller,
      hints: hints,
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
      imageHeightFactor: 0.88,
    ),
    PromoBannerData(
      title: 'iPhone 16 Pro',
      subtitle: 'Hello, Apple Intelligence.',
      imagePath: 'assets/images/iphone_16_pro.png',
      colors: [const Color(0xFF3C3B3F), const Color(0xFF605C5E)],
      actionText: 'Learn More',
      imageHeightFactor: 0.98,
    ),
    PromoBannerData(
      title: 'Watch Ultra 2',
      subtitle: 'New finish. Never finished.',
      imagePath: 'assets/images/watch_ultra.png',
      colors: [const Color(0xFFD35400), const Color(0xFF2C3E50)],
      actionText: 'Explore Ultra',
      imageHeightFactor: 0.98,
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
        LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = AppSpacing.xxl * 2;
            final cardWidth = math.max(
              0.0,
              constraints.maxWidth - horizontalPadding,
            );
            final carouselHeight = (cardWidth * 0.35).clamp(180.0, 240.0);

            return SizedBox(
              height: carouselHeight,
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
                        value = (1 - (value * 0.06)).clamp(0.0, 1.0);
                      }
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: _PromoBannerCard(banner: banner),
                    ),
                  );
                },
              ),
            );
          },
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

class _PromoBannerCard extends StatelessWidget {
  const _PromoBannerCard({required this.banner});

  final PromoBannerData banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background accents
          Positioned(
            right: -20,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                28,
                20,
                24,
                20,
              ), // Increased right padding to 24
              child: Row(
                children: [
                  Expanded(flex: 12, child: _PromoBannerCopy(banner: banner)),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 10,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        heightFactor: banner.imageHeightFactor,
                        child: ProductImageBox(
                          imagePath: banner.imagePath,
                          fit: BoxFit.contain,
                          animate: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBannerCopy extends StatelessWidget {
  const _PromoBannerCopy({required this.banner});

  final PromoBannerData banner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 200;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Professional Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context)?.latestRelease ?? 'LATEST RELEASE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              banner.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 22 : 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              banner.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w500,
                height: 1.3,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 18),
            // Action Button
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                final store = AppScope.of(context);
                store.setTab(1, searchQuery: banner.title);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _localizedActionText(context, banner.actionText),
                  style: TextStyle(
                    color: banner.colors.first,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _localizedActionText(BuildContext context, String actionText) {
    if (actionText == 'Shop MacBook') {
      return AppLocalizations.of(context)?.shopMacBook ?? actionText;
    }
    if (actionText == 'Learn More') {
      return AppLocalizations.of(context)?.learnMore ?? actionText;
    }
    if (actionText == 'Explore Ultra') {
      return AppLocalizations.of(context)?.exploreUltra ?? actionText;
    }
    return actionText;
  }
}

class PromoBannerData {
  PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.colors,
    required this.actionText,
    required this.imageHeightFactor,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> colors;
  final String actionText;
  final double imageHeightFactor;
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
