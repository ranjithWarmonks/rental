class StockEntryRow {
  int? itemId;
  String? itemName;
  int locationId;
  String type; // 'opening_stock', 'purchase', 'inward'
  double quantity;
  String notes;

  StockEntryRow({
    this.itemId,
    this.itemName,
    this.locationId = 1,
    this.type = 'opening_stock',
    this.quantity = 0.0,
    this.notes = '',
  });

  bool get isFilled => itemId != null && quantity > 0;

  Map<String, dynamic> toJson({int defaultLocationId = 1}) {
    final map = <String, dynamic>{
      'item_id': itemId,
      'location_id': (locationId > 0) ? locationId : defaultLocationId,
      'type': type,
      'quantity': quantity == quantity.roundToDouble() ? quantity.toInt() : quantity,
    };
    if (notes.trim().isNotEmpty) {
      map['notes'] = notes.trim();
    }
    return map;
  }
}

class StockEntryModel {
  final int id;
  final int itemId;
  final String itemName;
  final String sku;
  final String type; // OPENING STOCK, PURCHASE, INWARD
  final double quantity;
  final String? notes;
  final String createdBy;
  final String createdAt;

  StockEntryModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.sku,
    required this.type,
    required this.quantity,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockEntryModel.fromJson(Map<String, dynamic> json) {
    final itemMap = json['item'] is Map ? json['item'] : {};
    final userMap = json['user'] is Map ? json['user'] : (json['created_by_user'] is Map ? json['created_by_user'] : {});

    double parseNum(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? 0);
      return 0;
    }

    return StockEntryModel(
      id: parseInt(json['id']),
      itemId: parseInt(json['item_id']),
      itemName: itemMap['name'] ?? json['item_name'] ?? 'Item #${json['item_id']}',
      sku: itemMap['sku'] ?? json['sku'] ?? '',
      type: (json['type'] ?? json['entry_type'] ?? 'OPENING STOCK').toString().replaceAll('_', ' ').toUpperCase(),
      quantity: parseNum(json['quantity']),
      notes: json['notes']?.toString() ?? json['remark']?.toString(),
      createdBy: userMap['name'] ?? json['created_by'] ?? 'Admin',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
