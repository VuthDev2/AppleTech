part of '../main.dart';

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({required this.store, required super.child, super.key})
    : super(notifier: store);

  final AppStore store;

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.store;
  }
}

class AppStore extends ChangeNotifier {
  AppStore({AuthService? authService})
    : authService = authService ?? LocalAuthService() {
    // Restore session if available (helps with Hot Restart)
    final existingUser = this.authService.currentUser;
    if (existingUser != null) {
      user = existingUser;
      isAuthenticated = true;
    }
  }

  final AuthService authService;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code');
    if (code != null && ['en', 'km', 'zh'].contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  bool isAuthenticated = false;
  bool isAuthLoading = false;
  String? authError;
  bool isDarkMode = false;
  UserProfile? user;
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'km', 'zh'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  final List<Product> products = sampleProducts;
  final List<CartItem> bag = <CartItem>[];
  final Set<String> wishlist = <String>{};
  final List<OrderRecord> orders = <OrderRecord>[];

  List<AppNotification> notifications = _initialNotifications();

  static List<AppNotification> _initialNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'notif-1',
        title: 'Order on the way',
        body: 'Your MacBook Pro is out for delivery. Track it in your orders.',
        createdAt: now.subtract(const Duration(hours: 2)),
        kind: NotificationKind.order,
      ),
      AppNotification(
        id: 'notif-2',
        title: 'Limited-time offer',
        body: 'Use code APPLE10 at checkout for 10% off your next purchase.',
        createdAt: now.subtract(const Duration(hours: 5)),
        kind: NotificationKind.promo,
      ),
      AppNotification(
        id: 'notif-3',
        title: 'iPhone 16 Pro is here',
        body: 'Titanium design and the A18 Pro chip — now in the Store.',
        createdAt: now.subtract(const Duration(days: 1)),
        kind: NotificationKind.product,
      ),
      AppNotification(
        id: 'notif-4',
        title: 'Wishlist price drop',
        body: 'AirPods Pro in your wishlist are now \$50 off.',
        createdAt: now.subtract(const Duration(days: 2)),
        kind: NotificationKind.product,
        isRead: true,
      ),
      AppNotification(
        id: 'notif-5',
        title: 'AppleCare+ reminder',
        body: 'Extend coverage for your devices before warranty ends.',
        createdAt: now.subtract(const Duration(days: 3)),
        kind: NotificationKind.system,
        isRead: true,
      ),
    ];
  }

  int selectedTabIndex = 0;
  String exploreSearchQuery = '';
  bool isScrolling = false;

  void setScrolling(bool scrolling) {
    if (isScrolling != scrolling) {
      isScrolling = scrolling;
      notifyListeners();
    }
  }

  void setTab(int index, {String? searchQuery}) {
    selectedTabIndex = index;
    if (searchQuery != null) {
      exploreSearchQuery = searchQuery;
    }
    notifyListeners();
  }

  void clearExploreSearchQuery() {
    exploreSearchQuery = '';
  }

  final List<ShippingAddress> addresses = <ShippingAddress>[
    const ShippingAddress(
      id: 'addr-1',
      fullName: 'Kry Saravuth',
      street: '123 AppleTech Way, Apt 4B',
      city: 'Cupertino, CA',
      postalCode: '95014',
      phone: '+1 (555) 019-2834',
      isDefault: true,
    ),
  ];

  final List<PaymentCard> cards = <PaymentCard>[
    const PaymentCard(
      id: 'card-1',
      cardholderName: 'Kry Saravuth',
      cardNumber: '•••• •••• •••• 4242',
      expiryDate: '12/28',
      cvv: '123',
      brand: 'Visa Signature',
      themeColor: Color(0xFF0071E3), // Apple Blue
    ),
    const PaymentCard(
      id: 'card-2',
      cardholderName: 'Kry Saravuth',
      cardNumber: '•••• •••• •••• 8888',
      expiryDate: '09/29',
      cvv: '999',
      brand: 'Apple Card',
      themeColor: Color(0xFF1F1F1F), // Space Black
    ),
  ];

  String? appliedPromoCode;

  void addAddress(ShippingAddress address) {
    addresses.add(address);
    notifyListeners();
  }

  void removeAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void addCard(PaymentCard card) {
    cards.add(card);
    notifyListeners();
  }

  void removeCard(String id) {
    cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    final cleaned = code.trim().toUpperCase();
    if (cleaned == 'APPLE10' || cleaned == 'WELCOME') {
      appliedPromoCode = cleaned;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearPromoCode() {
    appliedPromoCode = null;
    notifyListeners();
  }

  void addReview(String productId, Review review) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final oldProduct = products[index];
      final newReviews = List<Review>.from(oldProduct.reviews)
        ..insert(0, review);

      final newReviewCount = oldProduct.reviewCount + 1;
      final newRating = double.parse(
        ((oldProduct.rating * oldProduct.reviewCount + review.rating) /
                newReviewCount)
            .toStringAsFixed(1),
      );

      products[index] = Product(
        id: oldProduct.id,
        name: oldProduct.name,
        category: oldProduct.category,
        tagline: oldProduct.tagline,
        description: oldProduct.description,
        detailedDescription: oldProduct.detailedDescription,
        basePrice: oldProduct.basePrice,
        specs: oldProduct.specs,
        accent: oldProduct.accent,
        icon: oldProduct.icon,
        imagePath: oldProduct.imagePath,
        variants: oldProduct.variants,
        rating: newRating,
        reviewCount: newReviewCount,
        reviews: newReviews,
        warranty: oldProduct.warranty,
        inStock: oldProduct.inStock,
        releaseDate: oldProduct.releaseDate,
        keyFeatures: oldProduct.keyFeatures,
        featured: oldProduct.featured,
      );
      notifyListeners();
    }
  }

  // Demo status bar settings
  String demoTime = '9:41';
  String demoDate = 'Tue, May 19';
  double demoBatteryLevel = 1.0;
  bool demoWifiConnected = true;

  void updateDemoStatus({
    String? time,
    String? date,
    double? battery,
    bool? wifi,
  }) {
    if (time != null) demoTime = time;
    if (date != null) demoDate = date;
    if (battery != null) demoBatteryLevel = battery;
    if (wifi != null) demoWifiConnected = wifi;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _runAuthAction(() async {
      final result = await authService.signIn(email: email, password: password);
      user = result.user;
      isAuthenticated = true;
    });
  }

  // New Google Sign-In method
  Future<bool> signInWithGoogle() async {
    return _runAuthAction(() async {
      final result = await authService.signInWithGoogle();
      user = result.user;
      isAuthenticated = true;
    });
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final result = await authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      user = result.user;
      isAuthenticated = true;
    });
  }

  Future<bool> requestPasswordReset({required String email}) async {
    return _runAuthAction(() {
      return authService.requestPasswordReset(email: email);
    });
  }

  Future<bool> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    return _runAuthAction(() {
      return authService.verifyPasswordResetCode(email: email, code: code);
    });
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return _runAuthAction(() {
      return authService.confirmPasswordReset(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    });
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    isAuthLoading = true;
    authError = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on AuthCancelledException {
      return false;
    } on AuthException catch (error) {
      authError = error.message;
      return false;
    } catch (_) {
      authError = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isAuthLoading = false;
      notifyListeners();
    }
  }

  void updateUserProfile({required String name, required String email}) {
    if (user != null) {
      user = UserProfile(
        uid: user!.uid,
        name: name.trim().isEmpty ? 'AppleTech Customer' : name.trim(),
        email: email.trim().isEmpty ? 'customer@apple.com' : email.trim(),
        createdAt: user!.createdAt,
      );
    } else {
      user = UserProfile(
        uid: 'uid-guest',
        name: name.trim().isEmpty ? 'AppleTech Customer' : name.trim(),
        email: email.trim().isEmpty ? 'customer@apple.com' : email.trim(),
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await authService.signOut();
    isAuthenticated = false;
    user = null;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  void markNotificationRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;
    notifications[index] = notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllNotificationsRead() {
    var changed = false;
    for (var i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void removeNotification(String id) {
    final before = notifications.length;
    notifications.removeWhere((n) => n.id == id);
    if (notifications.length < before) notifyListeners();
  }

  void pushNotification(AppNotification notification) {
    notifications.insert(0, notification);
    notifyListeners();
  }

  Product productById(String id) => products.firstWhere((p) => p.id == id);

  Variant variantById(String productId, String variantId) {
    return productById(productId).variants.firstWhere((v) => v.id == variantId);
  }

  void toggleWishlist(String productId) {
    wishlist.contains(productId)
        ? wishlist.remove(productId)
        : wishlist.add(productId);
    notifyListeners();
  }

  void addToBag(Product product, Variant variant) {
    final index = bag.indexWhere(
      (item) => item.productId == product.id && item.variantId == variant.id,
    );
    if (index == -1) {
      bag.add(CartItem(productId: product.id, variantId: variant.id));
    } else if (bag[index].quantity < variant.stock) {
      bag[index] = bag[index].copyWith(quantity: bag[index].quantity + 1);
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      bag.remove(item);
    } else {
      final variant = variantById(item.productId, item.variantId);
      final index = bag.indexOf(item);
      bag[index] = item.copyWith(quantity: math.min(quantity, variant.stock));
    }
    notifyListeners();
  }

  void removeFromBag(CartItem item) {
    bag.remove(item);
    notifyListeners();
  }

  void clearBag() {
    bag.clear();
    notifyListeners();
  }

  int get bagCount => bag.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal {
    return bag.fold(0, (sum, item) {
      final variant = variantById(item.productId, item.variantId);
      return sum + (variant.price * item.quantity);
    });
  }

  int get discount {
    if (appliedPromoCode == 'APPLE10') {
      return (subtotal * 0.10).round();
    } else if (appliedPromoCode == 'WELCOME') {
      return math.min(20, subtotal);
    }
    return 0;
  }

  int get discountedSubtotal => subtotal - discount;

  int get tax => (discountedSubtotal * 0.08).round();

  int get total => discountedSubtotal + tax;

  void completeCheckout() {
    if (bag.isEmpty) return;
    final orderId = 'AT-${1000 + orders.length}';
    orders.insert(
      0,
      OrderRecord(
        id: orderId,
        placedAt: DateTime.now(),
        total: total,
        items: List<CartItem>.from(bag),
        status: 'Preparing for delivery',
      ),
    );
    pushNotification(
      AppNotification(
        id: 'notif-order-$orderId',
        title: 'Order confirmed',
        body: 'Order $orderId is being prepared for delivery.',
        createdAt: DateTime.now(),
        kind: NotificationKind.order,
      ),
    );
    bag.clear();
    appliedPromoCode = null;
    notifyListeners();
  }
}
