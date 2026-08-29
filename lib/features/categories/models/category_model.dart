class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final int? parentId;
  final String? parentName;
  final int itemsCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.parentName,
    this.itemsCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final parentObj = json['parent'] is Map ? json['parent'] : null;
    return CategoryModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name'] ?? '',
      description: json['description']?.toString(),
      parentId: json['parent_id'] != null
          ? (json['parent_id'] is int ? json['parent_id'] : int.tryParse(json['parent_id'].toString()))
          : null,
      parentName: parentObj != null ? parentObj['name']?.toString() : json['parent_name']?.toString(),
      itemsCount: json['items_count'] is int
          ? json['items_count']
          : (int.tryParse(json['items_count']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'parent_id': parentId,
      };

  CategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    int? parentId,
    String? parentName,
    int? itemsCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }
}
