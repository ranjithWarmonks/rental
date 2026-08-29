import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_status_badge.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import 'package:rental/shared/utils/form_validators.dart';
import '../models/company_profile_model.dart';
import '../services/company_profile_service.dart';

class CompanyProfileView extends StatefulWidget {
  const CompanyProfileView({super.key});

  @override
  State<CompanyProfileView> createState() => _CompanyProfileViewState();
}

class _CompanyProfileViewState extends State<CompanyProfileView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _businessTypeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _pincodeController;
  late TextEditingController _gstController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _ownerNameController = TextEditingController();
    _businessTypeController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _pincodeController = TextEditingController();
    _gstController = TextEditingController();

    _loadCompanyProfile();
  }

  Future<void> _loadCompanyProfile() async {
    final profile = await CompanyProfileService().getCompanyProfile();
    if (mounted) {
      setState(() {
        _companyNameController.text = profile.companyName;
        _ownerNameController.text = profile.ownerName;
        _businessTypeController.text = profile.businessType;
        _phoneController.text = profile.phoneNumber;
        _emailController.text = profile.contactEmail;
        _addressController.text = profile.registeredAddress;
        _pincodeController.text = profile.pincode;
        _gstController.text = profile.gstNumber ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _ownerNameController.dispose();
    _businessTypeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  Future<void> _saveCompanyProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final updatedModel = CompanyProfileModel(
      companyName: _companyNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      businessType: _businessTypeController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      contactEmail: _emailController.text.trim(),
      registeredAddress: _addressController.text.trim(),
      pincode: _pincodeController.text.trim(),
      gstNumber: _gstController.text.trim().isNotEmpty ? _gstController.text.trim() : null,
    );

    final success = await CompanyProfileService().saveCompanyProfile(updatedModel);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Company details saved successfully!' : 'Failed to save company details.',
            style: const TextStyle(fontFamily: 'Urbanist'),
          ),
          backgroundColor: success ? buttonColor1 : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (success) {
        Navigator.pop(context, true);
      }
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
          icon: const Icon(Icons.arrow_back_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText.h2('Company Profile', fontSize: 20),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(buttonColor1),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card with Branding Badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: buttonColor1.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.business_rounded,
                                color: buttonColor1,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.h3(
                                    _companyNameController.text.isNotEmpty
                                        ? _companyNameController.text
                                        : 'Company Details',
                                    fontSize: 18,
                                  ),
                                  const SizedBox(height: 4),
                                  AppText.caption(
                                    _businessTypeController.text.isNotEmpty
                                        ? _businessTypeController.text
                                        : 'Rental & Business Account',
                                    fontSize: 13,
                                  ),
                                  const SizedBox(height: 6),
                                  AppStatusBadge.fromStatus('Verified Business'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Business & Owner Details Section
                      AppText.caption(
                        'BUSINESS INFORMATION',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            AppTextField(
                              label: 'Company Name',
                              hintText: 'Enter company name',
                              controller: _companyNameController,
                              prefixIcon: Icons.business_outlined,
                              isRequired: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Company name is required';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Owner / Authorized Person',
                              hintText: 'Enter owner or contact name',
                              controller: _ownerNameController,
                              prefixIcon: Icons.person_outline,
                              isRequired: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Owner name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Business Category / Type',
                              hintText: 'e.g. Equipment Rentals, Event Management',
                              controller: _businessTypeController,
                              prefixIcon: Icons.category_outlined,
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Contact & Location Details Section
                      AppText.caption(
                        'CONTACT & ADDRESS',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            AppTextField(
                              label: 'Phone Number',
                              hintText: 'Enter contact phone number',
                              controller: _phoneController,
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              isRequired: true,
                              validator: (val) => FormValidators.validatePhone(val, isRequired: true),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Contact Email',
                              hintText: 'Enter business email address',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              isRequired: true,
                              validator: (val) => FormValidators.validateEmail(val, isRequired: true),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Registered Office Address',
                              hintText: 'Building, street, suite details',
                              controller: _addressController,
                              prefixIcon: Icons.location_on_outlined,
                              maxLines: 3,
                              isRequired: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Registered address is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Pincode / Zip Code',
                              hintText: 'Enter pincode',
                              controller: _pincodeController,
                              prefixIcon: Icons.pin_drop_outlined,
                              keyboardType: TextInputType.number,
                              isRequired: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Pincode is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tax & Compliance Section
                      AppText.caption(
                        'TAX & REGISTRATION',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: AppTextField(
                          label: 'GST Number (GSTIN)',
                          hintText: 'e.g. 27AAAAA0000A1Z5',
                          controller: _gstController,
                          prefixIcon: Icons.receipt_long_outlined,
                          isOptional: true,
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
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
            text: 'Save Company Profile',
            icon: Icons.check_circle_outline_rounded,
            isLoading: _isSaving,
            onPressed: _saveCompanyProfile,
          ),
        ),
      ),
    );
  }
}
