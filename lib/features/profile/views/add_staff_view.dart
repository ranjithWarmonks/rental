import 'package:flutter/material.dart';
import 'package:rental/features/auth/models/auth_models.dart';
import 'package:rental/shared/services/location_service.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import 'package:rental/shared/utils/form_validators.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';
import 'add_role_view.dart';

class AddStaffView extends StatefulWidget {
  const AddStaffView({super.key});

  @override
  State<AddStaffView> createState() => _AddStaffViewState();
}

class _AddStaffViewState extends State<AddStaffView> {
  final _formKey = GlobalKey<FormState>();
  final StaffService _staffService = StaffService();
  final LocationService _locationService = LocationService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<RoleModel> _roles = [];
  List<StoreLocationModel> _locations = [];

  int? _selectedRoleId;
  int? _selectedLocationId;

  bool _isLoadingMetaData = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fetchMetaData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchMetaData() async {
    try {
      final results = await Future.wait([
        _staffService.getRoles(),
        _locationService.getLocations(),
      ]);

      if (mounted) {
        final rolesList = results[0] as List<RoleModel>;
        final locsList = results[1] as List<StoreLocationModel>;

        setState(() {
          _roles = rolesList;
          _locations = locsList;

          if (rolesList.isNotEmpty) {
            _selectedRoleId = rolesList.first.id;
          }
          if (locsList.isNotEmpty) {
            _selectedLocationId = locsList.firstWhere((l) => l.isDefault, orElse: () => locsList.first).id;
          }
          _isLoadingMetaData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMetaData = false);
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role.', style: TextStyle(fontFamily: 'Urbanist')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final emailVal = _emailController.text.trim();
      await _staffService.createUser(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: emailVal.isNotEmpty ? emailVal : null,
        password: _passwordController.text,
        roleId: _selectedRoleId,
        locationId: _selectedLocationId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created successfully!', style: TextStyle(fontFamily: 'Urbanist')),
            backgroundColor: buttonColor1,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontFamily: 'Urbanist')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Staff Member',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Create Staff Member',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingMetaData
            ? const Center(child: CircularProgressIndicator(color: buttonColor1))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card Container
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Staff Account Details',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create login credentials and assign role & store location access for your new team member.',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Full Name Field
                            AppTextField(
                              label: 'Full Name *',
                              hintText: 'e.g. Sarah Staff',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline_rounded,
                              isRequired: true,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter full name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Email Address Field (Nullable/Optional)
                            AppTextField(
                              label: 'Email Address',
                              hintText: 'e.g. sarah@example.com (optional)',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => FormValidators.validateEmail(val, isRequired: false),
                            ),

                            const SizedBox(height: 16),

                            // Phone Number Field (Required)
                            AppTextField(
                              label: 'Phone Number *',
                              hintText: 'e.g. +91 9876543210',
                              controller: _phoneController,
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              isRequired: true,
                              validator: (val) => FormValidators.validatePhone(val, isRequired: true),
                            ),

                            const SizedBox(height: 16),

                            // Password Field (Required, min: 8)
                            AppTextField(
                              label: 'Password *',
                              hintText: 'Minimum 8 characters',
                              controller: _passwordController,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              isRequired: true,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (val.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Role Selection Dropdown Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Assign Role',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: primaryColor,
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    final created = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddRoleView()),
                                    );
                                    if (created == true) {
                                      _fetchMetaData();
                                    }
                                  },
                                  child: const Text(
                                    '+ Create Role',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: buttonColor1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedRoleId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: primaryColor),
                                  items: _roles.map((role) {
                                    return DropdownMenuItem<int>(
                                      value: role.id,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.admin_panel_settings_outlined, size: 18, color: buttonColor1),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  role.name,
                                                  style: const TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                                if (role.description != null && role.description!.isNotEmpty)
                                                  Text(
                                                    role.description!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 11,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedRoleId = val);
                                    }
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Store Location Dropdown
                            const Text(
                              'Assigned Store Location',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: _selectedLocationId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: primaryColor),
                                  hint: Text('Select location...', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.grey.shade500)),
                                  items: _locations.map((loc) {
                                    return DropdownMenuItem<int?>(
                                      value: loc.id,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.storefront_rounded, size: 18, color: buttonColor1),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${loc.name}${loc.code != null ? " (${loc.code})" : ""}',
                                            style: const TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() => _selectedLocationId = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
