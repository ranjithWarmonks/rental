class UserProfileResponse {
  final bool status;
  final String? message;
  final UserProfileData data;

  UserProfileResponse({
    this.status = true,
    this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileResponse(
        status: json['status'] ?? true,
        message: json['message'],
        data: UserProfileData.fromJson(json['data'] ?? {}),
      );
}

class UserProfileData {
  final int id;
  final String name;
  final String email;
  final int tenantId;
  final int? apiSelectedLocationId;

  UserProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.tenantId,
    this.apiSelectedLocationId,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) =>
      UserProfileData(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        tenantId: json['tenant_id'] ?? 0,
        apiSelectedLocationId: json['api_selected_location_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'tenant_id': tenantId,
        'api_selected_location_id': apiSelectedLocationId,
      };
}

class UpdateProfileRequest {
  final String name;
  final String email;

  UpdateProfileRequest({required this.name, required this.email});

  Map<String, dynamic> toJson() => {'name': name, 'email': email};
}

class LocationContextRequest {
  final int locationId;

  LocationContextRequest({required this.locationId});

  Map<String, dynamic> toJson() => {'location_id': locationId};
}

class ChangePasswordRequest {
  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}
