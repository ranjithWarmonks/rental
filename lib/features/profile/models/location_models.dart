class CreateLocationRequest {
  final String name;
  final String code;
  final String? address;
  final bool isActive;
  final bool isDefault;

  CreateLocationRequest({
    required this.name,
    required this.code,
    this.address,
    this.isActive = true,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'address': address,
        'is_active': isActive,
        'is_default': isDefault,
      };
}
