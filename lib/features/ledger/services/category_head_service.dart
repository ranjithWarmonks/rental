import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import '../models/ledger_models.dart';

class CategoryHeadService {
  final List<LedgerCategoryModel> _mockCategories = [

  ];

  Future<List<LedgerCategoryModel>> getCategories() async {
    try {
      final res = await ApiManager().getCall(ledgerCategoriesApiName);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          final apiList = (data['data'] as List)
              .map((raw) => LedgerCategoryModel.fromJson(Map<String, dynamic>.from(raw)))
              .toList();
          if (apiList.isNotEmpty) return apiList;
        } else if (data is List) {
          final apiList = data
              .map((raw) => LedgerCategoryModel.fromJson(Map<String, dynamic>.from(raw)))
              .toList();
          if (apiList.isNotEmpty) return apiList;
        }
      }
    } catch (_) {
      // Fallback for offline / dev mode
    }

    return List.from(_mockCategories);
  }

  Future<LedgerCategoryModel> addCategory(String type, String name) async {
    try {
      final body = {
        'type': type.toLowerCase(),
        'name': name,
      };

      final res = await ApiManager().postCall(
        ledgerCategoriesApiName,
        jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final rawData = data is Map && data.containsKey('data') ? data['data'] : data;
        if (rawData is Map) {
          final created = LedgerCategoryModel.fromJson(Map<String, dynamic>.from(rawData));
          _mockCategories.insert(0, created);
          return created;
        }
      }
    } catch (_) {
      // Fallback for offline / dev mode
    }

    final newCat = LedgerCategoryModel(
      id: DateTime.now().millisecondsSinceEpoch,
      type: type.toLowerCase(),
      name: name,
    );
    _mockCategories.add(newCat);
    return newCat;
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final res = await ApiManager.delete(ledgerCategoryDetailApiName(id));
      if (res != null) {
        _mockCategories.removeWhere((c) => c.id == id);
        return true;
      }
    } catch (_) {
      // Fallback for offline / dev mode
    }

    _mockCategories.removeWhere((c) => c.id == id);
    return true;
  }
}
