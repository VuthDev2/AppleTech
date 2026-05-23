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
  AppStore({
    AuthService? authService,
    this.firestoreService,
    this.profileStorage,
  }) : authService = authService ?? LocalAuthService() {
    // Restore session if already authenticated (e.g., hot restart)
    final existingUser = this.authService.currentUser;
    if (existingUser != null) {
      user = existingUser;
      isAuthenticated = true;
    }
  }

  final AuthService authService;
  final UserDataRepository? firestoreService;
  final ProfilePhotoStorage? profileStorage;

  // ── auth state ─────────────────────────────────────────────────────────────

  bool isAuthenticated = false;
  bool isAuthLoading = false;
  bool isDataLoading = false;
  bool isProfileUpdating = false;
  String? authError;
  bool isDarkMode = false;
  UserProfile? user;
  Locale? _locale;

  Locale? get locale => _locale;

  // ── initialize: restore Firestore session on cold start ───────────────────

  Future<void> initialize() async {
    await loadLocale();

    // If Firebase already has a signed-in user, load their Firestore data.
    final existingUser = authService.currentUser;
    if (existingUser != null && firestoreService != null) {
      user = existingUser;
      isAuthenticated = true;
      await _loadFirestoreData(existingUser.uid);
    }
  }

  Future<void> _loadFirestoreData(String uid) async {
    if (firestoreService == null) return;
    isDataLoading = true;
    notifyListeners();
    try {
      final data = await firestoreService!.loadUserData(uid);

      // Hydrate bag
      bag
        ..clear()
        ..addAll(data.bag);

      // Hydrate wishlist (only valid product IDs)
      wishlist
        ..clear()
        ..addAll(
          data.wishlist.where(
            (id) => products.any((p) => p.id == id),
          ),
        );

      // Hydrate orders
      orders
        ..clear()
        ..addAll(data.orders);

      // Hydrate addresses (merge with any defaults; Firestore wins if non-empty)
      if (data.addresses.isNotEmpty) {
        addresses
          ..clear()
          ..addAll(data.addresses);
      }

      // Hydrate cards (merge similarly)
      if (data.cards.isNotEmpty) {
        cards
          ..clear()
          ..addAll(data.cards);
      }

      notifications = data.notifications;

      // Hydrate locale from Firestore if not already set from SharedPreferences
      if (data.locale != null && _locale == null) {
        final code = data.locale!;
        if (['en', 'km', 'zh'].contains(code)) {
          _locale = Locale(code);
        }
      }

      // Hydrate profile fields from Firestore when present
      if (user != null) {
        user = UserProfile(
          uid: user!.uid,
          name: data.displayName ?? user!.name,
          email: user!.email,
          createdAt: user!.createdAt,
          photoUrl: data.photoUrl ?? user!.photoUrl,
        );
      }
    } catch (e) {
      debugPrint('Failed to load Firestore data: $e');
    } finally {
      isDataLoading = false;
      notifyListeners();
    }
  }

  // ── locale ─────────────────────────────────────────────────────────────────

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code');
    if (code != null && ['en', 'km', 'zh'].contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'km', 'zh'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    // Also persist to Firestore
    if (user != null && firestoreService != null) {
      firestoreService!.saveUserProfile(user!.uid, locale: locale.languageCode);
    }
  }

  // ── products ──────────────────────────────────────────────────────────────

  final List<Product> products = sampleProducts;

  // ── mutable user data ─────────────────────────────────────────────────────

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
      themeColor: Color(0xFF0071E3),
    ),
    const PaymentCard(
      id: 'card-2',
      cardholderName: 'Kry Saravuth',
      cardNumber: '•••• •••• •••• 8888',
      expiryDate: '09/29',
      cvv: '999',
      brand: 'Apple Card',
      themeColor: Color(0xFF1F1F1F),
    ),
  ];

  String? appliedPromoCode;

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

  // ── auth actions ──────────────────────────────────────────────────────────

  Future<bool> signIn({required String email, required String password}) async {
    return _runAuthAction(() async {
      final result = await authService.signIn(email: email, password: password);
      user = result.user;
      isAuthenticated = true;
      await _loadFirestoreData(result.user.uid);
    });
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthAction(() async {
      final result = await authService.signInWithGoogle();
      user = result.user;
      isAuthenticated = true;
      // Ensure profile doc exists for Google sign-ins
      if (firestoreService != null) {
        await firestoreService!.createUserProfile(
          result.user.uid,
          name: result.user.name,
          email: result.user.email,
        );
      }
      await _loadFirestoreData(result.user.uid);
      _ensureWelcomeNotification();
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
      // Create Firestore profile document for new user
      if (firestoreService != null) {
        await firestoreService!.createUserProfile(
          result.user.uid,
          name: result.user.name,
          email: result.user.email,
        );
      }
      await _loadFirestoreData(result.user.uid);
      _ensureWelcomeNotification();
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

  bool get canEditEmail => authService is LocalAuthService;

  bool get canChangeProfilePhoto => profileStorage != null && user != null;

  Future<bool> updateUserProfile({
    required String name,
    String? email,
    Uint8List? photoBytes,
  }) async {
    if (user == null) return false;

    isProfileUpdating = true;
    authError = null;
    notifyListeners();

    try {
      final cleanName = name.trim().isEmpty ? 'AppleTech Customer' : name.trim();
      final cleanEmail = canEditEmail && email != null && email.trim().isNotEmpty
          ? email.trim()
          : user!.email;

      var photoUrl = user!.photoUrl;
      if (photoBytes != null && profileStorage != null) {
        photoUrl = await profileStorage!.uploadProfilePhoto(
          uid: user!.uid,
          bytes: photoBytes,
        );
      }

      // Firebase Auth photoURL only accepts http(s) URLs, not inline data URLs.
      if (photoUrl != null && photoUrl.startsWith('http')) {
        await authService.updateAuthProfile(
          displayName: cleanName,
          photoUrl: photoUrl,
        );
      } else {
        await authService.updateAuthProfile(displayName: cleanName);
      }

      user = UserProfile(
        uid: user!.uid,
        name: cleanName,
        email: cleanEmail,
        createdAt: user!.createdAt,
        photoUrl: photoUrl,
      );

      if (firestoreService != null) {
        await firestoreService!.saveUserProfile(
          user!.uid,
          name: cleanName,
          photoUrl: photoUrl,
        );
      }

      notifyListeners();
      return true;
    } on AuthException catch (error) {
      authError = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      debugPrint('Profile update failed: $error');
      authError = 'Could not update profile. Please try again.';
      notifyListeners();
      return false;
    } finally {
      isProfileUpdating = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authService.signOut();
    isAuthenticated = false;
    user = null;
    // Clear all in-memory user data
    bag.clear();
    wishlist.clear();
    orders.clear();
    addresses
      ..clear()
      ..add(const ShippingAddress(
        id: 'addr-1',
        fullName: 'Kry Saravuth',
        street: '123 AppleTech Way, Apt 4B',
        city: 'Cupertino, CA',
        postalCode: '95014',
        phone: '+1 (555) 019-2834',
        isDefault: true,
      ));
    cards
      ..clear()
      ..addAll([
        const PaymentCard(
          id: 'card-1',
          cardholderName: 'Kry Saravuth',
          cardNumber: '•••• •••• •••• 4242',
          expiryDate: '12/28',
          cvv: '123',
          brand: 'Visa Signature',
          themeColor: Color(0xFF0071E3),
        ),
        const PaymentCard(
          id: 'card-2',
          cardholderName: 'Kry Saravuth',
          cardNumber: '•••• •••• •••• 8888',
          expiryDate: '09/29',
          cvv: '999',
          brand: 'Apple Card',
          themeColor: Color(0xFF1F1F1F),
        ),
      ]);
    notifications = _initialNotifications();
    appliedPromoCode = null;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // ── notifications ─────────────────────────────────────────────────────────

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  void markNotificationRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;
    notifications[index] = notifications[index].copyWith(isRead: true);
    if (user != null && firestoreService != null) {
      firestoreService!.markNotificationRead(user!.uid, id);
    }
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
    if (changed) {
      if (user != null && firestoreService != null) {
        firestoreService!.markAllNotificationsRead(user!.uid);
      }
      notifyListeners();
    }
  }

  void removeNotification(String id) {
    final before = notifications.length;
    notifications.removeWhere((n) => n.id == id);
    if (notifications.length < before) {
      if (user != null && firestoreService != null) {
        firestoreService!.removeNotification(user!.uid, id);
      }
      notifyListeners();
    }
  }

  void pushNotification(AppNotification notification) {
    notifications.removeWhere((n) => n.id == notification.id);
    notifications.insert(0, notification);
    if (user != null && firestoreService != null) {
      firestoreService!.saveNotification(user!.uid, notification);
    }
    notifyListeners();
  }

  void _ensureWelcomeNotification() {
    if (user == null) return;
    final welcomeId = 'notif-welcome-${user!.uid}';
    if (notifications.any((n) => n.id == welcomeId)) return;
    pushNotification(
      AppNotification(
        id: welcomeId,
        title: 'Welcome to AppleTech',
        body: 'Your account is ready. Orders and offers will appear here.',
        createdAt: DateTime.now(),
        kind: NotificationKind.system,
      ),
    );
  }

  // ── products ──────────────────────────────────────────────────────────────

  Product productById(String id) => products.firstWhere((p) => p.id == id);

  Variant variantById(String productId, String variantId) {
    return productById(productId).variants.firstWhere((v) => v.id == variantId);
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

  // ── wishlist ──────────────────────────────────────────────────────────────

  void toggleWishlist(String productId) {
    bool isAdding = false;
    if (wishlist.contains(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
      isAdding = true;
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => products.first,
      );
      pushNotification(
        AppNotification(
          id: 'notif-wishlist-$productId-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Interest Saved',
          body: '${product.name} is now in your favorites.',
          createdAt: DateTime.now(),
          kind: NotificationKind.product,
        ),
      );
    }
    
    print('Wishlist updated: ${wishlist.length} items. Added: $isAdding'); // DEBUG
    notifyListeners();

    // Background sync
    if (user != null && firestoreService != null) {
      if (isAdding) {
        firestoreService!.addWishlistItem(user!.uid, productId);
      } else {
        firestoreService!.removeWishlistItem(user!.uid, productId);
      }
    }
  }

  // ── bag ───────────────────────────────────────────────────────────────────

  void addToBag(Product product, Variant variant) {
    final index = bag.indexWhere(
      (item) => item.productId == product.id && item.variantId == variant.id,
    );
    if (index == -1) {
      final item = CartItem(productId: product.id, variantId: variant.id);
      bag.add(item);
      if (user != null && firestoreService != null) {
        firestoreService!.saveCartItem(user!.uid, item);
      }
    } else if (bag[index].quantity < variant.stock) {
      bag[index] = bag[index].copyWith(quantity: bag[index].quantity + 1);
      if (user != null && firestoreService != null) {
        firestoreService!.saveCartItem(user!.uid, bag[index]);
      }
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      bag.remove(item);
      if (user != null && firestoreService != null) {
        firestoreService!.removeCartItem(user!.uid, item);
      }
    } else {
      final variant = variantById(item.productId, item.variantId);
      final index = bag.indexOf(item);
      bag[index] = item.copyWith(quantity: math.min(quantity, variant.stock));
      if (user != null && firestoreService != null) {
        firestoreService!.saveCartItem(user!.uid, bag[index]);
      }
    }
    notifyListeners();
  }

  void removeFromBag(CartItem item) {
    bag.remove(item);
    if (user != null && firestoreService != null) {
      firestoreService!.removeCartItem(user!.uid, item);
    }
    notifyListeners();
  }

  void clearBag() {
    bag.clear();
    if (user != null && firestoreService != null) {
      firestoreService!.clearCart(user!.uid);
    }
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

  // ── checkout ──────────────────────────────────────────────────────────────

  void completeCheckout({
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    DateTime? visitTime,
  }) {
    if (bag.isEmpty) return;
    
    // If there's an existing scheduled visit, we update it instead of creating a new one
    final existingIndex = orders.indexWhere((o) => o.status == 'Visit Scheduled');
    if (existingIndex != -1) {
      updateVisit(
        orderId: orders[existingIndex].id,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        visitTime: visitTime,
      );
      return;
    }

    final orderId = 'AT-${1000 + orders.length}';
    final order = OrderRecord(
      id: orderId,
      placedAt: DateTime.now(),
      total: total,
      items: List<CartItem>.from(bag),
      status: 'Visit Scheduled',
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      visitTime: visitTime,
    );
    orders.insert(0, order);

    // Persist order to Firestore
    try {
      if (user != null && firestoreService != null) {
        firestoreService!.saveOrder(user!.uid, order);
      }
    } catch (e) {
      debugPrint('Firestore order sync failed: $e');
    }

    final notification = AppNotification(
      id: 'notif-order-$orderId',
      title: 'Visit scheduled',
      body: 'Your visit reservation $orderId has been confirmed.',
      createdAt: DateTime.now(),
      kind: NotificationKind.order,
    );
    pushNotification(notification);

    appliedPromoCode = null;
    notifyListeners();
  }

  void updateVisit({
    required String orderId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    DateTime? visitTime,
  }) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final updatedOrder = OrderRecord(
      id: orderId,
      placedAt: orders[index].placedAt,
      total: total, // Recalculate based on current bag
      items: List<CartItem>.from(bag),
      status: 'Visit Scheduled',
      customerName: customerName ?? orders[index].customerName,
      customerPhone: customerPhone ?? orders[index].customerPhone,
      customerAddress: customerAddress ?? orders[index].customerAddress,
      visitTime: visitTime ?? orders[index].visitTime,
    );

    orders[index] = updatedOrder;

    try {
      if (user != null && firestoreService != null) {
        firestoreService!.saveOrder(user!.uid, updatedOrder);
      }
    } catch (e) {
      debugPrint('Firestore order update failed: $e');
    }

    notifyListeners();
  }

  void cancelVisit(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final cancelledOrder = OrderRecord(
      id: orderId,
      placedAt: orders[index].placedAt,
      total: orders[index].total,
      items: orders[index].items,
      status: 'Cancelled',
      customerName: orders[index].customerName,
      customerPhone: orders[index].customerPhone,
      customerAddress: orders[index].customerAddress,
      visitTime: orders[index].visitTime,
    );

    orders[index] = cancelledOrder;

    try {
      if (user != null && firestoreService != null) {
        firestoreService!.saveOrder(user!.uid, cancelledOrder);
      }
    } catch (e) {
      debugPrint('Firestore order cancel failed: $e');
    }

    notifyListeners();
  }

  // ── promo codes ───────────────────────────────────────────────────────────

  bool applyPromoCode(String code) {
    final cleaned = code.trim().toUpperCase();
    if (cleaned == 'APPLE10' || cleaned == 'WELCOME') {
      appliedPromoCode = cleaned;
      pushNotification(
        AppNotification(
          id: 'notif-promo-$cleaned-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Promo code applied',
          body: cleaned == 'APPLE10'
              ? 'APPLE10 is active — 10% off at checkout.'
              : 'WELCOME is active — \$20 off your order.',
          createdAt: DateTime.now(),
          kind: NotificationKind.promo,
        ),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearPromoCode() {
    appliedPromoCode = null;
    notifyListeners();
  }

  // ── addresses ─────────────────────────────────────────────────────────────

  void addAddress(ShippingAddress address) {
    addresses.add(address);
    if (user != null && firestoreService != null) {
      firestoreService!.saveAddress(user!.uid, address);
    }
    notifyListeners();
  }

  void removeAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    if (user != null && firestoreService != null) {
      firestoreService!.removeAddress(user!.uid, id);
    }
    notifyListeners();
  }

  // ── cards ─────────────────────────────────────────────────────────────────

  void addCard(PaymentCard card) {
    cards.add(card);
    if (user != null && firestoreService != null) {
      firestoreService!.saveCard(user!.uid, card);
    }
    notifyListeners();
  }

  void removeCard(String id) {
    cards.removeWhere((c) => c.id == id);
    if (user != null && firestoreService != null) {
      firestoreService!.removeCard(user!.uid, id);
    }
    notifyListeners();
  }
}
