import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import 'package:rental/shared/utils/form_validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company_profile_model.dart';
import '../models/user_profile_model.dart';

class CompanyProfileService {
  /// Fetch stored company/tenant details from API (GET /tenant) with fallback to SharedPreferences
  Future<CompanyProfileModel> getCompanyProfile() async {
    Map<String, dynamic> tenantData = {};
    try {
      final res = await ApiManager().getCall(tenantApiName);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body.containsKey('data') && body['data'] is Map) {
          tenantData = Map<String, dynamic>.from(body['data']);
        }
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Check direct company_details key
      final compJsonStr = prefs.getString('company_details');
      Map<String, dynamic> compMap = {};
      if (compJsonStr != null && compJsonStr.isNotEmpty) {
        try {
          compMap = jsonDecode(compJsonStr);
        } catch (_) {}
      }

      // 2. Check user_profile key for fallback info
      final userJsonStr = prefs.getString('user_profile');
      Map<String, dynamic> userMap = {};
      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        try {
          userMap = jsonDecode(userJsonStr);
        } catch (_) {}
      }

      // Merge data giving priority to explicit tenant API / company_details fields
      final companyName = (tenantData['name'] ?? compMap['company_name'] ?? compMap['companyName'] ?? userMap['companyName'] ?? userMap['company_name'] ?? 'Warmonks').toString();
      final phone = (compMap['phone_number'] ?? compMap['phoneNumber'] ?? userMap['phone'] ?? '+1 (555) 123-4567').toString();
      final email = (compMap['contact_email'] ?? compMap['contactEmail'] ?? userMap['email'] ?? 'contact@propmanager.com').toString();
      final address = (compMap['registered_address'] ?? compMap['registeredAddress'] ?? '123 Business Boulevard, Suite 400').toString();
      final gst = (compMap['gst_number'] ?? compMap['gstNumber'] ?? '27AAAAA0000A1Z5').toString();
      final pincode = (compMap['pincode'] ?? '10001').toString();
      final ownerName = (compMap['owner_name'] ?? compMap['ownerName'] ?? userMap['name'] ?? 'Admin User').toString();
      final businessType = (compMap['business_type'] ?? compMap['businessType'] ?? 'Rental & Event Services').toString();

      return CompanyProfileModel(
        companyName: companyName,
        registeredAddress: address,
        phoneNumber: phone,
        contactEmail: email,
        gstNumber: gst,
        pincode: pincode,
        ownerName: ownerName,
        businessType: businessType,
      );
    } catch (_) {
      return CompanyProfileModel(
        companyName: tenantData['name']?.toString() ?? 'Warmonks',
        registeredAddress: '123 Business Boulevard, Suite 400',
        phoneNumber: '+1 (555) 123-4567',
        contactEmail: 'contact@propmanager.com',
        gstNumber: '27AAAAA0000A1Z5',
        pincode: '10001',
        ownerName: 'Admin User',
        businessType: 'Rental & Event Services',
      );
    }
  }

  /// Save company details to SharedPreferences and sync with UserProfile
  Future<bool> saveCompanyProfile(CompanyProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cleanPhone = FormValidators.formatPhoneWithCountryCode(profile.phoneNumber);
      final formattedProfile = CompanyProfileModel(
        companyName: profile.companyName,
        registeredAddress: profile.registeredAddress,
        phoneNumber: cleanPhone,
        contactEmail: profile.contactEmail,
        gstNumber: profile.gstNumber,
        pincode: profile.pincode,
        ownerName: profile.ownerName,
        businessType: profile.businessType,
      );

      // Save company_details JSON
      await prefs.setString('company_details', jsonEncode(formattedProfile.toJson()));

      // Update user_profile JSON to keep company name in sync
      final userJsonStr = prefs.getString('user_profile');
      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        try {
          final userMap = Map<String, dynamic>.from(jsonDecode(userJsonStr));
          userMap['companyName'] = profile.companyName;
          if (profile.phoneNumber.isNotEmpty) userMap['phone'] = profile.phoneNumber;
          if (profile.contactEmail.isNotEmpty) userMap['email'] = profile.contactEmail;
          await prefs.setString('user_profile', jsonEncode(userMap));
        } catch (_) {}
      } else {
        final newProfile = UserProfileModel(
          name: profile.ownerName,
          phone: profile.phoneNumber,
          email: profile.contactEmail,
          role: 'Business Owner',
          companyName: profile.companyName,
        );
        await prefs.setString('user_profile', jsonEncode(newProfile.toJson()));
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
