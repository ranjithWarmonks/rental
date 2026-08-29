class RegisterCompanyModel {
  final String companyName;
  final String registeredAddress;
  final String phoneNumber;
  final String contactEmail;
  final String password;
  final String confirmPassword;
  final String? gstNumber;
  final String pincode;
  RegisterCompanyModel({
    required this.companyName,
    required this.registeredAddress,
    required this.phoneNumber,
    required this.contactEmail,
    required this.password,
    required this.confirmPassword,
    this.gstNumber,
    required this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'registered_address': registeredAddress,
      'phone_number': phoneNumber,
      'contact_email': contactEmail,
      'password': password,
      'password_confirmation': confirmPassword,
      'gst_number': gstNumber,
      'pincode': pincode,
    };
  }

  factory RegisterCompanyModel.fromJson(Map<String, dynamic> json) {
    return RegisterCompanyModel(
      companyName: json['company_name'] ?? '',
      registeredAddress: json['registered_address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      password: json['password'] ?? '',
      confirmPassword: json['password_confirmation'] ?? json['confirm_password'] ?? '',
      gstNumber: json['gst_number'],
      pincode: json['pincode'] ?? '',
    );
  }
}
