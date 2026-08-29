class RentalOrderItemRequest {
  final int itemId;
  final double quantity;
  final String pricingMode;
  final double unitPrice;
  final double discount;
  final double total;
  final double? customPrice;

  RentalOrderItemRequest({
    required this.itemId,
    required this.quantity,
    this.pricingMode = 'flat',
    required this.unitPrice,
    this.discount = 0.0,
    required this.total,
    this.customPrice,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': quantity,
        'pricing_mode': pricingMode,
        'unit_price': unitPrice,
        'discount': discount,
        'total': total,
        'custom_price': customPrice ?? unitPrice,
      };
}

class RentalOrderPaymentRequest {
  final String type;
  final String method;
  final double amount;
  final String? notes;

  RentalOrderPaymentRequest({
    this.type = 'advance',
    required this.method,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'method': method.toLowerCase(),
        'amount': amount.toStringAsFixed(2),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

class RentalOrderRequest {
  final int customerId;
  final int locationId;
  final String rentalDate;
  final String expectedReturnDate;
  final double discountPercentage;
  final double depositReceived;
  final String paymentMode;
  final String? notes;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final List<RentalOrderItemRequest> items;
  final List<RentalOrderPaymentRequest>? payments;

  RentalOrderRequest({
    required this.customerId,
    required this.locationId,
    required this.rentalDate,
    required this.expectedReturnDate,
    this.discountPercentage = 0.0,
    this.depositReceived = 0.0,
    required this.paymentMode,
    this.notes,
    required this.totalAmount,
    this.discountAmount = 0.0,
    required this.finalAmount,
    required this.items,
    this.payments,
  });

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'location_id': locationId,
        'rental_date': rentalDate,
        'expected_return_date': expectedReturnDate,
        'discount_percentage': discountPercentage,
        'deposit_received': depositReceived,
        'payment_mode': paymentMode,
        'notes': notes,
        'total_amount': totalAmount,
        'discount_amount': discountAmount,
        'final_amount': finalAmount,
        'items': items.map((i) => i.toJson()).toList(),
        if (payments != null && payments!.isNotEmpty)
          'payments': payments!.map((p) => p.toJson()).toList(),
      };
}

class RentalOrderResponse {
  final bool status;
  final String? message;
  final RentalOrderData data;

  RentalOrderResponse({
    required this.status,
    this.message,
    required this.data,
  });

  factory RentalOrderResponse.fromJson(Map<String, dynamic> json) =>
      RentalOrderResponse(
        status: json['status'] ?? true,
        message: json['message'],
        data: RentalOrderData.fromJson(json['data'] ?? {}),
      );
}

class RentalOrderData {
  final int id;
  final String rentalNumber;
  final String status; // active, pending, returned, cancelled

  RentalOrderData({
    required this.id,
    required this.rentalNumber,
    required this.status,
  });

  factory RentalOrderData.fromJson(Map<String, dynamic> json) => RentalOrderData(
        id: json['id'] ?? 0,
        rentalNumber: json['rental_number'] ?? '',
        status: json['status'] ?? 'active',
      );
}

class ReturnItemRow {
  final int rentalItemId;
  final double returnQuantity;

  ReturnItemRow({
    required this.rentalItemId,
    required this.returnQuantity,
  });

  Map<String, dynamic> toJson() => {
        'rental_item_id': rentalItemId,
        'return_quantity': returnQuantity,
      };
}

class RentalReturnRequest {
  final String? notes;
  final List<ReturnItemRow> items;

  RentalReturnRequest({
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'notes': notes,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
