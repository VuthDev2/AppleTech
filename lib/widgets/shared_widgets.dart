part of '../main.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.customArt,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? customArt;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppAnimations.slow,
      curve: AppAnimations.smooth,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customArt != null)
                customArt!
              else
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mediumGray,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-color logo for app chrome. Do not use `Image.asset(..., color:)` here:
/// `logo_apt.png` is not an alpha-only glyph, so a color filter draws a solid block.
class StoreBrandMark extends StatelessWidget {
  const StoreBrandMark({super.key, this.height = 26});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/appletech_logo.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class WishlistEmptyArt extends StatefulWidget {
  const WishlistEmptyArt({super.key});

  @override
  State<WishlistEmptyArt> createState() => _WishlistEmptyArtState();
}

class _WishlistEmptyArtState extends State<WishlistEmptyArt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.brightness == Brightness.dark
        ? AppColors.white
        : AppColors.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(180, 180),
          painter: WishlistEmptyPainter(_controller.value * 2 * math.pi, primary),
        );
      },
    );
  }
}

class WishlistEmptyPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  WishlistEmptyPainter(this.progress, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = LinearGradient(
        colors: [primaryColor.withValues(alpha: 0.4), primaryColor.withValues(alpha: 0.02)],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    // Outer circle
    canvas.drawCircle(center, size.width / 2, paint);

    // Inner dashed circle
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = primaryColor.withValues(alpha: 0.25);
    
    double radius = size.width / 2.8;
    int dashCount = 24;
    double dashLength = (2 * math.pi * radius) / (dashCount * 2);
    for (int i = 0; i < dashCount; i++) {
      double startAngle = (i * 2 * math.pi / dashCount) + (progress * 0.1);
      double sweepAngle = dashLength / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        dashPaint,
      );
    }

    // Draw beautiful heart path in the center
    final heartPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        colors: [
          Colors.pinkAccent,
          Colors.deepOrangeAccent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 24));

    final path = Path();
    final width = 48.0;
    final height = 48.0;
    final x = center.dx - width / 2;
    final y = center.dy - height / 2 + 4 + (math.sin(progress) * 3); // floating offset

    path.moveTo(x + width / 2, y + height / 4);
    path.cubicTo(x + width * 6 / 7, y + height * 0, x + width * 13 / 14, y + height * 2 / 5, x + width / 2, y + height * 7 / 8);
    path.cubicTo(x + width * 1 / 14, y + height * 2 / 5, x + width * 1 / 7, y + height * 0, x + width / 2, y + height / 4);
    path.close();

    // Heart shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.pinkAccent.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(path, heartPaint);
    
    // Sparkles
    final starPaint = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    
    double sp1X = center.dx - 32 + (math.cos(progress * 1.5) * 4);
    double sp1Y = center.dy - 32 + (math.sin(progress * 1.5) * 4);
    canvas.drawCircle(Offset(sp1X, sp1Y), 2.5, starPaint);

    double sp2X = center.dx + 30 + (math.sin(progress * 2) * 3);
    double sp2Y = center.dy + 15 + (math.cos(progress * 2) * 3);
    canvas.drawCircle(Offset(sp2X, sp2Y), 2.0, starPaint);
  }

  @override
  bool shouldRepaint(covariant WishlistEmptyPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.primaryColor != primaryColor;
}

class BagEmptyArt extends StatefulWidget {
  const BagEmptyArt({super.key});

  @override
  State<BagEmptyArt> createState() => _BagEmptyArtState();
}

class _BagEmptyArtState extends State<BagEmptyArt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.brightness == Brightness.dark
        ? AppColors.white
        : AppColors.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(180, 180),
          painter: BagEmptyPainter(_controller.value * 2 * math.pi, primary),
        );
      },
    );
  }
}

class BagEmptyPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  BagEmptyPainter(this.progress, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = LinearGradient(
        colors: [primaryColor.withValues(alpha: 0.4), primaryColor.withValues(alpha: 0.02)],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    // Outer circle
    canvas.drawCircle(center, size.width / 2, paint);

    // Inner dashed circle
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = primaryColor.withValues(alpha: 0.25);
    
    double radius = size.width / 2.8;
    int dashCount = 24;
    double dashLength = (2 * math.pi * radius) / (dashCount * 2);
    for (int i = 0; i < dashCount; i++) {
      double startAngle = (i * 2 * math.pi / dashCount) - (progress * 0.08);
      double sweepAngle = dashLength / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        dashPaint,
      );
    }

    // Draw bag shape in center
    final bagWidth = 36.0;
    final bagHeight = 40.0;
    final x = center.dx - bagWidth / 2;
    final y = center.dy - bagHeight / 2 + 5 + (math.cos(progress) * 3); // floating offset

    // Bag Handle
    final handlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = primaryColor.withValues(alpha: 0.85);
    
    canvas.drawArc(
      Rect.fromLTWH(x + 8, y - 8, bagWidth - 16, 16),
      math.pi,
      math.pi,
      false,
      handlePaint,
    );

    // Bag Body
    final bagPath = Path()
      ..moveTo(x, y)
      ..lineTo(x + 4, y + bagHeight)
      ..quadraticBezierTo(x + 5, y + bagHeight + 3, x + 8, y + bagHeight + 3)
      ..lineTo(x + bagWidth - 8, y + bagHeight + 3)
      ..quadraticBezierTo(x + bagWidth - 5, y + bagHeight + 3, x + bagWidth - 4, y + bagHeight)
      ..lineTo(x + bagWidth, y)
      ..close();

    final bagPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.85),
          primaryColor.withValues(alpha: 0.35),
        ],
      ).createShader(Rect.fromLTWH(x, y, bagWidth, bagHeight));

    canvas.drawPath(
      bagPath,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(bagPath, bagPaint);

    // White tag circle
    final tagPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, y + bagHeight / 2 - 2), 4, tagPaint);
  }

  @override
  bool shouldRepaint(covariant BagEmptyPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.primaryColor != primaryColor;
}


