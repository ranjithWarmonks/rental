import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../models/unit_model.dart';
import '../services/unit_service.dart';

class UnitsView extends StatefulWidget {
  const UnitsView({super.key});

  @override
  State<UnitsView> createState() => _UnitsViewState();
}

class _UnitsViewState extends State<UnitsView> {
  final UnitService _unitService = UnitService();
  final TextEditingController _searchController = TextEditingController();

  List<UnitModel> _units = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUnits([String searchQuery = '']) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final list = await _unitService.getUnits(searchQuery: searchQuery);
      if (mounted) {
        setState(() {
          _units = list;
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

  void _openCreateOrEditDialog([UnitModel? unit]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UnitFormDialog(
        existingUnit: unit,
        onSaved: () {
          _loadUnits(_searchController.text.trim());
        },
      ),
    );
  }

  Future<void> _deleteUnit(UnitModel unit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Unit',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${unit.name}" (${unit.abbreviation})? This action cannot be undone.',
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Urbanist', color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _unitService.deleteUnit(unit.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unit "${unit.name}" deleted successfully.', style: const TextStyle(fontFamily: 'Urbanist')),
              backgroundColor: buttonColor1,
            ),
          );
          _loadUnits(_searchController.text.trim());
        }
      } catch (e) {
        if (mounted) {
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
          'Units of Measure',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryColor),
            onPressed: () => _loadUnits(_searchController.text.trim()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateOrEditDialog(),
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Create Unit',
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
                label: 'Search Units',
                hintText: 'Search by unit name or abbreviation...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => _loadUnits(val),
              ),
            ),

            // Content Section
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
                                  onPressed: () => _loadUnits(),
                                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                  label: const Text('Try Again', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor1),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _units.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.straighten_rounded, size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No units of measure found',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap "+ Create Unit" to add your first unit',
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
                              onRefresh: () => _loadUnits(_searchController.text.trim()),
                              color: buttonColor1,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: _units.length,
                                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                                itemBuilder: (ctx, idx) {
                                  final unit = _units[idx];
                                  return Material(
                                    color: Colors.transparent,
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
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: buttonColor1.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.straighten_rounded, color: buttonColor1, size: 22),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      unit.name,
                                                      style: const TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    if (unit.abbreviation.isNotEmpty)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.purple.shade50,
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: Colors.purple.shade100),
                                                        ),
                                                        child: Text(
                                                          unit.abbreviation,
                                                          style: TextStyle(
                                                            fontFamily: 'Urbanist',
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.purple.shade700,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Abbreviation: ${unit.abbreviation.isNotEmpty ? unit.abbreviation : 'N/A'}',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600, size: 20),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            onSelected: (val) {
                                              if (val == 'edit') {
                                                _openCreateOrEditDialog(unit);
                                              } else if (val == 'delete') {
                                                _deleteUnit(unit);
                                              }
                                            },
                                            itemBuilder: (ctx) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                                                    SizedBox(width: 10),
                                                    Text('Edit Unit', style: TextStyle(fontFamily: 'Urbanist')),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                                    SizedBox(width: 10),
                                                    Text('Delete', style: TextStyle(fontFamily: 'Urbanist', color: Color(0xFFDC2626))),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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

class _UnitFormDialog extends StatefulWidget {
  final UnitModel? existingUnit;
  final VoidCallback onSaved;

  const _UnitFormDialog({
    this.existingUnit,
    required this.onSaved,
  });

  @override
  State<_UnitFormDialog> createState() => _UnitFormDialogState();
}

class _UnitFormDialogState extends State<_UnitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _abbreviationController = TextEditingController();
  final UnitService _unitService = UnitService();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingUnit != null) {
      _nameController.text = widget.existingUnit!.name;
      _abbreviationController.text = widget.existingUnit!.abbreviation;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _abbreviationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.existingUnit == null) {
        await _unitService.createUnit(
          name: _nameController.text.trim(),
          abbreviation: _abbreviationController.text.trim(),
        );
      } else {
        await _unitService.updateUnit(
          widget.existingUnit!.id,
          name: _nameController.text.trim(),
          abbreviation: _abbreviationController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingUnit == null
                  ? 'Unit created successfully!'
                  : 'Unit updated successfully!',
              style: const TextStyle(fontFamily: 'Urbanist'),
            ),
            backgroundColor: buttonColor1,
          ),
        );
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
    final isEdit = widget.existingUnit != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Breadcrumb
                Row(
                  children: [
                    Text(
                      'Units of Measure',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      ' / ',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      isEdit ? 'Edit Unit' : 'Create Unit',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Unit Name Input Field
                AppTextField(
                  label: 'Unit Name (e.g., Piece, Set, Day)',
                  hintText: 'Enter unit name',
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Unit name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Abbreviation Input Field
                AppTextField(
                  label: 'Abbreviation (e.g., pcs, set, dy)',
                  hintText: 'Enter abbreviation',
                  controller: _abbreviationController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Abbreviation is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Action Buttons: Cancel and CREATE UNIT / SAVE UNIT
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor1,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isEdit ? 'SAVE UNIT' : 'CREATE UNIT',
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.8,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
