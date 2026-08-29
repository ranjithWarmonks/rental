import 'dart:convert';

class RoleModel {
  final int id;
  final String name;
  final String? description;
  final List<String> permissions;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    List<String> perms = [];
    final rawPerms = json['permissions'] ?? json['permissions '];
    if (rawPerms is List) {
      perms = rawPerms.map((p) => p.toString()).toList();
    } else if (rawPerms is String && rawPerms.trim().isNotEmpty) {
      final trimmed = rawPerms.trim();
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) {
            perms = decoded.map((p) => p.toString()).toList();
          }
        } catch (_) {
          perms = trimmed.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
        }
      } else {
        perms = trimmed.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      }
    }

    return RoleModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0),
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Role #${json['id']}',
      description: json['description']?.toString(),
      permissions: perms,
    );
  }
}

class StaffUserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int? roleId;
  final String roleName;
  final int? locationId;
  final String? locationName;
  final bool isActive;
  final String createdAt;

  StaffUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.roleId,
    this.roleName = 'Staff',
    this.locationId,
    this.locationName,
    this.isActive = true,
    this.createdAt = '',
  });

  factory StaffUserModel.fromJson(Map<String, dynamic> json) {
    final roleMap = json['role'] is Map ? json['role'] : {};
    final locMap = json['location'] is Map ? json['location'] : {};

    return StaffUserModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0),
      name: json['name']?.toString() ?? 'Staff Member',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      roleId: json['role_id'] != null ? int.tryParse(json['role_id'].toString()) : roleMap['id'],
      roleName: roleMap['name'] ?? json['role_name'] ?? 'Staff',
      locationId: json['location_id'] != null ? int.tryParse(json['location_id'].toString()) : locMap['id'],
      locationName: locMap['name'] ?? json['location_name'],
      isActive: json['is_active'] ?? json['active'] ?? true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