String ensureTransparentImageUrl(String path) {
  if (!path.startsWith('http')) return path;
  if (path.contains('fmt=png-alpha')) return path;
  if (path.contains('fmt=')) {
    return path.replaceFirst(RegExp(r'fmt=[^&]+'), 'fmt=png-alpha');
  }
  return '$path${path.contains('?') ? '&' : '?'}fmt=png-alpha';
}

/// Fills its parent and keeps the product PNG centered with a transparent backdrop.
class ProductImageBox extends StatelessWidget {
  const ProductImageBox({
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.animate = true,
    super.key,
  });

  final String imagePath;
  final BoxFit fit;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
          return ProductImage(
            imagePath: imagePath,
            fit: fit,
            animate: animate,
          );
        }
        return ProductImage(
          imagePath: imagePath,
          width: w,
          height: h,
          fit: fit,
          animate: animate,
        );
      },
    );
  }
}

class ProductImage extends StatefulWidget {
  const ProductImage({
    required this.imagePath,
    this.width,
    this.height,
    this.size,
    this.fit = BoxFit.contain,
    this.animate = true,
    super.key,
  });

  final String imagePath;
  final double? width;
  final double? height;
  /// Legacy single dimension — applied when [width]/[height] are null.
  final double? size;
  final BoxFit fit;
  final bool animate;

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  bool _loaded = false;

  double? get _width => widget.width ?? widget.size;
  double? get _height => widget.height ?? widget.size;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    if (widget.animate) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _markLoaded() {
    if (!_loaded && mounted) {
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        widget.imagePath.startsWith('http://') || widget.imagePath.startsWith('https://');
    final url = isNetwork ? ensureTransparentImageUrl(widget.imagePath) : widget.imagePath;

    Widget image = isNetwork
        ? CachedNetworkImage(
            imageUrl: url,
            width: _width,
            height: _height,
            fit: widget.fit,
            fadeInDuration: AppAnimations.normal,
            fadeOutDuration: AppAnimations.fast,
            filterQuality: FilterQuality.high,
            placeholder: (context, _) => SizedBox(
              width: _width,
              height: _height,
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, _, _) => _errorPlaceholder(),
            imageBuilder: (context, imageProvider) {
              _markLoaded();
              return Image(
                image: imageProvider,
                width: _width,
                height: _height,
                fit: widget.fit,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              );
            },
          )
        : Image.asset(
            url,
            width: _width,
            height: _height,
            fit: widget.fit,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                _markLoaded();
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
          );

    if (!isNetwork && !_loaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _markLoaded());
    }

    image = AnimatedOpacity(
      opacity: _loaded ? 1 : 0,
      duration: AppAnimations.normal,
      curve: AppAnimations.easeOut,
      child: image,
    );

    if (widget.animate) {
      image = AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final dy = (_floatController.value - 0.5) * 10;
          return Transform.translate(offset: Offset(0, dy), child: child);
        },
        child: image,
      );
    }

    return ColoredBox(
      color: Colors.transparent,
      child: image,
    );
  }

  Widget _errorPlaceholder() {
    return SizedBox(
      width: _width,
      height: _height,
      child: const Icon(CupertinoIcons.photo, color: AppColors.mediumGray),
    );
  }
}

class ProductGlyph extends StatelessWidget {
  const ProductGlyph({
    required this.product,
    required this.size,
    this.overrideColor,
    this.showBackground = true,
    super.key,
  });

  final Product product;
  final double size;
  final Color? overrideColor;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final color = overrideColor ?? product.accent;
    return Hero(
      tag: 'product-${product.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size,
          height: size,
          decoration: showBackground
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withAlpha(40),
                      color.withAlpha(10),
                      Colors.white.withAlpha(10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(size * 0.22),
                )
              : null,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size * 0.08),
              child: ProductImage(
                imagePath: product.imagePath,
                width: size * (showBackground ? 0.82 : 0.96),
                height: size * (showBackground ? 0.82 : 0.96),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

IconData categoryIcon(String category) {
  return switch (category) {
    'Mac' => CupertinoIcons.device_laptop,
    'iPhone' => CupertinoIcons.device_phone_portrait,
    'iPad' => Icons.tablet_mac,
    'Watch' => Icons.watch,
    'AirPods' => Icons.earbuds,
    'iMac' => Icons.desktop_mac_outlined,
    _ => CupertinoIcons.square_grid_2x2,
  };
}

void openProduct(BuildContext context, Product product) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ProductDetailScreen(product: product),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: AppAnimations.easeOut);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: AppAnimations.slow,
    ),
  );
}

/// Professional text field widget
class ProfessionalTextField extends StatefulWidget {
  const ProfessionalTextField({
    required this.controller,
    required this.hintText,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String? label;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<ProfessionalTextField> createState() => _ProfessionalTextFieldState();
}

class _ProfessionalTextFieldState extends State<ProfessionalTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: _isFocused ? AppColors.white : AppColors.lightGray,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.mediumGray,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(
                color: _isFocused ? AppColors.black : AppColors.lightGray,
                width: _isFocused ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(
                color: AppColors.lightGray,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.black, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
          ),
        ),
      ],
    );
  }
}
