import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';

class PermissionModule {
  final String key;
  final String title;
  final IconData icon;

  const PermissionModule({
    required this.key,
    required this.title,
    required this.icon,
  });
}

class AddRoleView extends StatefulWidget {
  final RoleModel? existingRole;

  const AddRoleView({super.key, this.existingRole});

  @override
  State<AddRoleView> createState() => _AddRoleViewState();
}

class _AddRoleViewState extends State<AddRoleView> {
  final _formKey = GlobalKey<FormState>();
  final StaffService _staffService = StaffService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRole != null) {
      _nameController.text = widget.existingRole!.name;
      _descriptionController.text = widget.existingRole!.description ?? '';
      _selectedPermissions.addAll(widget.existingRole!.permissions);
    }
  }

  final List<PermissionModule> _modules = const [
    PermissionModule(key: 'rental', title: 'Rentals Orders & Returns', icon: Icons.assignment_outlined),
    PermissionModule(key: 'inventory', title: 'Inventory Items & Stock', icon: Icons.inventory_2_outlined),
    PermissionModule(key: 'stock_entry', title: 'Inward Stock Entries', icon: Icons.move_to_inbox_rounded),
    PermissionModule(key: 'stock_adjustment', title: 'Stock Adjustments', icon: Icons.tune_rounded),
    PermissionModule(key: 'item_availability', title: 'Item Availability Checker', icon: Icons.event_available_rounded),
    PermissionModule(key: 'category', title: 'Item Categories', icon: Icons.grid_view_rounded),
    PermissionModule(key: 'category_head', title: 'Category Head Management', icon: Icons.category_outlined),
    PermissionModule(key: 'unit', title: 'Units of Measure', icon: Icons.straighten_rounded),
    PermissionModule(key: 'location', title: 'Store & Godown Locations', icon: Icons.storefront_rounded),
    PermissionModule(key: 'customer', title: 'Customer Management', icon: Icons.people_outline_rounded),
    PermissionModule(key: 'sales', title: 'Sales & Billing', icon: Icons.point_of_sale_rounded),
    PermissionModule(key: 'ledger', title: 'Ledger & Expenses', icon: Icons.account_balance_wallet_outlined),
    PermissionModule(key: 'user', title: 'Staff & System Users', icon: Icons.badge_outlined),
    PermissionModule(key: 'role', title: 'Roles & Permissions', icon: Icons.admin_panel_settings_outlined),
    PermissionModule(key: 'company_profile', title: 'Company Profile', icon: Icons.business_outlined),
    PermissionModule(key: 'notification', title: 'Notifications & Reminders', icon: Icons.notifications_none_rounded),
    PermissionModule(key: 'report', title: 'Reports & Analytics', icon: Icons.bar_chart_rounded),
  ];

  final List<String> _actions = const ['view', 'add', 'edit', 'delete'];

  // Selected permission keys set e.g. {'rental-view', 'rental-add', ...}
  final Set<String> _selectedPermissions = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int get _totalPossiblePermissions => _modules.length * _actions.length;

  bool get _isAllSelected => _selectedPermissions.length == _totalPossiblePermissions;

  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        _selectedPermissions.clear();
      } else {
        _selectedPermissions.clear();
        for (var m in _modules) {
          for (var a in _actions) {
            _selectedPermissions.add('${m.key}-$a');
          }
        }
      }
    });
  }

  bool _isModuleAllSelected(String moduleKey) {
    for (var a in _actions) {
      if (!_selectedPermissions.contains('$moduleKey-$a')) return false;
    }
    return true;
  }

  void _toggleModuleAll(String moduleKey) {
    final allSelected = _isModuleAllSelected(moduleKey);
    setState(() {
      for (var a in _actions) {
        final permKey = '$moduleKey-$a';
        if (allSelected) {
          _selectedPermissions.remove(permKey);
        } else {
          _selectedPermissions.add(permKey);
        }
      }
    });
  }

  void _toggleSinglePermission(String permKey) {
    setState(() {
      if (_selectedPermissions.contains(permKey)) {
        _selectedPermissions.remove(permKey);
      } else {
        _selectedPermissions.add(permKey);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPermissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one permission for this role.', style: TextStyle(fontFamily: 'Urbanist')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final permsList = _selectedPermissions.toList();
      final isEdit = widget.existingRole != null;

      if (isEdit) {
        await _staffService.updateRole(
          id: widget.existingRole!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          permissions: permsList,
        );
      } else {
        await _staffService.createRole(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          permissions: permsList,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'Role updated successfully!' : 'Role created successfully!',
              style: const TextStyle(fontFamily: 'Urbanist'),
            ),
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
    final isEdit = widget.existingRole != null;
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
          isEdit ? 'Edit Role' : 'Create Role',
          style: const TextStyle(
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          isEdit ? 'Save Changes' : 'Save & Create Role',
                          style: const TextStyle(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Basic Details Card
                Container(
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
                        'Role Information',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Role Name Field
                      AppTextField(
                        label: 'Role Name *',
                        hintText: 'e.g. Store Manager, Cashier, Supervisor',
                        controller: _nameController,
                        prefixIcon: Icons.admin_panel_settings_outlined,
                        isRequired: true,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter role name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description Field
                      AppTextField(
                        label: 'Description',
                        hintText: 'Optional description of responsibilities...',
                        controller: _descriptionController,
                        prefixIcon: Icons.notes_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Permissions Section Header & Global Select All Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Menu Permissions',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_selectedPermissions.length} of $_totalPossiblePermissions permissions selected',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: buttonColor1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _toggleSelectAll,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isAllSelected ? buttonColor1.withValues(alpha: 0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isAllSelected ? buttonColor1 : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isAllSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                size: 18,
                                color: _isAllSelected ? buttonColor1 : Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isAllSelected ? 'Deselect All' : 'Select All',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _isAllSelected ? buttonColor1 : primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Module Permissions Cards List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _modules.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 14),
                  itemBuilder: (ctx, idx) {
                    final module = _modules[idx];
                    final isModuleAll = _isModuleAllSelected(module.key);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Module Title & Select Module All Checkbox
                          Row(
                            children: [
                              Icon(module.icon, size: 20, color: primaryColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  module.title,
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _toggleModuleAll(module.key),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isModuleAll ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                        size: 16,
                                        color: isModuleAll ? buttonColor1 : Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'All',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isModuleAll ? buttonColor1 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // 4 Action Chips (view, add, edit, delete)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _actions.map((action) {
                              final permKey = '${module.key}-$action';
                              final isSelected = _selectedPermissions.contains(permKey);

                              Color chipColor;
                              switch (action) {
                                case 'view':
                                  chipColor = Colors.blue;
                                  break;
                                case 'add':
                                  chipColor = Colors.green;
                                  break;
                                case 'edit':
                                  chipColor = Colors.orange.shade800;
                                  break;
                                case 'delete':
                                  chipColor = Colors.red;
                                  break;
                                default:
                                  chipColor = buttonColor1;
                              }

                              return InkWell(
                                onTap: () => _toggleSinglePermission(permKey),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? chipColor.withValues(alpha: 0.1) : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? chipColor : Colors.grey.shade300,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                        size: 14,
                                        color: isSelected ? chipColor : Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$action ($permKey)',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 12,
                                          color: isSelected ? chipColor : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
