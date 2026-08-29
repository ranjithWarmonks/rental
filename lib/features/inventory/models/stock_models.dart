class StockEntryRow {
  final int itemId;
  final int locationId;
  final String type; // opening_stock, inward
  final int quantity;
  final String? notes;

  StockEntryRow({
    required this.itemId,
    required this.locationId,
    required this.type,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'location_id': locationId,
        'type': type,
        'quantity': quantity,
        'notes': notes,
      };
}

class BulkStockEntryRequest {
  final List<StockEntryRow> rows;

  BulkStockEntryRequest({required this.rows});

  Map<String, dynamic> toJson() => {
        'rows': rows.map((r) => r.toJson()).toList(),
      };
}

class StockAdjustmentRow {
  final int itemId;
  final int locationId;
  final String type; // addition, reduction, damage, loss
  final int quantity;
  final String? notes;

  StockAdjustmentRow({
    required this.itemId,
    required this.locationId,
    required this.type,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'location_id': locationId,
        'type': type,
        'quantity': quantity,
        'notes': notes,
      };
}

class BulkStockAdjustmentRequest {
  final List<StockAdjustmentRow> rows;

  BulkStockAdjustmentRequest({required this.rows});

  Map<String, dynamic> toJson() => {
        'rows': rows.map((r) => r.toJson()).toList(),
      };
}
