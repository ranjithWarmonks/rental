double _toDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

int _toInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is num) return val.toInt();
  final d = double.tryParse(val.toString());
  return d != null ? d.toInt() : 0;
}

class InventoryItemModel {
  final int id;
  final String name;
  final String sku;
  final int categoryId;
  final int unitId;
  final double replacementCost;
  final double damageFee;
  final String status;
  final String availableFor;
  final String pricingMode;
  final double pricePerDay;
  final double depositAmount;
  final double? salePrice;
  final int? stockAtLocation;
  final String? categoryName;
  final Map<String, dynamic>? customFields;
  final String? imageUrl;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.unitId,
    required this.replacementCost,
    required this.damageFee,
    required this.status,
    required this.availableFor,
    required this.pricingMode,
    required this.pricePerDay,
    required this.depositAmount,
    this.salePrice,
    this.stockAtLocation,
    this.categoryName,
    this.customFields,
    this.imageUrl,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      InventoryItemModel(
        id: _toInt(json['id']),
        name: json['name']?.toString() ?? '',
        sku: json['sku']?.toString() ?? '',
        categoryId: _toInt(json['category_id']),
        unitId: _toInt(json['unit_id']),
        replacementCost: _toDouble(json['replacement_cost']),
        damageFee: _toDouble(json['damage_fee']),
        status: json['status']?.toString() ?? 'active',
        availableFor: json['available_for']?.toString() ?? 'rental',
        pricingMode: json['pricing_mode']?.toString() ?? 'day',
        pricePerDay: _toDouble(json['price_per_day'] ?? json['rental_price_per_day']),
        depositAmount: _toDouble(json['deposit_amount']),
        salePrice: json['sale_price'] != null ? _toDouble(json['sale_price']) : null,
        stockAtLocation: json['current_stock'] != null || json['stock_at_location'] != null || json['stock'] != null
            ? _toInt(json['current_stock'] ?? json['stock_at_location'] ?? json['stock'])
            : null,
        categoryName: json['category'] is Map && json['category']['name'] != null
            ? json['category']['name'].toString()
            : json['category_name']?.toString(),
        customFields: json['custom_fields'] is Map ? Map<String, dynamic>.from(json['custom_fields']) : null,
        imageUrl: json['image_url']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'category_id': categoryId,
        'unit_id': unitId,
        'replacement_cost': replacementCost,
        'damage_fee': damageFee,
        'status': status,
        'available_for': availableFor,
        'pricing_mode': pricingMode,
        'price_per_day': pricePerDay,
        'deposit_amount': depositAmount,
        'sale_price': salePrice,
        'stock_at_location': stockAtLocation,
        'category_name': categoryName,
        'custom_fields': customFields,
        'image_url': imageUrl,
      };
}

class CreateItemRequest {
  final String name;
  final String sku;
  final int categoryId;
  final int unitId;
  final double replacementCost;
  final double damageFee;
  final String status;
  final String availableFor;
  final String pricingMode;
  final double pricePerDay;
  final double depositAmount;
  final double? salePrice;
  final Map<String, dynamic>? customFields;

  CreateItemRequest({
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.unitId,
    required this.replacementCost,
    required this.damageFee,
    this.status = 'active',
    this.availableFor = 'rental',
    this.pricingMode = 'day',
    required this.pricePerDay,
    required this.depositAmount,
    this.salePrice,
    this.customFields,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sku': sku,
        'category_id': categoryId,
        'unit_id': unitId,
        'replacement_cost': replacementCost,
        'damage_fee': damageFee,
        'status': status,
        'available_for': availableFor,
        'pricing_mode': pricingMode,
        'price_per_day': pricePerDay,
        'deposit_amount': depositAmount,
        'sale_price': salePrice,
        'custom_fields': customFields,
      };
}

class ItemAvailabilityModel {
  final int itemId;
  final int totalStock;
  final int bookedQuantity;
  final int availableStock;

  ItemAvailabilityModel({
    required this.itemId,
    required this.totalStock,
    required this.bookedQuantity,
    required this.availableStock,
  });

  factory ItemAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      ItemAvailabilityModel(
        itemId: json['item_id'] ?? 0,
        totalStock: json['total_stock'] ?? 0,
        bookedQuantity: json['booked_quantity'] ?? 0,
        availableStock: json['available_stock'] ?? 0,
      );
}

class StockHistoryModel {
  final int id;
  final int itemId;
  final int locationId;
  final String type;
  final int quantity;
  final String? notes;
  final String createdAt;

  StockHistoryModel({
    required this.id,
    required this.itemId,
    required this.locationId,
    required this.type,
    required this.quantity,
    this.notes,
    required this.createdAt,
  });

  factory StockHistoryModel.fromJson(Map<String, dynamic> json) =>
      StockHistoryModel(
        id: json['id'] ?? 0,
        itemId: json['item_id'] ?? 0,
        locationId: json['location_id'] ?? 0,
        type: json['type'] ?? '',
        quantity: json['quantity'] ?? 0,
        notes: json['notes'],
        createdAt: json['created_at'] ?? '',
      );
}
