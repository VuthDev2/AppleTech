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

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.tagline,
    required this.description,
    required this.basePrice,
    required this.specs,
    required this.accent,
    required this.icon,
    required this.variants,
    this.featured = false,
  });

  final String id;
  final String name;
  final String category;
  final String tagline;
  final String description;
  final int basePrice;
  final List<String> specs;
  final Color accent;
  final IconData icon;
  final List<Variant> variants;
  final bool featured;
}

class Variant {
  const Variant({
    required this.id,
    required this.colorName,
    required this.color,
    required this.storage,
    required this.price,
    required this.stock,
  });

  final String id;
  final String colorName;
  final Color color;
  final String storage;
  final int price;
  final int stock;
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
