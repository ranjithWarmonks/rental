import 'dart:convert';
import 'package:rental/features/auth/models/auth_models.dart';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';

class LocationService {
  Future<List<StoreLocationModel>> getLocations() async {
    try {
      final res = await ApiManager().getCall(locationsApiName);
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

        final locations = rawList
            .map((raw) => StoreLocationModel.fromJson(Map<String, dynamic>.from(raw)))
            .toList();

        if (locations.isNotEmpty) {
          return locations;
        }
      }
    } catch (_) {}

    return [
      StoreLocationModel(id: 1, name: 'Main Store', code: 'MAIN01', isDefault: true, isActive: true),
    ];
  }

  Future<StoreLocationModel> createLocation({
    required String name,
    String? code,
    String? address,
    bool isActive = true,
    bool isDefault = false,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'is_active': isActive,
      'is_default': isDefault,
    };
    if (code != null && code.trim().isNotEmpty) {
      payload['code'] = code.trim();
    }
    if (address != null && address.trim().isNotEmpty) {
      payload['address'] = address.trim();
    }

    final res = await ApiManager().postCall(
      locationsApiName,
      jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data is Map && data.containsKey('status') && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to create location');
      }
      final locData = data is Map && data.containsKey('data') ? data['data'] : data;
      return StoreLocationModel.fromJson(Map<String, dynamic>.from(locData));
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to create location (${res.statusCode})';
      throw Exception(msg);
    }
  }
}
