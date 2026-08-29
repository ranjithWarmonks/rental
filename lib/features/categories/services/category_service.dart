import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import '../models/category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> getCategories({String? searchQuery, bool all = true}) async {
    final queryParams = <String>[];
    if (all) queryParams.add('all=true');
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(searchQuery.trim())}');
    }

    final url = queryParams.isEmpty
        ? categoriesApiName
        : '$categoriesApiName?${queryParams.join('&')}';

    final res = await ApiManager().getCall(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List<dynamic> rawList = [];

      if (data is Map && data.containsKey('data')) {
        final dataVal = data['data'];
        if (dataVal is List) {
          rawList = dataVal;
        } else if (dataVal is Map && dataVal.containsKey('data') && dataVal['data'] is List) {
          rawList = dataVal['data'];
        } else if (dataVal is Map) {
          rawList = [dataVal];
        }
      } else if (data is List) {
        rawList = data;
      }

      return rawList
          .map((raw) => CategoryModel.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
    } else {
      throw Exception('Failed to load categories (${res.statusCode})');
    }
  }

  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    int? parentId,
  }) async {
    final bodyMap = <String, dynamic>{
      'name': name.trim(),
    };
    if (description != null && description.trim().isNotEmpty) {
      bodyMap['description'] = description.trim();
    }
    if (parentId != null && parentId > 0) {
      bodyMap['parent_id'] = parentId;
    }

    final res = await ApiManager().postCall(
      categoriesApiName,
      jsonEncode(bodyMap),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final raw = data is Map && data.containsKey('data') ? data['data'] : data;
      if (raw is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(raw));
      }
      return CategoryModel(id: 0, name: name, description: description, parentId: parentId);
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to create category (${res.statusCode})';
      throw Exception(msg);
    }
  }

  Future<CategoryModel> updateCategory(
    int id, {
    required String name,
    String? description,
    int? parentId,
  }) async {
    final bodyMap = <String, dynamic>{
      'name': name.trim(),
    };
    if (description != null) {
      bodyMap['description'] = description.trim();
    }
    if (parentId != null && parentId > 0) {
      bodyMap['parent_id'] = parentId;
    }

    final res = await ApiManager().patchCall(
      categoryDetailApiName(id),
      jsonEncode(bodyMap),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final raw = data is Map && data.containsKey('data') ? data['data'] : data;
      if (raw is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(raw));
      }
      return CategoryModel(id: id, name: name, description: description, parentId: parentId);
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to update category (${res.statusCode})';
      throw Exception(msg);
    }
  }

  Future<void> deleteCategory(int id) async {
    final res = await ApiManager().deleteCall(categoryDetailApiName(id));
    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    } else if (res.statusCode == 409) {
      throw Exception('Cannot delete category: Items are currently associated with this category.');
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to delete category (${res.statusCode})';
      throw Exception(msg);
    }
  }
}
