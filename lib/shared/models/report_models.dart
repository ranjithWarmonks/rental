class CategoryModel {
  final int id;
  final String name;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}

class UnitModel {
  final int id;
  final String name;
  final String abbreviation;

  UnitModel({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) => UnitModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        abbreviation: json['abbreviation'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'abbreviation': abbreviation,
      };
}

class CustomFieldModel {
  final int id;
  final String name;
  final String fieldType;
  final bool isRequired;

  CustomFieldModel({
    required this.id,
    required this.name,
    required this.fieldType,
    this.isRequired = false,
  });

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) =>
      CustomFieldModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        fieldType: json['field_type'] ?? 'text',
        isRequired: json['is_required'] ?? false,
      );
}

class FinancialReportModel {
  final double totalIncome;
  final double totalExpense;
  final double netProfit;

  FinancialReportModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
  });

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) =>
      FinancialReportModel(
        totalIncome: (json['total_income'] ?? 0).toDouble(),
        totalExpense: (json['total_expense'] ?? 0).toDouble(),
        netProfit: (json['net_profit'] ?? 0).toDouble(),
      );
}
