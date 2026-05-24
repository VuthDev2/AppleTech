part of '../../main.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String query = '';
  String category = 'All';
  String sortBy = 'none'; // 'none', 'price_asc', 'price_desc', 'rating'
  bool onlyInStock = false;
  bool isGridView = true;
  bool _isFocused = false;

  static final List<String> _recentSearches = <String>[
    'MacBook Pro',
    'MacBook Air',
    'iPad Pro',
  ];

  static const List<String> _trendingSearches = <String>[
    'MacBook Pro 16-inch',
    'MacBook Air 15',
    'iPad Pro',
    'iMac',
    'Apple Watch Ultra 3',
    'AirPods Pro 3rd gen',
    '512GB SSD',
    '64GB unified memory',
  ];

  final List<Map<String, dynamic>> collectionBanners = <Map<String, dynamic>>[
    {
      'category': 'Mac',
      'tagline': 'Supercharged for pro workflows.',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E252B), Color(0xFF0C1013)],
      ),
      'imagePath': productImageFor('mbp-16-m4m-2024'),
      'accent': const Color(0xFF7D8A95),
    },
    {
      'category': 'iPhone',
      'tagline': 'Titanium. Built for Apple Intelligence.',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2C2520), Color(0xFF15110E)],
      ),
      'imagePath': productImageFor('iphone-16-pro-un'),
      'accent': const Color(0xFFC9B8A6),
    },
    {
      'category': 'iPad',
      'tagline': 'Impossibly thin. Unreal power.',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1C2833), Color(0xFF0A121A)],
      ),
      'imagePath': productImageFor('ipad-pro-13-m4-2024'),
      'accent': const Color(0xFF9EC5DD),
    },
    {
      'category': 'Watch',
      'tagline': 'Ultimate sports & adventure watch.',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2D1F18), Color(0xFF130D0A)],
      ),
      'imagePath': productImageFor('watch-ultra-2-2023'),
      'accent': const Color(0xFFF28C38),
    },
    {
      'category': 'AirPods',
      'tagline': 'Everything you hear is unheard of.',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF252729), Color(0xFF0F1011)],
      ),
      'imagePath': productImageFor('airpods-pro-2-2022'),
      'accent': const Color(0xFFE7E9EA),
    },
    {
      'category': 'iMac',
      'tagline': 'All-in-one. All-in on color.',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A2A3A), Color(0xFF0A1218)],
      ),
      'imagePath': productImageFor('imac-24-m4-2024'),
      'accent': const Color(0xFF5E9FD6),
    },
    {
      'category': 'Accessories',
      'tagline': 'Essentials for your devices.',
      'gradient': const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF333333), Color(0xFF111111)],
      ),
      'imagePath': productImageFor('magic-mouse-2024'),
      'accent': const Color(0xFFAAAAAA),
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _searchFocusNode.hasFocus;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = AppScope.of(context);
    if (store.exploreSearchQuery.isNotEmpty) {
      final newQuery = store.exploreSearchQuery;
      store.clearExploreSearchQuery();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            query = newQuery;
            _searchController.text = newQuery;
            _addToRecentSearches(newQuery);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _addToRecentSearches(String searchTerm) {
    if (searchTerm.trim().isEmpty) return;
    setState(() {
      _recentSearches.remove(searchTerm);
      _recentSearches.insert(0, searchTerm);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });
  }

  void _performSearch(String searchTerm) {
    setState(() {
      query = searchTerm;
      _searchController.text = searchTerm;
      _addToRecentSearches(searchTerm);
      _searchFocusNode.unfocus();
    });
  }

  void _clearSearch() {
    setState(() {
      query = '';
      _searchController.clear();
      category = 'All';
    });
  }

  Widget _buildScrollableBody(AppStore store, bool isDark) {
    // 1. Suggestions State
    if (_isFocused && query.isNotEmpty) {
      final suggestions = store.products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase());
      }).toList();

      if (suggestions.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.search, size: 48, color: AppColors.mediumGray),
                const SizedBox(height: 12),
                Text(
                  'No quick matches for "$query"',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Press enter to view full search results.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mediumGray, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => Divider(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final product = suggestions[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: const Icon(CupertinoIcons.search, size: 18, color: AppColors.mediumGray),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(
              product.category,
              style: const TextStyle(color: AppColors.mediumGray, fontSize: 12),
            ),
            trailing: const Icon(CupertinoIcons.arrow_up_left, size: 16, color: AppColors.mediumGray),
            onTap: () => _performSearch(product.name),
          );
        },
      );
    }

    // 2. Discover State (Empty query)
    if (query.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.4,
                      ),
                ),
                TextButton(
                  onPressed: () => setState(() => _recentSearches.clear()),
                  child: const Text('Clear', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _recentSearches.map((term) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InputChip(
                      label: Text(term),
                      onPressed: () => _performSearch(term),
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white : AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Trending Searches
          Text(
            'Trending',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
          ),
          const SizedBox(height: 12),
          ..._trendingSearches.map((term) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.graph_square, size: 16, color: AppColors.primary),
              ),
              title: Text(
                term,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              trailing: const Icon(CupertinoIcons.chevron_right, size: 14, color: AppColors.mediumGray),
              onTap: () => _performSearch(term),
            );
          }),

          const SizedBox(height: 28),

          // Explore Collections Banners
          Text(
            'Explore Collections',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
          ),
          const SizedBox(height: 14),
          ...collectionBanners.map((banner) {
            return ExploreCollectionCard(
              category: banner['category'],
              tagline: banner['tagline'],
              gradient: banner['gradient'],
              imagePath: banner['imagePath'],
              accent: banner['accent'],
              onTap: () {
                setState(() {
                  category = banner['category'];
                  query = banner['category'];
                  _searchController.text = banner['category'];
                  _addToRecentSearches(banner['category']);
                });
              },
            );
          }),
        ],
      );
    }

    // 3. Search Results State
    final filtered = store.products.where((product) {
      final matchesCategory = category == 'All' || product.category == category;
      final matchesQuery = productMatchesSearch(product, query);
      return matchesCategory && matchesQuery;
    }).toList();

    // Sort Results
    if (sortBy == 'price_asc') {
      filtered.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (sortBy == 'price_desc') {
      filtered.sort((a, b) => b.basePrice.compareTo(a.basePrice));
    } else if (sortBy == 'rating') {
      filtered.sort((a, b) => a.rating.compareTo(a.rating));
    }

    // Filter Stock
    if (onlyInStock) {
      filtered.removeWhere((p) => !p.inStock);
    }

    return Column(
      children: [
        // Filter & Control Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} ${filtered.length == 1 ? "result" : "results"} for "$query"',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  // Sort Dropdown Button
                  Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
                    ),
                    child: PopupMenuButton<String>(
                      initialValue: sortBy,
                      icon: const Icon(CupertinoIcons.sort_down, size: 18, color: AppColors.primary),
                      tooltip: 'Sort results',
                      onSelected: (val) => setState(() => sortBy = val),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'none', child: Text('Default Order')),
                        const PopupMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                        const PopupMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                        const PopupMenuItem(value: 'rating', child: Text('Top Rated')),
                      ],
                    ),
                  ),

                  // Toggle Stock
                  GestureDetector(
                    onTap: () => setState(() => onlyInStock = !onlyInStock),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: onlyInStock ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                        border: Border.all(
                          color: onlyInStock ? AppColors.primary : (isDark ? Colors.white24 : Colors.black12),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'In Stock',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: onlyInStock ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ),

                  // Toggle Grid/List layout
                  GestureDetector(
                    onTap: () => setState(() => isGridView = !isGridView),
                    child: Icon(
                      isGridView ? CupertinoIcons.list_bullet : CupertinoIcons.square_grid_2x2,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Results Display
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      EmptyState(
                        icon: CupertinoIcons.search,
                        title: 'No products found',
                        subtitle:
                            'We couldn\'t find anything matching your search. Try adjusting filters or search for another term.',
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Try searching for:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: _trendingSearches.map((term) {
                          return ActionChip(
                            label: Text(term),
                            onPressed: () => _performSearch(term),
                            side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
              : isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: filtered.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) => ProductGridCard(product: filtered[index]),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => ProductListTile(product: filtered[index]),
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Gorgeous Apple Store Search Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)?.explore ?? 'Explore',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                  ),
                  StoreUserAvatar(
                    name: store.user?.name ?? 'AppleTech Customer',
                    photoUrl: store.user?.photoUrl,
                    size: 36,
                    onTap: () => store.setTab(4),
                  ),
                ],
              ),
            ),

            // Search Input Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.fastOutSlowIn,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFEFEFF4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (val) => setState(() => query = val),
                        onSubmitted: (val) => _performSearch(val),
                        style: TextStyle(
                          fontSize: 16.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)?.searchHint ?? 'Search MacBook, iPad, iPhone…',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 15.5,
                          ),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: isDark ? Colors.white38 : Colors.black45,
                            size: 19,
                          ),
                          suffixIcon: query.isNotEmpty
                              ? GestureDetector(
                                  onTap: _clearSearch,
                                  child: Icon(
                                    CupertinoIcons.clear_thick_circled,
                                    color: isDark ? Colors.white54 : Colors.black38,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),

                  // Animated Cancel Button
                  AnimatedCrossFade(
                    firstChild: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: TextButton(
                        onPressed: () {
                          _searchFocusNode.unfocus();
                          _clearSearch();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.cancel ?? 'Cancel',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState:
                        _isFocused || query.isNotEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),

            // Divider Line
            Divider(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              height: 1,
              thickness: 0.5,
            ),

            // Scrollable Content
            Expanded(
              child: _buildScrollableBody(store, isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreCollectionCard extends StatefulWidget {
  const ExploreCollectionCard({
    required this.category,
    required this.tagline,
    required this.gradient,
    required this.imagePath,
    required this.accent,
    required this.onTap,
    super.key,
  });

  final String category;
  final String tagline;
  final LinearGradient gradient;
  final String imagePath;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<ExploreCollectionCard> createState() => _ExploreCollectionCardState();
}

class _ExploreCollectionCardState extends State<ExploreCollectionCard> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHighlighted = true),
      onExit: (_) => setState(() => _isHighlighted = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHighlighted = true),
        onTapUp: (_) => setState(() => _isHighlighted = false),
        onTapCancel: () => setState(() => _isHighlighted = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _isHighlighted ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Stack(
              clipBehavior: Clip.none, // Allow images to pop out!
              children: [
                // Main Box
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                        if (_isHighlighted)
                          BoxShadow(
                            color: widget.accent.withValues(alpha: 0.3),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                  ),
                ),

                // Subtle Accent Glow
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.accent.withValues(alpha: 0.12),
                          widget.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Text Content
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  right: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.category.toUpperCase(),
                        style: TextStyle(
                          color: widget.accent.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore',
                            style: TextStyle(
                              color: widget.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(CupertinoIcons.chevron_right, size: 10, color: widget.accent),
                        ],
                      ),
                    ],
                  ),
                ),

                // Product Image - THE POP OUT EFFECT
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  right: _isHighlighted ? -20 : 5,
                  bottom: _isHighlighted ? -20 : 10,
                  top: _isHighlighted ? -20 : 10,
                  child: AnimatedScale(
                    scale: _isHighlighted ? 1.20 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    child: Hero(
                      tag: 'collection-image-${widget.category}',
                      child: SizedBox(
                        width: 160,
                        child: ProductImageBox(
                          imagePath: widget.imagePath,
                          fit: BoxFit.contain,
                          animate: !_isHighlighted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
