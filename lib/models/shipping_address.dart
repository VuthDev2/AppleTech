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
