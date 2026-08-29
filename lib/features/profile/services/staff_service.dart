import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import 'package:rental/shared/utils/form_validators.dart';
import '../models/staff_model.dart';

class StaffService {
  Future<List<RoleModel>> getRoles() async {
    final res = await ApiManager().getCall(rolesApiName);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List<dynamic> rawList = [];

      if (data is Map && data.containsKey('data')) {
        final dataVal = data['data'];
        if (dataVal is List) {
          rawList = dataVal;
        } else if (dataVal is Map && dataVal.containsKey('data') && dataVal['data'] is List) {
          rawList = dataVal['data'];
        }
      } else if (data is List) {
        rawList = data;
      }

      return rawList
          .map((raw) => RoleModel.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
    } else {
      throw Exception('Failed to load roles (${res.statusCode})');
    }
  }

  Future<RoleModel> createRole({
    required String name,
    required List<String> permissions,
    String? description,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'permissions': permissions.join(','),
    };
    if (description != null && description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }

    final res = await ApiManager().postCall(
      rolesApiName,
      jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data is Map && data.containsKey('status') && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to create role');
      }

      final roleData = data is Map && data.containsKey('data') ? data['data'] : data;
      return RoleModel.fromJson(Map<String, dynamic>.from(roleData));
    } else {
      String msg = 'Failed to create role (${res.statusCode})';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('message')) {
          msg = data['message'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<RoleModel> updateRole({
    required int id,
    required String name,
    required List<String> permissions,
    String? description,
  }) async {
    final payload = <String, dynamic>{
      'id': id,
      'name': name.trim(),
      'permissions': permissions.join(','),
    };
    if (description != null && description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }

    final res = await ApiManager().postCall(
      roleDetailApiName(id),
      jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data is Map && data.containsKey('status') && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to update role');
      }

      final roleData = data is Map && data.containsKey('data') ? data['data'] : data;
      return RoleModel.fromJson(Map<String, dynamic>.from(roleData));
    } else {
      String msg = 'Failed to update role (${res.statusCode})';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('message')) {
          msg = data['message'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<List<StaffUserModel>> getUsers({String searchQuery = ''}) async {
    final queryParams = <String>[];
    if (searchQuery.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(searchQuery.trim())}');
    }

    final url = queryParams.isEmpty
        ? usersApiName
        : '$usersApiName?${queryParams.join('&')}';

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
          .map((raw) => StaffUserModel.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
    } else {
      throw Exception('Failed to load users (${res.statusCode})');
    }
  }

  Future<StaffUserModel> createUser({
    required String name,
    required String phone,
    String? email,
    required String password,
    int? roleId,
    int? locationId,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'phone': FormValidators.formatPhoneWithCountryCode(phone),
      'password': password,
    };

    if (email != null && email.trim().isNotEmpty) {
      payload['email'] = email.trim();
    }

    if (roleId != null && roleId > 0) {
      payload['role_id'] = roleId;
    }

    if (locationId != null && locationId > 0) {
      payload['location_id'] = locationId;
    }

    final res = await ApiManager().postCall(
      usersApiName,
      jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data is Map && data.containsKey('status') && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to create user');
      }

      final userData = data is Map && data.containsKey('data') ? data['data'] : data;
      return StaffUserModel.fromJson(Map<String, dynamic>.from(userData));
    } else {
      String msg = 'Failed to create user (${res.statusCode})';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('message')) {
          msg = data['message'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<StaffUserModel> getUserDetails(int id) async {
    final res = await ApiManager().getCall(userDetailApiName(id));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final userData = data is Map && data.containsKey('data') ? data['data'] : data;
      return StaffUserModel.fromJson(Map<String, dynamic>.from(userData));
    } else {
      throw Exception('Failed to load user details (${res.statusCode})');
    }
  }

  Future<StaffUserModel> updateUser({
    required int id,
    required String name,
    required String phone,
    String? email,
    String? password,
    int? roleId,
    int? locationId,
    bool? isActive,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'phone': FormValidators.formatPhoneWithCountryCode(phone),
    };

    if (email != null && email.trim().isNotEmpty) {
      payload['email'] = email.trim();
    }

    if (password != null && password.trim().isNotEmpty) {
      payload['password'] = password;
    }

    if (roleId != null && roleId > 0) {
      payload['role_id'] = roleId;
    }

    if (locationId != null && locationId > 0) {
      payload['location_id'] = locationId;
    }

    if (isActive != null) {
      payload['is_active'] = isActive;
    }

    final res = await ApiManager().putCall(
      userDetailApiName(id),
      jsonEncode(payload),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data is Map && data.containsKey('status') && data['status'] == false) {
        throw Exception(data['message'] ?? 'Failed to update user');
      }

      final userData = data is Map && data.containsKey('data') ? data['data'] : data;
      return StaffUserModel.fromJson(Map<String, dynamic>.from(userData));
    } else {
      String msg = 'Failed to update user (${res.statusCode})';
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
