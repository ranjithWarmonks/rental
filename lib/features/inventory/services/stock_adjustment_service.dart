import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import '../models/stock_adjustment_model.dart';

class StockAdjustmentService {
  Future<List<StockAdjustmentModel>> getStockAdjustments({String? searchQuery}) async {
    final queryParams = <String>[];
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(searchQuery.trim())}');
    }

    final url = queryParams.isEmpty
        ? stockAdjustmentsApiName
        : '$stockAdjustmentsApiName?${queryParams.join('&')}';

    final res = await ApiManager().getCall(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List<dynamic> rawList = [];

      if (data is Map && data.containsKey('data')) {
        final dataVal = data['data'];
        if (dataVal is List) {
          rawList = dataVal;
        } else if (dataVal is Map && dataVal.containsKey('data') && dataVal['data'] is List) {
          rawList = dataVal['data'];
        } else if (dataVal is Map) {
          rawList = [dataVal];
        }
      } else if (data is List) {
        rawList = data;
      }

      return rawList
          .map((raw) => StockAdjustmentModel.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
    } else {
      throw Exception('Failed to load stock adjustments (${res.statusCode})');
    }
  }

  Future<void> submitBulkAdjustments(
    List<StockAdjustmentRow> filledRows, {
    int locationId = 1,
  }) async {
    final payload = {
      'location_id': locationId > 0 ? locationId : 1,
      'adjustments': filledRows.map((r) => r.toJson()).toList(),
    };

    final res = await ApiManager().postCall(
      stockAdjustmentsApiName,
      jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return;
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to submit stock adjustments (${res.statusCode})';
      throw Exception(msg);
    }
  }
}
