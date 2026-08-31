import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';
import 'add_staff_view.dart';
import 'user_detail_view.dart';

import 'package:rental/shared/localization/app_language_controller.dart';

class StaffManagementView extends StatefulWidget {
  const StaffManagementView({super.key});

  @override
  State<StaffManagementView> createState() => _StaffManagementViewState();
}

class _StaffManagementViewState extends State<StaffManagementView> {
  final StaffService _staffService = StaffService();
  final TextEditingController _searchController = TextEditingController();

  List<StaffUserModel> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers([String searchQuery = '']) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final list = await _staffService.getUsers(searchQuery: searchQuery);
      if (mounted) {
        setState(() {
          _users = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _openAddStaffScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddStaffView()),
    );
    if (result == true) {
      _loadUsers(_searchController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguageController();

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.text('staff_users'),
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryColor),
            onPressed: () => _loadUsers(_searchController.text.trim()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddStaffScreen,
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'Add Staff Member',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AppTextField(
                label: 'Search Staff',
                hintText: 'Search by name or email...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => _loadUsers(val),
              ),
            ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: buttonColor1))
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _loadUsers(),
                                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                  label: const Text('Try Again', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor1),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _users.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.badge_outlined, size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No staff members found',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap "+ Add Staff Member" to invite your team',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _loadUsers(_searchController.text.trim()),
                              color: buttonColor1,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: _users.length,
                                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                                itemBuilder: (ctx, idx) {
                                  final u = _users[idx];

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final refresh = await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserDetailView(user: u),
                                          ),
                                        );
                                        if (refresh == true) {
                                          _loadUsers(_searchController.text.trim());
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.grey.shade200),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: buttonColor1.withValues(alpha: 0.1),
                                              child: Text(
                                                u.name.isNotEmpty ? u.name[0].toUpperCase() : 'S',
                                                style: const TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.bold,
                                                  color: buttonColor1,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          u.name,
                                                          style: const TextStyle(
                                                            fontFamily: 'Urbanist',
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                            color: primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue.shade50,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          u.roleName,
                                                          style: TextStyle(
                                                            fontFamily: 'Urbanist',
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 11,
                                                            color: Colors.blue.shade700,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    u.email,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 13,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  if (u.phone.isNotEmpty) ...[
                                                    const SizedBox(height: 3),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.phone_outlined, size: 13, color: Colors.grey.shade500),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          u.phone,
                                                          style: TextStyle(
                                                            fontFamily: 'Urbanist',
                                                            fontSize: 12,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  if (u.locationName != null && u.locationName!.isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.storefront_rounded, size: 14, color: Colors.grey.shade500),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          u.locationName!,
                                                          style: TextStyle(
                                                            fontFamily: 'Urbanist',
                                                            fontSize: 12,
                                                            color: Colors.grey.shade500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 22),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
