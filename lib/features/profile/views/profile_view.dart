import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';

class ProfileView extends StatefulWidget {
  final UserProfileModel userProfile;

  const ProfileView({
    super.key,
    required this.userProfile,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _phoneController = TextEditingController(text: widget.userProfile.phone);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _companyController = TextEditingController(text: widget.userProfile.companyName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final updatedProfile = widget.userProfile.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      companyName: _companyController.text.trim(),
    );

    await UserProfileService().updateProfile(updatedProfile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!', style: TextStyle(fontFamily: 'Urbanist')),
          backgroundColor: buttonColor1,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText.h2('My Profile', fontSize: 20),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Avatar Header
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, size: 50, color: primaryColor),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: buttonColor1,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h3('Personal & Business Details', fontSize: 16),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Full Name',
                      hintText: 'Enter full name',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      isRequired: true,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Phone Number',
                      hintText: 'Enter phone number',
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                      isRequired: true,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Email Address',
                      hintText: 'Enter email address',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Company Name',
                      hintText: 'Enter company name',
                      controller: _companyController,
                      prefixIcon: Icons.business_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: AppButton(
            text: 'Save Changes',
            onPressed: _saveProfile,
          ),
        ),
      ),
    );
  }
}
