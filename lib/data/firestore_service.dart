part of '../main.dart';

// ---------------------------------------------------------------------------
// UserDataRepository — persisted user data (bag, wishlist, orders, etc.)
// ---------------------------------------------------------------------------

abstract class UserDataRepository {
  Future<UserFirestoreData> loadUserData(String uid);

  Future<void> createUserProfile(
    String uid, {
    required String name,
    required String email,
  });

  Future<void> saveUserProfile(
    String uid, {
    String? name,
    String? locale,
    String? photoUrl,
  });

  Future<void> saveCartItem(String uid, CartItem item);

  Future<void> removeCartItem(String uid, CartItem item);

  Future<void> clearCart(String uid);

  Future<void> addWishlistItem(String uid, String productId);

  Future<void> removeWishlistItem(String uid, String productId);

  Future<void> saveOrder(String uid, OrderRecord order);

  Future<void> saveAddress(String uid, ShippingAddress address);

  Future<void> removeAddress(String uid, String addressId);

  Future<void> saveAllAddresses(String uid, List<ShippingAddress> addresses);

  Future<void> saveCard(String uid, PaymentCard card);

  Future<void> removeCard(String uid, String cardId);

  Future<void> saveNotification(String uid, AppNotification notif);

  Future<void> markNotificationRead(String uid, String notifId);

  Future<void> markAllNotificationsRead(String uid);

  Future<void> removeNotification(String uid, String notifId);
}

// ---------------------------------------------------------------------------
// DirectFirestoreService — Direct connection to Cloud Firestore
// ---------------------------------------------------------------------------

class DirectFirestoreService implements UserDataRepository {
  DirectFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<UserFirestoreData> loadUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data() ?? {};

    final bagSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bag')
        .get();
    final wishlistSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .get();
    final ordersSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .get();
    final notificationsSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .get();
    final addressesSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .get();
    final cardsSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('cards')
        .get();

    return UserFirestoreData(
      bag: bagSnap.docs
          .map((d) => FirestoreService._cartItemFromJson(d.data()))
          .toList(),
      wishlist: wishlistSnap.docs.map((d) => d.id).toSet(),
      orders: ordersSnap.docs
          .map((d) => FirestoreService._orderFromJson(d.data()))
          .toList(),
      addresses: addressesSnap.docs
          .map((d) => FirestoreService._addressFromJson(d.data()))
          .toList(),
      cards: cardsSnap.docs
          .map((d) => FirestoreService._cardFromJson(d.data()))
          .toList(),
      notifications: notificationsSnap.docs
          .map((d) => FirestoreService._notificationFromJson(d.data()))
          .toList(),
      locale: data['locale'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      isAdmin: data['role'] == 'admin',
    );
  }

