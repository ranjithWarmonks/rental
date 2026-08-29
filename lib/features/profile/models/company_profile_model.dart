class CompanyProfileModel {
  final String companyName;
  final String registeredAddress;
  final String phoneNumber;
  final String contactEmail;
  final String? gstNumber;
  final String pincode;
  final String ownerName;
  final String businessType;

  CompanyProfileModel({
    required this.companyName,
    required this.registeredAddress,
    required this.phoneNumber,
    required this.contactEmail,
    this.gstNumber,
    required this.pincode,
    this.ownerName = 'Business Owner',
    this.businessType = 'Rental & Event Services',
  });

  CompanyProfileModel copyWith({
    String? companyName,
    String? registeredAddress,
    String? phoneNumber,
    String? contactEmail,
    String? gstNumber,
    String? pincode,
    String? ownerName,
    String? businessType,
  }) {
    return CompanyProfileModel(
      companyName: companyName ?? this.companyName,
      registeredAddress: registeredAddress ?? this.registeredAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactEmail: contactEmail ?? this.contactEmail,
      gstNumber: gstNumber ?? this.gstNumber,
      pincode: pincode ?? this.pincode,
      ownerName: ownerName ?? this.ownerName,
      businessType: businessType ?? this.businessType,
    );
  }

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      companyName: json['company_name']?.toString() ??
          json['companyName']?.toString() ??
          'PropManager Pro Rentals',
      registeredAddress: json['registered_address']?.toString() ??
          json['address']?.toString() ??
          '',
      phoneNumber: json['phone_number']?.toString() ??
          json['phone']?.toString() ??
          '',
      contactEmail: json['contact_email']?.toString() ??
          json['email']?.toString() ??
          '',
      gstNumber: json['gst_number']?.toString() ?? json['gstNumber']?.toString(),
      pincode: json['pincode']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? json['ownerName']?.toString() ?? 'Business Owner',
      businessType: json['business_type']?.toString() ?? json['businessType']?.toString() ?? 'Rental & Event Services',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'registered_address': registeredAddress,
      'phone_number': phoneNumber,
      'contact_email': contactEmail,
      if (gstNumber != null && gstNumber!.isNotEmpty) 'gst_number': gstNumber,
      'pincode': pincode,
      'owner_name': ownerName,
      'business_type': businessType,
    };
  }
}
