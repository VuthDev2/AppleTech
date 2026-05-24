import 'package:flutter/material.dart';
import 'variant.dart';
import 'review.dart';

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
