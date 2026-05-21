part of '../main.dart';

class StoreShell extends StatefulWidget {
  const StoreShell({super.key});

  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildStatusBar(BuildContext context, AppStore store) {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? Colors.white : Colors.black87;
    // Full status-bar inset once only — do not wrap this widget in SafeArea or it
    // stacks below the notch/island and looks unrealistically low.
    final safeTop = MediaQuery.paddingOf(context).top;

    if (isIOS) {
      // iOS: time + trailing indicators share one row, vertically centered in the top inset.
      return SizedBox(
        height: safeTop > 0 ? safeTop : 20.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Left: Time
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatTime(_now),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              // Right: Status Icons
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Signal bars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(4, (index) {
                        final active = index < 3; // 3 bars active
                        return Container(
                          width: 2.8,
                          height: 3.5 + (index * 2.2),
                          margin: const EdgeInsets.only(left: 1.8),
                          decoration: BoxDecoration(
                            color: active ? barColor : barColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(0.5),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 5),
                    // WiFi
                    Icon(
                      store.demoWifiConnected ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
                      size: 14.0,
                      color: barColor,
                    ),
                    const SizedBox(width: 5),
                    // Battery
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 11.0,
                          padding: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: barColor.withValues(alpha: 0.8), width: 1.0),
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: 0.88,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: BorderRadius.circular(1.2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 0.5),
                        Container(
                          width: 1.0,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: barColor.withValues(alpha: 0.8),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(0.8),
                              bottomRight: Radius.circular(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final top = safeTop > 0 ? safeTop : 24.0;
      return SizedBox(
        height: top,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Left: Time & notification dots
              Text(
                _formatTime(_now),
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.mail_outline_rounded,
                size: 13.0,
                color: barColor.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              // Right: Status Icons
              Icon(
                store.demoWifiConnected ? Icons.wifi : Icons.wifi_off_rounded,
                size: 14,
                color: barColor,
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.signal_cellular_4_bar_rounded,
                size: 14,
                color: barColor,
              ),
              const SizedBox(width: 6),
              Text(
                '88%',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(width: 4),
              // Android vertical battery icon
              Container(
                width: 9.0,
                height: 13.5,
                decoration: BoxDecoration(
                  border: Border.all(color: barColor.withValues(alpha: 0.8), width: 1.0),
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: const EdgeInsets.all(0.8),
                child: Column(
                  children: [
                    Container(
                      height: 1.5,
                      color: Colors.transparent,
                    ),
                    Expanded(
                      child: Container(
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildHomeIndicator(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final barColor = isDark
        ? Colors.white.withValues(alpha: 0.82)
        : Colors.black.withValues(alpha: 0.72);

    // Tab bar floats above; home indicator sits in the system safe area below it.
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom: bottomInset > 0 ? math.max(bottomInset - 6, 4) : 12,
      ),
      child: Center(
        child: Container(
          width: isIOS ? 134 : 96,
          height: isIOS ? 5 : 3.5,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final tabIndex = store.selectedTabIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;

    final screens = <Widget>[
      const HomeScreen(),
      const ExploreScreen(),
      const WishlistScreen(),
      const BagScreen(),
      const ProfileScreen(),
    ];

    // Define platform-specific icons and labels
    final iosIcons = <IconData>[
      CupertinoIcons.house,
      CupertinoIcons.search,
      CupertinoIcons.heart,
      CupertinoIcons.bag,
      CupertinoIcons.person_crop_circle,
    ];
    final iosActiveIcons = <IconData>[
      CupertinoIcons.house_fill,
      CupertinoIcons.search,
      CupertinoIcons.heart_fill,
      CupertinoIcons.bag_fill,
      CupertinoIcons.person_crop_circle_fill,
    ];

    final androidIcons = <IconData>[
      Icons.home_outlined,
      Icons.search_rounded,
      Icons.favorite_border_rounded,
      Icons.shopping_bag_outlined,
      Icons.person_outline_rounded,
    ];
    final androidActiveIcons = <IconData>[
      Icons.home_filled,
      Icons.search_rounded,
      Icons.favorite_rounded,
      Icons.shopping_bag_rounded,
      Icons.person_rounded,
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Mock OS status bar — height is exactly MediaQuery.padding.top (no extra SafeArea).
          ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: _buildStatusBar(context, store),
          ),
          // Main screen view (removing top padding to prevent double SafeArea spacing)
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: IndexedStack(
                index: tabIndex,
                children: screens,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / 5;
                final targetSelectedLeft = (tabWidth * tabIndex) + (tabWidth - 56) / 2;

                final fillColor = isDark
                    ? const Color(0xFF2A2A2E).withValues(alpha: 0.42)
                    : Colors.white.withValues(alpha: 0.58);
                final borderColor = isDark
                    ? Colors.white.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.92);
                final activeRingColor = isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.95);

                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: targetSelectedLeft),
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedSelectedLeft, child) {
                    final activeX = animatedSelectedLeft + 28.0;

                    return SizedBox(
                      height: 68,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipPath(
                            clipper: TabBarClipper(activeX: activeX),
                            child: SizedBox(
                              height: 68,
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                                      child: const ColoredBox(
                                        color: Color(0x01FFFFFF),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: isDark
                                            ? [
                                                Colors.white.withValues(alpha: 0.14),
                                                Colors.white.withValues(alpha: 0.04),
                                                Colors.black.withValues(alpha: 0.18),
                                              ]
                                            : [
                                                Colors.white.withValues(alpha: 0.78),
                                                Colors.white.withValues(alpha: 0.52),
                                                Colors.white.withValues(alpha: 0.38),
                                              ],
                                        stops: const [0.0, 0.42, 1.0],
                                      ),
                                    ),
                                  ),
                                  CustomPaint(
                                    painter: TabBarPainter(
                                      activeX: activeX,
                                      isDark: isDark,
                                      borderColor: borderColor,
                                      fillColor: fillColor,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      final isSelected = tabIndex == index;
                                      final inactiveColor = isDark
                                          ? Colors.white.withValues(alpha: 0.42)
                                          : const Color(0xFF8E8E93);
                                      final icons = isIOS ? iosIcons : androidIcons;

                                      return Expanded(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => store.setTab(index),
                                          child: Center(
                                            child: isSelected
                                                ? const SizedBox.shrink()
                                                : (index == 3
                                                    ? Badge.count(
                                                        count: store.bagCount,
                                                        isLabelVisible: store.bagCount > 0,
                                                        backgroundColor: AppColors.primary,
                                                        textColor: Colors.white,
                                                        child: Icon(
                                                          icons[index],
                                                          size: 23,
                                                          color: inactiveColor,
                                                        ),
                                                      )
                                                    : Icon(
                                                        icons[index],
                                                        size: 23,
                                                        color: inactiveColor,
                                                      )),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                          left: animatedSelectedLeft,
                          top: -14,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => store.setTab(tabIndex),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF5EB0FF),
                                    AppColors.primary,
                                    Color(0xFF0066E0),
                                  ],
                                  stops: [0.0, 0.5, 1.0],
                                ),
                                border: Border.all(
                                  color: activeRingColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.45),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.55),
                                    blurRadius: 6,
                                    offset: const Offset(-2, -3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: tabIndex == 3
                                    ? Badge.count(
                                        count: store.bagCount,
                                        isLabelVisible: store.bagCount > 0,
                                        backgroundColor: Colors.white,
                                        textColor: AppColors.primary,
                                        child: Icon(
                                          isIOS ? iosActiveIcons[tabIndex] : androidActiveIcons[tabIndex],
                                          size: 23,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        isIOS ? iosActiveIcons[tabIndex] : androidActiveIcons[tabIndex],
                                        size: 23,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildHomeIndicator(context),
        ],
      ),
    );
  }
}

// --- Custom Tab Bar Painting & Clipping helpers ---

Path getHumpPath(double cx) {
  final path = Path();
  final double humpWidth = 72.0;
  final double startX = cx - humpWidth / 2;
  final double endX = cx + humpWidth / 2;
  
  path.moveTo(startX, 0);
  
  // Left transition: S-curve
  path.cubicTo(
    cx - 30, 0,
    cx - 27, -10.0,
    cx - 22, -10.0,
  );
  
  // Circular arch over the top
  path.arcToPoint(
    Offset(cx + 22, -10.0),
    radius: const Radius.circular(31.5),
    clockwise: true,
  );
  
  // Right transition: S-curve
  path.cubicTo(
    cx + 27, -10.0,
    cx + 30, 0,
    endX, 0,
  );
  
  path.lineTo(endX, 15);
  path.lineTo(startX, 15);
  path.close();
  
  return path;
}

Path getTabBarPath(Size size, double activeX) {
  final w = size.width;
  final h = size.height;
  final r = 28.0; // corner radius of the tab bar itself

  // Path 1: Rounded Rectangle
  final path1 = Path()
    ..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(r),
    ));

  // Path 2: Hump
  final path2 = getHumpPath(activeX);

  // Combine them using union to create a single continuous shape
  final combined = Path.combine(PathOperation.union, path1, path2);
  
  // Intersect with horizontal bounds to prevent bleed-through at far-left/right edges
  final bounds = Path()..addRect(Rect.fromLTWH(0, -30, w, h + 30));
  final finalPath = Path.combine(PathOperation.intersect, combined, bounds);
  
  return finalPath;
}

class TabBarClipper extends CustomClipper<Path> {
  final double activeX;
  TabBarClipper({required this.activeX});

  @override
  Path getClip(Size size) {
    return getTabBarPath(size, activeX);
  }

  @override
  bool shouldReclip(covariant TabBarClipper oldClipper) {
    return oldClipper.activeX != activeX;
  }
}

class TabBarPainter extends CustomPainter {
  final double activeX;
  final bool isDark;
  final Color borderColor;
  final Color fillColor;

  TabBarPainter({
    required this.activeX,
    required this.isDark,
    required this.borderColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = getTabBarPath(size, activeX);
    final bounds = path.getBounds();

    canvas.drawShadow(
      path,
      isDark ? Colors.black.withValues(alpha: 0.55) : Colors.black.withValues(alpha: 0.1),
      22,
      false,
    );

    // Liquid glass body — soft tint over the backdrop blur.
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          fillColor.withValues(alpha: isDark ? 0.55 : 0.72),
          fillColor.withValues(alpha: isDark ? 0.28 : 0.38),
          fillColor.withValues(alpha: isDark ? 0.42 : 0.55),
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Specular highlight near the active tab (liquid refraction).
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          ((activeX / size.width) * 2) - 1,
          -0.65,
        ),
        radius: 0.55,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.16 : 0.55),
          Colors.transparent,
        ],
      ).createShader(bounds);
    canvas.drawPath(path, glowPaint);

    // Top-edge light catch (Telegram-style glass rim).
    final rimPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.28 : 0.85),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.35],
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, rimPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TabBarPainter oldDelegate) {
    return oldDelegate.activeX != activeX ||
        oldDelegate.isDark != isDark ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor;
  }
}
