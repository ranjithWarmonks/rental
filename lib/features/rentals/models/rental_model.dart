class RentalModel {
  final int? dbId;
  final String id;
  final int? customerId;
  final String customerName;
  final String customerPhone;
  final int? locationId;
  final String? locationName;
  final String pickupDate;
  final String returnDate;
  final String duration;
  final String createdBy;
  final String status; // ACTIVE, PENDING, OVERDUE, RETURNED
  final String paymentStatus; // FULL, PARTIAL, DUE
  final double totalAmount;
  final double paidAmount;
  final double balanceDue;
  final double securityDeposit;
  final double subtotal;
  final double discount;
  final double tax;
  final List<RentedItemModel> items;
  final List<PaymentLogModel> payments;
  final String? overdueNotes;

  RentalModel({
    this.dbId,
    required this.id,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.locationId,
    this.locationName,
    required this.pickupDate,
    required this.returnDate,
    required this.duration,
    required this.createdBy,
    required this.status,
    this.paymentStatus = 'PARTIAL',
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceDue,
    required this.securityDeposit,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.items,
    required this.payments,
    this.overdueNotes,
  });

  RentalModel copyWith({
    int? dbId,
    String? id,
    int? customerId,
    String? customerName,
    String? customerPhone,
    int? locationId,
    String? locationName,
    String? pickupDate,
    String? returnDate,
    String? duration,
    String? createdBy,
    String? status,
    String? paymentStatus,
    double? totalAmount,
    double? paidAmount,
    double? balanceDue,
    double? securityDeposit,
    double? subtotal,
    double? discount,
    double? tax,
    List<RentedItemModel>? items,
    List<PaymentLogModel>? payments,
    String? overdueNotes,
  }) {
    return RentalModel(
      dbId: dbId ?? this.dbId,
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      duration: duration ?? this.duration,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      overdueNotes: overdueNotes ?? this.overdueNotes,
    );
  }
}

class RentedItemModel {
  final String id;
  final String name;
  final int quantity;
  final double ratePerDay;
  final double total;
  final String pricingMode; // 'flat' or 'day'

  RentedItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.ratePerDay,
    required this.total,
    this.pricingMode = 'day',
  });

  RentedItemModel copyWith({
    String? id,
    String? name,
    int? quantity,
    double? ratePerDay,
    double? total,
    String? pricingMode,
  }) {
    return RentedItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      ratePerDay: ratePerDay ?? this.ratePerDay,
      total: total ?? this.total,
      pricingMode: pricingMode ?? this.pricingMode,
    );
  }
}

class PaymentLogModel {
  final String id;
  final double amount;
  final String date;
  final String mode; // UPI, Cash, Bank, Card

  PaymentLogModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.mode,
  });
}
