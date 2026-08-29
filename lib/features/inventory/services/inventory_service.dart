import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import '../models/inventory_models.dart';
import '../models/item_availability_model.dart';

class InventoryService {
  final List<InventoryItemModel> _mockItems = [

  ];

  Future<List<InventoryItemModel>> getItems({String searchQuery = ''}) async {
    try {
      final url = searchQuery.isEmpty
          ? itemsApiName
          : '$itemsApiName?search=$searchQuery';

      final res = await ApiManager().getCall(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          final apiList = (data['data'] as List)
              .map((raw) => InventoryItemModel.fromJson(Map<String, dynamic>.from(raw)))
              .toList();
          if (apiList.isNotEmpty) return apiList;
        }
      }
    } catch (_) {
      // Fallback for offline / dev mode
    }

    if (searchQuery.isEmpty) return List.from(_mockItems);

    final q = searchQuery.toLowerCase();
    return _mockItems.where((item) =>
      item.name.toLowerCase().contains(q) ||
      item.sku.toLowerCase().contains(q)
    ).toList();
  }

  Future<InventoryItemModel> addItem(CreateItemRequest req) async {
    try {
      final res = await ApiManager().postCall(
        itemsApiName,
        jsonEncode(req.toJson()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final rawData = data is Map && data.containsKey('data') ? data['data'] : data;
        if (rawData is Map) {
          final created = InventoryItemModel.fromJson(Map<String, dynamic>.from(rawData));
          _mockItems.insert(0, created);
          return created;
        }
      }
    } catch (_) {
      // Fallback for offline / dev mode
    }

    final newItem = InventoryItemModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: req.name,
      sku: req.sku,
      categoryId: req.categoryId,
      unitId: req.unitId,
      replacementCost: req.replacementCost,
      damageFee: req.damageFee,
      status: req.status,
      availableFor: req.availableFor,
      pricingMode: req.pricingMode,
      pricePerDay: req.pricePerDay,
      depositAmount: req.depositAmount,
      stockAtLocation: 10,
    );
    _mockItems.insert(0, newItem);
    return newItem;
  }

  Future<InventoryItemModel> updateItem(int id, CreateItemRequest req) async {
    try {
      final res = await ApiManager().patchCall(
        itemDetailApiName(id),
        jsonEncode(req.toJson()),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawData = data is Map && data.containsKey('data') ? data['data'] : data;
        if (rawData is Map) {
          final updated = InventoryItemModel.fromJson(Map<String, dynamic>.from(rawData));
          final idx = _mockItems.indexWhere((i) => i.id == id);
          if (idx != -1) _mockItems[idx] = updated;
          return updated;
        }
      }
    } catch (_) {
      // Fallback for offline / dev mode
    }

    final idx = _mockItems.indexWhere((i) => i.id == id);
    final updated = InventoryItemModel(
      id: id,
      name: req.name,
      sku: req.sku,
      categoryId: req.categoryId,
      unitId: req.unitId,
      replacementCost: req.replacementCost,
      damageFee: req.damageFee,
      status: req.status,
      availableFor: req.availableFor,
      pricingMode: req.pricingMode,
      pricePerDay: req.pricePerDay,
      depositAmount: req.depositAmount,
      stockAtLocation: idx != -1 ? _mockItems[idx].stockAtLocation : 10,
    );

    if (idx != -1) {
      _mockItems[idx] = updated;
    }
    return updated;
  }

  Future<bool> deleteItem(int id) async {
    try {
      final res = await ApiManager.delete(itemDetailApiName(id));
      if (res != null) {
        _mockItems.removeWhere((i) => i.id == id);
        return true;
      }
    } catch (_) {
      // Fallback for offline / dev mode
    }

    _mockItems.removeWhere((i) => i.id == id);
    return true;
  }

  /// Check item availability for a date range
  Future<ItemAvailabilityResult> checkItemAvailability({
    required int itemId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];
      final url = '${itemAvailabilityApiName(itemId)}?rental_date=$startStr&expected_return_date=$endStr';

      final res = await ApiManager().getCall(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final items = await getItems();
        final matchedItem = items.firstWhere((i) => i.id == itemId, orElse: () => items.first);
        return ItemAvailabilityResult.fromJson(
          Map<String, dynamic>.from(data),
          itemName: matchedItem.name,
          pricePerDay: matchedItem.pricePerDay,
          depositAmount: matchedItem.depositAmount,
          startDate: startDate,
          endDate: endDate,
        );
      }
    } catch (_) {}

    // Fallback for offline / dev demo mode
    final items = await getItems();
    final item = items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => items.isNotEmpty
          ? items.first
          : InventoryItemModel(
              id: itemId,
              name: 'Selected Item',
              sku: 'SKU-101',
              categoryId: 1,
              unitId: 1,
              replacementCost: 1000.0,
              damageFee: 100.0,
              status: 'active',
              availableFor: 'both',
              pricingMode: 'daily',
              pricePerDay: 500.0,
              depositAmount: 500.0,
              stockAtLocation: 8,
            ),
    );

    final stockVal = item.stockAtLocation ?? 10;
    final total = stockVal > 0 ? stockVal : 10;
    final rented = (itemId % 3 == 0) ? total : (itemId % 2 == 0 ? (total ~/ 2) : 1);
    final avail = total - rented;

    return ItemAvailabilityResult(
      itemId: item.id,
      itemName: item.name,
      totalStock: total,
      rentedCount: rented > total ? total : rented,
      availableQuantity: avail < 0 ? 0 : avail,
      isAvailable: avail > 0,
      pricePerDay: item.pricePerDay > 0 ? item.pricePerDay : 350.0,
      depositAmount: item.depositAmount > 0 ? item.depositAmount : 500.0,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
