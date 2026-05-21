part of '../main.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
}

class Review {
  Review({
    required this.id,
    required this.author,
    required this.rating,
    required this.title,
    required this.content,
    required this.date,
    required this.verified,
  });

  final String id;
  final String author;
  final int rating; // 1-5
  final String title;
  final String content;
  final DateTime date;
  final bool verified;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.tagline,
    required this.description,
    required this.detailedDescription,
    required this.basePrice,
    required this.specs,
    required this.accent,
    required this.icon,
    required this.imagePath,
    required this.variants,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
    required this.warranty,
    required this.inStock,
    required this.releaseDate,
    required this.keyFeatures,
    this.featured = false,
    this.brand = 'Apple',
  });

  final String id;
  final String name;
  final String category;
  final String tagline;
  final String description;
  final String detailedDescription;
  final int basePrice;
  final List<String> specs;
  final Color accent;
  final IconData icon;
  final String imagePath;
  final List<Variant> variants;
  final double rating; // 1-5 stars
  final int reviewCount;
  final List<Review> reviews;
  final String warranty;
  final bool inStock;
  final DateTime releaseDate;
  final List<String> keyFeatures;
  final bool featured;
  final String brand;
}

class Variant {
  const Variant({
    required this.id,
    required this.colorName,
    required this.color,
    required this.storage,
    required this.price,
    required this.stock,
    this.size,
    this.ram,
    this.ssd,
  });

  final String id;
  final String colorName;
  final Color color;
  final String storage;
  final int price;
  final int stock;
  final String? size;
  final String? ram;
  final String? ssd;

  String get configurationLabel {
    final parts = <String>[];
    if (size != null && size!.isNotEmpty) parts.add(size!);
    if (ram != null && ram!.isNotEmpty) parts.add(ram!);
    if (ssd != null && ssd!.isNotEmpty) {
      parts.add(ssd!);
    } else {
      parts.add(storage);
    }
    return parts.join(' • ');
  }
}

class CartItem {
  const CartItem({
    required this.productId,
    required this.variantId,
    this.quantity = 1,
  });

  final String productId;
  final String variantId;
  final int quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      variantId: variantId,
      quantity: quantity ?? this.quantity,
    );
  }
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.placedAt,
    required this.total,
    required this.items,
    required this.status,
  });

  final String id;
  final DateTime placedAt;
  final int total;
  final List<CartItem> items;
  final String status;
}

enum NotificationKind { order, promo, product, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.kind,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationKind kind;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      kind: kind,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ShippingAddress {
  const ShippingAddress({
    required this.id,
    required this.fullName,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.phone,
    this.isDefault = false,
  });

  final String id;
  final String fullName;
  final String street;
  final String city;
  final String postalCode;
  final String phone;
  final bool isDefault;

  ShippingAddress copyWith({
    String? id,
    String? fullName,
    String? street,
    String? city,
    String? postalCode,
    String? phone,
    bool? isDefault,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.brand,
    required this.themeColor,
  });

  final String id;
  final String cardholderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String brand;
  final Color themeColor;
}

