import 'cart_item.dart';

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.placedAt,
    required this.total,
    required this.items,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.visitTime,
  });

  final String id;
  final DateTime placedAt;
  final int total;
  final List<CartItem> items;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final DateTime? visitTime;
}
