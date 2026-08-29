class StockAdjustmentRow {
  int? itemId;
  String? itemName;
  String type; // 'addition', 'deduction', 'set'
  double quantity;
  String notes;

  StockAdjustmentRow({
    this.itemId,
    this.itemName,
    this.type = 'addition',
    this.quantity = 0.0,
    this.notes = '',
  });

  bool get isFilled => itemId != null && quantity > 0;

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'type': type,
        'quantity': quantity,
        'notes': notes.trim().isNotEmpty ? notes.trim() : null,
      };
}

class StockAdjustmentModel {
  final int id;
  final int itemId;
  final String itemName;
  final String sku;
  final String type; // ADDITION, DEDUCTION, SET
  final double quantity;
  final double previousStock;
  final double newStock;
  final String? notes;
  final String createdBy;
  final String createdAt;

  StockAdjustmentModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.sku,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    final itemMap = json['item'] is Map ? json['item'] : {};
    final userMap = json['user'] is Map ? json['user'] : (json['created_by_user'] is Map ? json['created_by_user'] : {});

    double parseNum(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return StockAdjustmentModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      itemId: json['item_id'] is int ? json['item_id'] : (int.tryParse(json['item_id']?.toString() ?? '0') ?? 0),
      itemName: itemMap['name'] ?? json['item_name'] ?? 'Item #${json['item_id']}',
      sku: itemMap['sku'] ?? json['sku'] ?? '',
      type: (json['type'] ?? json['adjustment_type'] ?? 'ADDITION').toString().toUpperCase(),
      quantity: parseNum(json['quantity']),
      previousStock: parseNum(json['previous_stock'] ?? json['old_stock']),
      newStock: parseNum(json['new_stock'] ?? json['current_stock']),
      notes: json['notes']?.toString() ?? json['reason']?.toString(),
      createdBy: userMap['name'] ?? json['created_by'] ?? 'Admin',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
