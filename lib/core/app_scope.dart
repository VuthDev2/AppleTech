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
  bool isAuthenticated = false;
  bool isDarkMode = false;
  UserProfile? user;
  final List<Product> products = sampleProducts;
  final List<CartItem> bag = <CartItem>[];
  final Set<String> wishlist = <String>{};
  final List<OrderRecord> orders = <OrderRecord>[];

  void login(String email, String password, {String? name}) {
    isAuthenticated = true;
    user = UserProfile(
      uid: 'uid-${email.hashCode.abs()}',
      name: name?.trim().isEmpty ?? true ? 'Kry Saravuth' : name!.trim(),
      email: email,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  void logout() {
    isAuthenticated = false;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
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

  int get bagCount => bag.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal {
    return bag.fold(0, (sum, item) {
      final variant = variantById(item.productId, item.variantId);
      return sum + (variant.price * item.quantity);
    });
  }

  int get tax => (subtotal * 0.08).round();

  int get total => subtotal + tax;

  void completeCheckout() {
    if (bag.isEmpty) return;
    orders.insert(
      0,
      OrderRecord(
        id: 'AT-${1000 + orders.length}',
        placedAt: DateTime.now(),
        total: total,
        items: List<CartItem>.from(bag),
        status: 'Preparing for delivery',
      ),
    );
    bag.clear();
    notifyListeners();
  }
}
