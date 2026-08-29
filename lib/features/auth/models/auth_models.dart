import 'dart:convert';

class LoginRequest {
  final String phone;
  final String email;
  final String password;
  final String deviceName;

  LoginRequest({
    required this.phone,
    String? email,
    required this.password,
    this.deviceName = 'Flutter Mobile',
  }) : email = email ?? (phone.contains('@') ? phone : '$phone@renwala.com');

  Map<String, dynamic> toJson() => {
        'phone': phone,

        'password': password,

      };
}

class RegisterCompanyRequest {
  final String companyName;
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String deviceName;
  final String? phone;

  RegisterCompanyRequest({
    required this.companyName,
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.deviceName = 'Flutter Mobile',
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'company_name': companyName,
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': deviceName,
        'phone': phone,
      };
}

class AuthResponse {
  final bool? status;
  final String? message;
  final String token;
  final AuthUserModel user;
  final TenantModel tenant;
  final StoreLocationModel? location;

  AuthResponse({
    this.status,
    this.message,
    required this.token,
    required this.user,
    required this.tenant,
    this.location,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] is Map ? json['data'] : json;
    final tokenVal = json['token'] ?? json['access_token'] ?? rawData['token'] ?? rawData['access_token'] ?? '';
    final userMap = json['user'] ?? rawData['user'] ?? rawData;
    final tenantMap = json['tenant'] ?? rawData['tenant'] ?? {};
    final locMap = json['location'] ?? rawData['location'];

    return AuthResponse(
      status: json['status'],
      message: json['message'],
      token: tokenVal.toString(),
      user: AuthUserModel.fromJson(userMap is Map ? Map<String, dynamic>.from(userMap) : {}),
      tenant: TenantModel.fromJson(tenantMap is Map ? Map<String, dynamic>.from(tenantMap) : {}),
      location: locMap is Map ? StoreLocationModel.fromJson(Map<String, dynamic>.from(locMap)) : null,
    );
  }
}

class AuthUserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int tenantId;
  final int? apiSelectedLocationId;
  final String roleName;
  final String permissions;
  final List<String> permissionsList;

  AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.tenantId,
    this.apiSelectedLocationId,
    this.roleName = '',
    this.permissions = '',
    this.permissionsList = const [],
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final rawPerms = json['permissions'];
    List<String> perms = [];
    String permsStr = '';

    if (rawPerms is List) {
      perms = rawPerms.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      permsStr = perms.join(',');
    } else if (rawPerms is String && rawPerms.trim().isNotEmpty) {
      permsStr = rawPerms.trim();
      if (permsStr.startsWith('[') && permsStr.endsWith(']')) {
        try {
          final decoded = jsonDecode(permsStr);
          if (decoded is List) {
            perms = decoded.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          }
        } catch (_) {
          perms = permsStr.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
      } else {
        perms = permsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }

    final roleVal = json['role_name'] ?? json['role'] ?? json['role_id'];
    String roleStr = '';
    if (roleVal is Map) {
      roleStr = roleVal['name']?.toString() ?? '';
    } else if (roleVal != null) {
      roleStr = roleVal.toString();
    }

    return AuthUserModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0),
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      tenantId: json['tenant_id'] is int ? json['tenant_id'] : (int.tryParse(json['tenant_id'].toString()) ?? 0),
      apiSelectedLocationId: json['api_selected_location_id'] != null ? int.tryParse(json['api_selected_location_id'].toString()) : null,
      roleName: roleStr,
      permissions: permsStr,
      permissionsList: perms,
    );
  }

  /// Check if user has specific permission. Always returns true if role is Admin/admin.
  bool hasPermission(String requiredPermission) {
    final normalizedRole = roleName.trim().toLowerCase();
    if (normalizedRole == 'admin' || normalizedRole == 'administrator' || permissionsList.contains('*')) {
      return true;
    }
    return permissionsList.contains(requiredPermission.trim());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'tenant_id': tenantId,
        'api_selected_location_id': apiSelectedLocationId,
        'role_name': roleName,
        'permissions': permissions,
      };
}

class TenantModel {
  final int id;
  final String name;

  TenantModel({required this.id, required this.name});

  factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class StoreLocationModel {
  final int id;
  final String name;
  final String? code;
  final String? address;
  final bool isDefault;
  final bool isActive;

  StoreLocationModel({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.isDefault = false,
    this.isActive = true,
  });

  factory StoreLocationModel.fromJson(Map<String, dynamic> json) =>
      StoreLocationModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        code: json['code'],
        address: json['address'],
        isDefault: json['is_default'] ?? false,
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'address': address,
        'is_default': isDefault,
        'is_active': isActive,
      };
}
