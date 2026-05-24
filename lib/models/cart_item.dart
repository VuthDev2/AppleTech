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
