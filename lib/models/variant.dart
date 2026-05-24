import 'package:flutter/material.dart';

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
