import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/models/auth_models.dart';

class PermissionManager {
  static Future<AuthUserModel?> getLoggedInUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileStr = prefs.getString('profile');
      if (profileStr != null && profileStr.isNotEmpty) {
        final map = jsonDecode(profileStr);
        if (map is Map) {
          return AuthUserModel.fromJson(Map<String, dynamic>.from(map));
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> hasPermission(String requiredPermission) async {
    final user = await getLoggedInUser();
    if (user == null) return true;
    return user.hasPermission(requiredPermission);
  }

  static Future<bool> hasAnyPermission(List<String> permissions) async {
    final user = await getLoggedInUser();
    if (user == null) return true;
    for (var perm in permissions) {
      if (user.hasPermission(perm)) return true;
    }
    return false;
  }
}
