import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import '../models/user_profile_models.dart';

class UserProfileService {
  /// Load cached user profile or return fallback defaults
  Future<UserProfileModel> getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('user_profile');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return UserProfileModel.fromJson(map);
      }
    } catch (_) {}

    return UserProfileModel(
      name: 'Admin User',
      phone: '+1 (555) 123-4567',
      email: 'admin@propmanager.com',
      role: 'Business Owner',
      companyName: 'PropManager Pro Rentals',
      appVersion: 'v1.0.0',
      buildNumber: '100',
    );
  }

  /// Save profile to local persistent storage
  Future<void> saveProfileToCache(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', jsonEncode(profile.toJson()));
    } catch (_) {}
  }

  /// Fetch user profile from `/me` endpoint and update cached storage
  Future<UserProfileModel> fetchProfile() async {
    final cached = await getCachedProfile();
    try {
      final res = await ApiManager().getCall(meApiName);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final profileRes = UserProfileResponse.fromJson(data);
        final apiUser = profileRes.data;

        final updated = cached.copyWith(
          name: apiUser.name.isNotEmpty ? apiUser.name : cached.name,
          email: apiUser.email.isNotEmpty ? apiUser.email : cached.email,
        );

        await saveProfileToCache(updated);
        return updated;
      }
    } catch (_) {}
    return cached;
  }

  Future<bool> updateProfile(UserProfileModel profile) async {
    await saveProfileToCache(profile);
    try {
      final req = UpdateProfileRequest(name: profile.name, email: profile.email);
      final res = await ApiManager().patchCall(
        meApiName,
        jsonEncode(req.toJson()),
      );
      if (res.statusCode == 200) {
        return true;
      }
    } catch (_) {}
    return true;
  }

  Future<void> logout() async {
    try {
      await ApiManager().postCall(logoutApiName, jsonEncode({}));
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('user_token');
    await prefs.remove('profile');
    await prefs.remove('user_profile');
    await prefs.remove('company_details');
  }
}

