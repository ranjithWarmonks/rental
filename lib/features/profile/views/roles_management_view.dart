import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';
import 'add_role_view.dart';

class RolesManagementView extends StatefulWidget {
  const RolesManagementView({super.key});

  @override
  State<RolesManagementView> createState() => _RolesManagementViewState();
}

class _RolesManagementViewState extends State<RolesManagementView> {
  final StaffService _staffService = StaffService();

  List<RoleModel> _roles = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final list = await _staffService.getRoles();
      if (mounted) {
        setState(() {
          _roles = list;
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

  void _openAddRoleScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddRoleView()),
    );
    if (result == true) {
      _loadRoles();
    }
  }

  void _openEditRoleScreen(RoleModel role) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => AddRoleView(existingRole: role)),
    );
    if (result == true) {
      _loadRoles();
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
          'Roles & Permissions',
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
            onPressed: _loadRoles,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddRoleScreen,
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.add_moderator_rounded, color: Colors.white),
        label: const Text(
          'Create Role',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
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
                            onPressed: _loadRoles,
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                            label: const Text('Try Again', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: buttonColor1),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadRoles,
                    color: buttonColor1,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _roles.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 14),
                      itemBuilder: (ctx, idx) {
                        final role = _roles[idx];

                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: buttonColor1.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.admin_panel_settings_outlined, color: buttonColor1, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          role.name,
                                          style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: primaryColor,
                                          ),
                                        ),
                                        if (role.description != null && role.description!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            role.description!,
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20, color: buttonColor1),
                                    onPressed: () => _openEditRoleScreen(role),
                                    tooltip: 'Edit Role & Permissions',
                                  ),
                                ],
                              ),

                              if (role.permissions.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Text(
                                  'PERMISSIONS (${role.permissions.length}):',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: role.permissions.map((p) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.blue.shade100),
                                      ),
                                      child: Text(
                                        p,
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
