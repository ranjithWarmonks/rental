class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String customerType; // Retail, B2B, VIP
  final String? idProofType;
  final String? idProofNumber;
  final String? notes;
  final int totalRentals;
  final int activeRentals;
  final double totalSpent;
  final String status; // ACTIVE, INACTIVE
  final String joinedDate;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    this.customerType = 'Retail',
    this.idProofType,
    this.idProofNumber,
    this.notes,
    required this.totalRentals,
    required this.activeRentals,
    required this.totalSpent,
    this.status = 'ACTIVE',
    required this.joinedDate,
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? customerType,
    String? idProofType,
    String? idProofNumber,
    String? notes,
    int? totalRentals,
    int? activeRentals,
    double? totalSpent,
    String? status,
    String? joinedDate,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      customerType: customerType ?? this.customerType,
      idProofType: idProofType ?? this.idProofType,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      notes: notes ?? this.notes,
      totalRentals: totalRentals ?? this.totalRentals,
      activeRentals: activeRentals ?? this.activeRentals,
      totalSpent: totalSpent ?? this.totalSpent,
      status: status ?? this.status,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}
