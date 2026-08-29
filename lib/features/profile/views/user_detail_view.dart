import 'package:flutter/material.dart';
import 'package:rental/features/auth/models/auth_models.dart';
import 'package:rental/shared/services/location_service.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import 'package:rental/shared/utils/form_validators.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';

class UserDetailView extends StatefulWidget {
  final StaffUserModel user;

  const UserDetailView({
    super.key,
    required this.user,
  });

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView> {
  final StaffService _staffService = StaffService();

  late StaffUserModel _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final updated = await _staffService.getUserDetails(_currentUser.id);
      if (mounted) {
        setState(() {
          _currentUser = updated;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openUpdateDialog() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditUserBottomSheet(user: _currentUser),
    );

    if (updated == true) {
      _fetchUserDetails();
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
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Staff User Details',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryColor),
            onPressed: _fetchUserDetails,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _openUpdateDialog,
              icon: const Icon(Icons.edit_note_rounded, size: 22, color: Colors.white),
              label: const Text(
                'Update User Details',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: buttonColor1))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: buttonColor1.withValues(alpha: 0.1),
                            child: Text(
                              _currentUser.name.isNotEmpty ? _currentUser.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: buttonColor1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _currentUser.name,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _currentUser.roleName,
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _currentUser.isActive ? Colors.green.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 3,
                                      backgroundColor: _currentUser.isActive ? Colors.green.shade600 : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _currentUser.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: _currentUser.isActive ? Colors.green.shade700 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Information Details Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Details',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone Number',
                            value: _currentUser.phone.isNotEmpty ? _currentUser.phone : 'Not provided',
                          ),
                          const Divider(height: 24),

                          _buildDetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            value: _currentUser.email.isNotEmpty ? _currentUser.email : 'Not provided',
                          ),
                          const Divider(height: 24),

                          _buildDetailRow(
                            icon: Icons.storefront_rounded,
                            label: 'Assigned Store Location',
                            value: _currentUser.locationName ?? 'All Locations Access',
                          ),
                          const Divider(height: 24),

                          _buildDetailRow(
                            icon: Icons.admin_panel_settings_outlined,
                            label: 'Role Access Level',
                            value: _currentUser.roleName,
                          ),
                          if (_currentUser.createdAt.isNotEmpty) ...[
                            const Divider(height: 24),
                            _buildDetailRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Member Since',
                              value: _currentUser.createdAt,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditUserBottomSheet extends StatefulWidget {
  final StaffUserModel user;

  const _EditUserBottomSheet({required this.user});

  @override
  State<_EditUserBottomSheet> createState() => _EditUserBottomSheetState();
}

class _EditUserBottomSheetState extends State<_EditUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final StaffService _staffService = StaffService();
  final LocationService _locationService = LocationService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();

  List<RoleModel> _roles = [];
  List<StoreLocationModel> _locations = [];

  int? _selectedRoleId;
  int? _selectedLocationId;
  bool _isActive = true;

  bool _isLoadingMeta = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRoleId = widget.user.roleId;
    _selectedLocationId = widget.user.locationId;
    _isActive = widget.user.isActive;

    _loadMetaData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadMetaData() async {
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

          if (_selectedRoleId == null && rolesList.isNotEmpty) {
            _selectedRoleId = rolesList.first.id;
          }

          _isLoadingMeta = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMeta = false);
      }
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final emailVal = _emailController.text.trim();
      final passwordVal = _passwordController.text;

      await _staffService.updateUser(
        id: widget.user.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: emailVal.isNotEmpty ? emailVal : null,
        password: passwordVal.isNotEmpty ? passwordVal : null,
        roleId: _selectedRoleId,
        locationId: _selectedLocationId,
        isActive: _isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User details updated successfully!', style: TextStyle(fontFamily: 'Urbanist')),
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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle & Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Update Staff Details',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Form
            Expanded(
              child: _isLoadingMeta
                  ? const Center(child: CircularProgressIndicator(color: buttonColor1))
                  : SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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

                            // Phone Field
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

                            // Email Field
                            AppTextField(
                              label: 'Email Address (Optional)',
                              hintText: 'e.g. sarah@example.com',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              validator: (val) => FormValidators.validateEmail(val, isRequired: false),
                            ),
                            const SizedBox(height: 16),

                            // Password Field (Optional change)
                            AppTextField(
                              label: 'New Password (Optional)',
                              hintText: 'Leave blank to keep current password',
                              controller: _passwordController,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
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
                                if (val != null && val.isNotEmpty && val.length < 8) {
                                  return 'New password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Role Selection Dropdown
                            const Text(
                              'Assigned Role',
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
                                  value: _selectedRoleId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: primaryColor),
                                  hint: Text('Select role...', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.grey.shade500)),
                                  items: _roles.map((role) {
                                    return DropdownMenuItem<int?>(
                                      value: role.id,
                                      child: Text(
                                        role.name,
                                        style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: primaryColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() => _selectedRoleId = val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Store Location Selection Dropdown
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
                                      child: Text(
                                        '${loc.name}${loc.code != null ? " (${loc.code})" : ""}',
                                        style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: primaryColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() => _selectedLocationId = val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Active Status Switch
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Account Active Status',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _isActive,
                                    activeTrackColor: buttonColor1,
                                    onChanged: (val) {
                                      setState(() => _isActive = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitUpdate,
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
                                          Icon(Icons.save_rounded, size: 20, color: Colors.white),
                                          SizedBox(width: 10),
                                          Text(
                                            'Save Changes',
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
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
