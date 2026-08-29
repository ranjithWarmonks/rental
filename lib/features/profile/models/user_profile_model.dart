class UserProfileModel {
  final String name;
  final String phone;
  final String email;
  final String role;
  final String companyName;
  final String appVersion;
  final String buildNumber;

  UserProfileModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.companyName,
    this.appVersion = 'v1.0.0',
    this.buildNumber = '100',
  });

  UserProfileModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? role,
    String? companyName,
    String? appVersion,
    String? buildNumber,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      companyName: companyName ?? this.companyName,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name']?.toString() ?? 'User',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Business Owner',
      companyName: json['companyName']?.toString() ??
          json['company_name']?.toString() ??
          'PropManager Pro Rentals',
      appVersion: json['appVersion']?.toString() ?? 'v1.0.0',
      buildNumber: json['buildNumber']?.toString() ?? '100',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'companyName': companyName,
        'appVersion': appVersion,
        'buildNumber': buildNumber,
      };
}

