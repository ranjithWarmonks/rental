import '../../auth/models/auth_models.dart';

class RoleModel {
  final int id;
  final String name;

  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class StaffUserModel {
  final int id;
  final String name;
  final String email;
  final int tenantId;
  final RoleModel? role;
  final int? apiSelectedLocationId;
  final StoreLocationModel? apiSelectedLocation;

  StaffUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.tenantId,
    this.role,
    this.apiSelectedLocationId,
    this.apiSelectedLocation,
  });

  factory StaffUserModel.fromJson(Map<String, dynamic> json) =>
      StaffUserModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        tenantId: json['tenant_id'] ?? 0,
        role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
        apiSelectedLocationId: json['api_selected_location_id'],
        apiSelectedLocation: json['api_selected_location'] != null
            ? StoreLocationModel.fromJson(json['api_selected_location'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'tenant_id': tenantId,
        'role': role?.toJson(),
        'api_selected_location_id': apiSelectedLocationId,
        'api_selected_location': apiSelectedLocation?.toJson(),
      };
}

class CreateStaffRequest {
  final String name;
  final String email;
  final String password;
  final int roleId;

  CreateStaffRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.roleId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'role_id': roleId,
      };
}