  @override
  Future<void> createUserProfile(
    String uid, {
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'displayName': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> saveUserProfile(
    String uid, {
    String? name,
    String? locale,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['displayName'] = name;
    if (locale != null) data['locale'] = locale;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<void> saveCartItem(String uid, CartItem item) async {
    final id = '${item.productId}__${item.variantId}';
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bag')
        .doc(id)
        .set({
          'productId': item.productId,
          'variantId': item.variantId,
          'quantity': item.quantity,
        });
  }

  @override
  Future<void> removeCartItem(String uid, CartItem item) async {
    final id = '${item.productId}__${item.variantId}';
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('bag')
        .doc(id)
        .delete();
  }

  @override
  Future<void> clearCart(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('bag')
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> addWishlistItem(String uid, String productId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .set({'productId': productId});
  }

  @override
  Future<void> removeWishlistItem(String uid, String productId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  @override
  Future<void> saveOrder(String uid, OrderRecord order) async {
    final data = <String, dynamic>{
      'id': order.id,
      'total': order.total,
      'status': order.status,
      'placedAt': Timestamp.fromDate(order.placedAt),
      'items': order.items
          .map(
            (i) => {
              'productId': i.productId,
              'variantId': i.variantId,
              'quantity': i.quantity,
            },
          )
          .toList(),
    };
    if (order.customerName != null) data['customerName'] = order.customerName;
    if (order.customerPhone != null) {
      data['customerPhone'] = order.customerPhone;
    }
    if (order.customerAddress != null) {
      data['customerAddress'] = order.customerAddress;
    }
    if (order.visitTime != null) {
      data['visitTime'] = Timestamp.fromDate(order.visitTime!);
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(order.id)
        .set(data);
  }

  @override
  Future<void> saveAddress(String uid, ShippingAddress address) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(address.id)
        .set({
          'id': address.id,
          'fullName': address.fullName,
          'street': address.street,
          'city': address.city,
          'postalCode': address.postalCode,
          'phone': address.phone,
          'isDefault': address.isDefault,
        });
  }

  @override
  Future<void> removeAddress(String uid, String addressId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  @override
  Future<void> saveAllAddresses(
    String uid,
    List<ShippingAddress> addresses,
  ) async {
    await Future.wait(addresses.map((address) => saveAddress(uid, address)));
  }

  @override
  Future<void> saveCard(String uid, PaymentCard card) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cards')
        .doc(card.id)
        .set({
          'id': card.id,
          'cardholderName': card.cardholderName,
          'cardNumber': card.cardNumber,
          'expiryDate': card.expiryDate,
          'brand': card.brand,
          'themeColor': card.themeColor.toARGB32(),
        });
  }

  @override
  Future<void> removeCard(String uid, String cardId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cards')
        .doc(cardId)
        .delete();
  }

  @override
  Future<void> saveNotification(String uid, AppNotification notif) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notif.id)
        .set({
          'id': notif.id,
          'title': notif.title,
          'body': notif.body,
          'kind': notif.kind.name,
          'isRead': notif.isRead,
          'createdAt': Timestamp.fromDate(notif.createdAt),
        });
  }

  @override
  Future<void> markNotificationRead(String uid, String notifId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .update({'isRead': true});
  }

  @override
  Future<void> markAllNotificationsRead(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> removeNotification(String uid, String notifId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .delete();
  }
}

// ---------------------------------------------------------------------------
// FirestoreService — Express backend + Firestore Admin SDK
// ---------------------------------------------------------------------------

class FirestoreService implements UserDataRepository {
  FirestoreService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    http.Client? client,
    String? baseUrl,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _client = client ?? http.Client(),
       _baseUrl = _normalizeBaseUrl(baseUrl ?? _defaultBaseUrl);

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final http.Client _client;
  final String _baseUrl;

  // ── load all user data ───────────────────────────────────────────────────

  Future<UserFirestoreData> loadUserData(String uid) async {
    final responses = await Future.wait<Map<String, dynamic>>([
      _get('/users/me'),
      _get('/users/me/bag'),
      _get('/users/me/wishlist'),
      _get('/users/me/orders'),
      _get('/users/me/addresses'),
      _get('/users/me/cards'),
      _get('/users/me/notifications'),
    ]);

    final profile = responses[0];
    return UserFirestoreData(
      bag: ((responses[1]['items'] as List<dynamic>?) ?? [])
          .map(_cartItemFromJson)
          .toList(),
      wishlist: Set<String>.from(
        (responses[2]['productIds'] as List<dynamic>? ?? const <dynamic>[]).map(
          (id) => id.toString(),
        ),
      ),
      orders: ((responses[3]['orders'] as List<dynamic>?) ?? [])
          .map(_orderFromJson)
          .toList(),
      addresses: ((responses[4]['addresses'] as List<dynamic>?) ?? [])
          .map(_addressFromJson)
          .toList(),
      cards: ((responses[5]['cards'] as List<dynamic>?) ?? [])
          .map(_cardFromJson)
          .toList(),
      notifications: ((responses[6]['notifications'] as List<dynamic>?) ?? [])
          .map(_notificationFromJson)
          .toList(),
      locale: profile['locale'] as String?,
      displayName: profile['displayName'] as String?,
      photoUrl: profile['photoUrl'] as String?,
      isAdmin: profile['role'] == 'admin',
    );
  }

  // ── profile ──────────────────────────────────────────────────────────────

  Future<void> createUserProfile(
    String uid, {
    required String name,
    required String email,
  }) async {
    await saveUserProfile(uid, name: name);
  }

  Future<void> saveUserProfile(
    String uid, {
    String? name,
    String? locale,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['displayName'] = name;
    if (locale != null) data['locale'] = locale;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isEmpty) return;
    await _patch('/users/me', data);
  }

  // ── bag ──────────────────────────────────────────────────────────────────

  Future<void> saveCartItem(String uid, CartItem item) async {
    await _put('/users/me/bag/${_cartItemId(item)}', {
      'productId': item.productId,
      'variantId': item.variantId,
      'quantity': item.quantity,
    });
  }

  Future<void> removeCartItem(String uid, CartItem item) async {
    await _delete('/users/me/bag/${_cartItemId(item)}');
  }

  Future<void> clearCart(String uid) async {
    await _delete('/users/me/bag');
  }

  // ── wishlist ─────────────────────────────────────────────────────────────

  Future<void> addWishlistItem(String uid, String productId) async {
    await _post('/users/me/wishlist', {'productId': productId});
  }

  Future<void> removeWishlistItem(String uid, String productId) async {
    await _delete('/users/me/wishlist/${Uri.encodeComponent(productId)}');
  }

  // ── orders ───────────────────────────────────────────────────────────────

  Future<void> saveOrder(String uid, OrderRecord order) async {
    final data = <String, dynamic>{
      'id': order.id,
      'total': order.total,
      'status': order.status,
      'items': order.items.map(_cartItemToJson).toList(),
    };
    if (order.customerName != null) data['customerName'] = order.customerName;
    if (order.customerPhone != null) {
      data['customerPhone'] = order.customerPhone;
    }
    if (order.customerAddress != null) {
      data['customerAddress'] = order.customerAddress;
    }
    if (order.visitTime != null) {
      data['visitTime'] = order.visitTime!.toIso8601String();
    }
    await _post('/users/me/orders', data);
  }

  // ── addresses ────────────────────────────────────────────────────────────

  Future<void> saveAddress(String uid, ShippingAddress address) async {
    await _put('/users/me/addresses/${Uri.encodeComponent(address.id)}', {
      'fullName': address.fullName,
      'street': address.street,
      'city': address.city,
      'postalCode': address.postalCode,
      'phone': address.phone,
      'isDefault': address.isDefault,
    });
  }

  Future<void> removeAddress(String uid, String addressId) async {
    await _delete('/users/me/addresses/${Uri.encodeComponent(addressId)}');
  }

  Future<void> saveAllAddresses(
    String uid,
    List<ShippingAddress> addresses,
  ) async {
    await Future.wait(addresses.map((address) => saveAddress(uid, address)));
  }

  // ── payment cards ─────────────────────────────────────────────────────────

  Future<void> saveCard(String uid, PaymentCard card) async {
    await _put('/users/me/cards/${Uri.encodeComponent(card.id)}', {
      'cardholderName': card.cardholderName,
      'cardNumber': card.cardNumber,
      'expiryDate': card.expiryDate,
      'brand': card.brand,
      'themeColor': card.themeColor.toARGB32(),
    });
  }

  Future<void> removeCard(String uid, String cardId) async {
    await _delete('/users/me/cards/${Uri.encodeComponent(cardId)}');
  }

  // ── notifications ─────────────────────────────────────────────────────────

  Future<void> saveNotification(String uid, AppNotification notif) async {
    await _post('/users/me/notifications', {
      'id': notif.id,
      'title': notif.title,
      'body': notif.body,
      'kind': notif.kind.name,
      'isRead': notif.isRead,
    });
  }

  Future<void> markNotificationRead(String uid, String notifId) async {
    await _patch('/users/me/notifications/${Uri.encodeComponent(notifId)}', {
      'isRead': true,
    });
  }

  Future<void> markAllNotificationsRead(String uid) async {
    await _post(
      '/users/me/notifications/mark-all-read',
      const <String, dynamic>{},
    );
  }

  Future<void> removeNotification(String uid, String notifId) async {
    await _delete('/users/me/notifications/${Uri.encodeComponent(notifId)}');
  }

  // ── HTTP helpers ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _get(String path) => _request('GET', path);

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) {
    return _request('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> _patch(String path, Map<String, dynamic> body) {
    return _request('PATCH', path, body: body);
  }

  Future<Map<String, dynamic>> _delete(String path) => _request('DELETE', path);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _firebaseAuth.currentUser?.getIdToken();
    if (token == null) {
      throw const AuthException('Please sign in again.');
    }

    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return const <String, dynamic>{};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw BackendException(_errorMessage(response), response.statusCode);
  }

  static String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded['error']?.toString() ?? 'Backend request failed.';
    } catch (_) {
      return 'Backend request failed with status ${response.statusCode}.';
    }
  }

  // ── mapping helpers ───────────────────────────────────────────────────────

  static String _cartItemId(CartItem item) {
    return '${Uri.encodeComponent(item.productId)}__${Uri.encodeComponent(item.variantId)}';
  }

  static Map<String, dynamic> _cartItemToJson(CartItem item) {
    return {
      'productId': item.productId,
      'variantId': item.variantId,
      'quantity': item.quantity,
    };
  }

  static CartItem _cartItemFromJson(dynamic value) {
    final json = value as Map<String, dynamic>;
    return CartItem(
      productId: json['productId'] as String,
      variantId: json['variantId'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  static OrderRecord _orderFromJson(dynamic value) {
    final json = value as Map<String, dynamic>;
    final rawItems = (json['items'] as List<dynamic>?) ?? const <dynamic>[];
    return OrderRecord(
      id: json['id'] as String,
      placedAt: _parseDate(json['placedAt']) ?? DateTime.now(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'Preparing for delivery',
      items: rawItems.map(_cartItemFromJson).toList(),
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerAddress: json['customerAddress'] as String?,
      visitTime: _parseDate(json['visitTime']),
    );
  }

  static ShippingAddress _addressFromJson(dynamic value) {
    final json = value as Map<String, dynamic>;
    return ShippingAddress(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      phone: json['phone'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  static PaymentCard _cardFromJson(dynamic value) {
    final json = value as Map<String, dynamic>;
    final colorInt = (json['themeColor'] as num?)?.toInt() ?? 0xFF0071E3;
    return PaymentCard(
      id: json['id'] as String,
      cardholderName: json['cardholderName'] as String,
      cardNumber: json['cardNumber'] as String,
      expiryDate: json['expiryDate'] as String,
      cvv: '',
      brand: json['brand'] as String,
      themeColor: Color(colorInt),
    );
  }

  static AppNotification _notificationFromJson(dynamic value) {
    final json = value as Map<String, dynamic>;
    final kindName = json['kind'] as String? ?? 'system';
    final kind = NotificationKind.values.firstWhere(
      (value) => value.name == kindName,
      orElse: () => NotificationKind.system,
    );
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      kind: kind,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String _normalizeBaseUrl(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}

class BackendException implements Exception {
  const BackendException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

// ---------------------------------------------------------------------------
// UserFirestoreData — result of a full load
// ---------------------------------------------------------------------------

class UserFirestoreData {
  const UserFirestoreData({
    required this.bag,
    required this.wishlist,
    required this.orders,
    required this.addresses,
    required this.cards,
    required this.notifications,
    this.locale,
    this.displayName,
    this.photoUrl,
    this.isAdmin = false,
  });

  final List<CartItem> bag;
  final Set<String> wishlist;
  final List<OrderRecord> orders;
  final List<ShippingAddress> addresses;
  final List<PaymentCard> cards;
  final List<AppNotification> notifications;
  final String? locale;
  final String? displayName;
  final String? photoUrl;
  final bool isAdmin;
}
