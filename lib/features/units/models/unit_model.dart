class UnitModel {
  final int id;
  final String name;
  final String abbreviation;
  final int itemsCount;

  UnitModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.itemsCount = 0,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? json['short_name'] ?? json['symbol'] ?? json['code'] ?? '',
      itemsCount: json['items_count'] is int
          ? json['items_count']
          : (int.tryParse(json['items_count']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'abbreviation': abbreviation,
        'short_name': abbreviation,
      };

  UnitModel copyWith({
    int? id,
    String? name,
    String? abbreviation,
    int? itemsCount,
  }) {
    return UnitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }
}
