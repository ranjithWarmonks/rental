class LedgerTransactionModel {
  final int id;
  final String entryDate;
  final String type; // income, expense
  final double amount;
  final String description;
  final String category;
  final String? paymentMethod;

  LedgerTransactionModel({
    required this.id,
    required this.entryDate,
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    this.paymentMethod,
  });

  factory LedgerTransactionModel.fromJson(Map<String, dynamic> json) =>
      LedgerTransactionModel(
        id: json['id'] ?? 0,
        entryDate: json['entry_date'] ?? '',
        type: json['type'] ?? 'expense',
        amount: (json['amount'] ?? 0).toDouble(),
        description: json['description'] ?? '',
        category: json['category'] ?? '',
        paymentMethod: json['payment_method'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entry_date': entryDate,
        'type': type,
        'amount': amount,
        'description': description,
        'category': category,
        'payment_method': paymentMethod,
      };
}

class CreateLedgerEntryRequest {
  final String entryDate;
  final String type;
  final double amount;
  final String description;
  final String category;
  final String? paymentMethod;

  CreateLedgerEntryRequest({
    required this.entryDate,
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    this.paymentMethod = 'cash',
  });

  Map<String, dynamic> toJson() => {
        'entry_date': entryDate,
        'type': type,
        'amount': amount,
        'description': description,
        'category': category,
        'payment_method': paymentMethod,
      };
}

class LedgerCategoryModel {
  final int id;
  final String type;
  final String name;

  LedgerCategoryModel({
    required this.id,
    required this.type,
    required this.name,
  });

  factory LedgerCategoryModel.fromJson(Map<String, dynamic> json) =>
      LedgerCategoryModel(
        id: json['id'] ?? 0,
        type: json['type'] ?? 'expense',
        name: json['name'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
      };
}
