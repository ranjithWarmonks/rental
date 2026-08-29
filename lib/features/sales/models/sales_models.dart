class SaleOrderItemRequest {
  final int itemId;
  final double quantity;
  final double? customPrice;

  SaleOrderItemRequest({
    required this.itemId,
    required this.quantity,
    this.customPrice,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': quantity,
        'custom_price': customPrice,
      };
}

class SaleOrderRequest {
  final int customerId;
  final int locationId;
  final String saleDate;
  final double discountPercentage;
  final String paymentMode;
  final List<SaleOrderItemRequest> items;

  SaleOrderRequest({
    required this.customerId,
    required this.locationId,
    required this.saleDate,
    this.discountPercentage = 0.0,
    required this.paymentMode,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'location_id': locationId,
        'sale_date': saleDate,
        'discount_percentage': discountPercentage,
        'payment_mode': paymentMode,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class SalePaymentRequest {
  final double amount;
  final String paymentMode;
  final String paymentDate;
  final String? reference;
  final String? notes;

  SalePaymentRequest({
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    this.reference,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'payment_mode': paymentMode,
        'payment_date': paymentDate,
        'reference': reference,
        'notes': notes,
      };
}
