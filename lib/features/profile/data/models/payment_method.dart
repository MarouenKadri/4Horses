class PaymentMethod {
  final String id;
  final String brand;
  final String last4;
  final String expiry;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.isDefault,
  });

  PaymentMethod copyWith({bool? isDefault}) => PaymentMethod(
    id: id,
    brand: brand,
    last4: last4,
    expiry: expiry,
    isDefault: isDefault ?? this.isDefault,
  );
}
