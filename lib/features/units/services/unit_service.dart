import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import '../models/unit_model.dart';

class UnitService {
  Future<List<UnitModel>> getUnits({String? searchQuery}) async {
    final queryParams = <String>[];
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(searchQuery.trim())}');
    }

    final url = queryParams.isEmpty
        ? unitsApiName
        : '$unitsApiName?${queryParams.join('&')}';

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
          .map((raw) => UnitModel.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
    } else {
      throw Exception('Failed to load units of measure (${res.statusCode})');
    }
  }

  Future<UnitModel> createUnit({
    required String name,
    required String abbreviation,
  }) async {
    final bodyMap = <String, dynamic>{
      'name': name.trim(),
      'abbreviation': abbreviation.trim(),
      'short_name': abbreviation.trim(),
      'symbol': abbreviation.trim(),
    };

    final res = await ApiManager().postCall(
      unitsApiName,
      jsonEncode(bodyMap),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final raw = data is Map && data.containsKey('data') ? data['data'] : data;
      if (raw is Map) {
        return UnitModel.fromJson(Map<String, dynamic>.from(raw));
      }
      return UnitModel(id: 0, name: name, abbreviation: abbreviation);
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to create unit (${res.statusCode})';
      throw Exception(msg);
    }
  }

  Future<UnitModel> updateUnit(
    int id, {
    required String name,
    required String abbreviation,
  }) async {
    final bodyMap = <String, dynamic>{
      'name': name.trim(),
      'abbreviation': abbreviation.trim(),
      'short_name': abbreviation.trim(),
      'symbol': abbreviation.trim(),
    };

    final res = await ApiManager().patchCall(
      unitDetailApiName(id),
      jsonEncode(bodyMap),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final raw = data is Map && data.containsKey('data') ? data['data'] : data;
      if (raw is Map) {
        return UnitModel.fromJson(Map<String, dynamic>.from(raw));
      }
      return UnitModel(id: id, name: name, abbreviation: abbreviation);
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to update unit (${res.statusCode})';
      throw Exception(msg);
    }
  }

  Future<void> deleteUnit(int id) async {
    final res = await ApiManager().deleteCall(unitDetailApiName(id));
    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    } else if (res.statusCode == 409) {
      throw Exception('Cannot delete unit: Items are currently using this unit of measure.');
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to delete unit (${res.statusCode})';
      throw Exception(msg);
    }
  }
}
