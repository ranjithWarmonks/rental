class CustomerApiModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? customerType;
  final double defaultDiscountPercentage;
  final String? idProofType;
  final String? idProofNumber;
  final String? notes;

  CustomerApiModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.customerType,
    this.defaultDiscountPercentage = 0.0,
    this.idProofType,
    this.idProofNumber,
    this.notes,
  });

  factory CustomerApiModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return CustomerApiModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      customerType: json['customer_type']?.toString(),
      defaultDiscountPercentage: parseDouble(json['default_discount_percentage']),
      idProofType: json['id_proof_type']?.toString(),
      idProofNumber: json['id_proof_number']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'customer_type': customerType,
        'default_discount_percentage': defaultDiscountPercentage,
        'id_proof_type': idProofType,
        'id_proof_number': idProofNumber,
        'notes': notes,
      };
}

class CreateCustomerRequest {
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? customerType;
  final double? defaultDiscountPercentage;
  final String? idProofType;
  final String? idProofNumber;
  final String? notes;

  CreateCustomerRequest({
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.customerType,
    this.defaultDiscountPercentage,
    this.idProofType,
    this.idProofNumber,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'customer_type': customerType,
        'default_discount_percentage': defaultDiscountPercentage,
        'id_proof_type': idProofType,
        'id_proof_number': idProofNumber,
        'notes': notes,
      };
}

class QuickCustomerRequest {
  final String name;
  final String phone;
  final String? customerType;

  QuickCustomerRequest({
    required this.name,
    required this.phone,
    this.customerType = 'Retail',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'customer_type': customerType,
      };
}

class PaginationMetaModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMetaModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      PaginationMetaModel(
        currentPage: json['current_page'] ?? 1,
        lastPage: json['last_page'] ?? 1,
        perPage: json['per_page'] ?? 15,
        total: json['total'] ?? 0,
      );
}
