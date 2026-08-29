class ItemAvailabilityResult {
  final int itemId;
  final String itemName;
  final int totalStock;
  final int rentedCount;
  final int availableQuantity;
  final bool isAvailable;
  final double pricePerDay;
  final double depositAmount;
  final DateTime? startDate;
  final DateTime? endDate;

  ItemAvailabilityResult({
    required this.itemId,
    required this.itemName,
    required this.totalStock,
    required this.rentedCount,
    required this.availableQuantity,
    required this.isAvailable,
    this.pricePerDay = 0.0,
    this.depositAmount = 0.0,
    this.startDate,
    this.endDate,
  });

  factory ItemAvailabilityResult.fromJson(
    Map<String, dynamic> json, {
    String? itemName,
    double? pricePerDay,
    double? depositAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final rawData = json['data'] is Map ? json['data'] : json;
    final total = (rawData['total_stock'] ?? rawData['stock'] ?? 0) as num;
    final booked = (rawData['booked_quantity'] ?? rawData['rented_count'] ?? rawData['rented'] ?? 0) as num;
    final avail = (rawData['available_stock'] ?? rawData['available_quantity'] ?? rawData['available'] ?? (total - booked)) as num;

    return ItemAvailabilityResult(
      itemId: rawData['item_id'] ?? rawData['id'] ?? 0,
      itemName: itemName ?? rawData['item_name'] ?? rawData['name'] ?? 'Item',
      totalStock: total.toInt(),
      rentedCount: booked.toInt(),
      availableQuantity: avail.toInt(),
      isAvailable: avail > 0,
      pricePerDay: pricePerDay ?? ((rawData['price_per_day'] ?? 0) as num).toDouble(),
      depositAmount: depositAmount ?? ((rawData['deposit_amount'] ?? 0) as num).toDouble(),
      startDate: startDate,
      endDate: endDate,
    );
  }
}
