import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import '../models/stock_entry_model.dart';

class StockEntryService {
  Future<List<StockEntryModel>> getStockEntries({String? searchQuery}) async {
    final queryParams = <String>[];
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(searchQuery.trim())}');
    }

    final url = queryParams.isEmpty
        ? stockEntriesApiName
        : '$stockEntriesApiName?${queryParams.join('&')}';

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
          .map((raw) => StockEntryModel.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
    } else {
      throw Exception('Failed to load stock entries (${res.statusCode})');
    }
  }

  Future<void> submitStockEntries(
    List<StockEntryRow> filledRows, {
    int locationId = 1,
  }) async {
    final defaultLocId = locationId > 0 ? locationId : 1;
    final payload = {
      'rows': filledRows.map((r) => r.toJson(defaultLocationId: defaultLocId)).toList(),
    };

    final res = await ApiManager().postCall(
      stockEntriesApiName,
      jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('status') && data['status'] == false) {
          final msg = data['message'] ?? 'Failed to submit stock entries';
          throw Exception(msg);
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('Failed to submit')) {
          rethrow;
        }
      }
      return;
    } else {
      String msg = 'Failed to submit stock entries (${res.statusCode})';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('message')) {
          msg = data['message'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
