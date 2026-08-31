import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

import 'package:rental/shared/localization/app_language_controller.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories([String searchQuery = '']) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final list = await _categoryService.getCategories(searchQuery: searchQuery);
      if (mounted) {
        setState(() {
          _categories = list;
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

  void _openCreateOrEditDialog([CategoryModel? category]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CategoryFormDialog(
        existingCategory: category,
        allCategories: _categories,
        onSaved: () {
          _loadCategories(_searchController.text.trim());
        },
      ),
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Category',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
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
        await _categoryService.deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${category.name}" deleted successfully.', style: const TextStyle(fontFamily: 'Urbanist')),
              backgroundColor: buttonColor1,
            ),
          );
          _loadCategories(_searchController.text.trim());
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
          lang.text('item_categories'),
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryColor),
            onPressed: () => _loadCategories(_searchController.text.trim()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateOrEditDialog(),
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Create Category',
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
            // Search Bar Card
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AppTextField(
                label: 'Search Categories',
                hintText: 'Search by category name...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => _loadCategories(val),
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
                                  onPressed: () => _loadCategories(),
                                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                  label: const Text('Try Again', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor1),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _categories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.category_outlined, size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No categories found',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap "+ Create Category" to add your first category',
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
                              onRefresh: () => _loadCategories(_searchController.text.trim()),
                              color: buttonColor1,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: _categories.length,
                                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                                itemBuilder: (ctx, idx) {
                                  final cat = _categories[idx];
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: buttonColor1.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.category_rounded, color: buttonColor1, size: 22),
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
                                                        cat.name,
                                                        style: const TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                          color: primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                    if (cat.parentName != null && cat.parentName!.isNotEmpty)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue.shade50,
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: Colors.blue.shade100),
                                                        ),
                                                        child: Text(
                                                          'Parent: ${cat.parentName}',
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
                                                if (cat.description != null && cat.description!.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    cat.description!,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 13,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey.shade500),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${cat.itemsCount} ${cat.itemsCount == 1 ? 'item' : 'items'}',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600, size: 20),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            onSelected: (val) {
                                              if (val == 'edit') {
                                                _openCreateOrEditDialog(cat);
                                              } else if (val == 'delete') {
                                                _deleteCategory(cat);
                                              }
                                            },
                                            itemBuilder: (ctx) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                                                    SizedBox(width: 10),
                                                    Text('Edit Category', style: TextStyle(fontFamily: 'Urbanist')),
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

class _CategoryFormDialog extends StatefulWidget {
  final CategoryModel? existingCategory;
  final List<CategoryModel> allCategories;
  final VoidCallback onSaved;

  const _CategoryFormDialog({
    this.existingCategory,
    required this.allCategories,
    required this.onSaved,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  int? _selectedParentId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCategory != null) {
      _nameController.text = widget.existingCategory!.name;
      _descriptionController.text = widget.existingCategory!.description ?? '';
      _selectedParentId = widget.existingCategory!.parentId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.existingCategory == null) {
        await _categoryService.createCategory(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
          parentId: _selectedParentId,
        );
      } else {
        await _categoryService.updateCategory(
          widget.existingCategory!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
          parentId: _selectedParentId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingCategory == null
                  ? 'Category created successfully!'
                  : 'Category updated successfully!',
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
    final isEdit = widget.existingCategory != null;

    // Filter available parent categories (exclude self if editing)
    final parentOptions = widget.allCategories
        .where((c) => !isEdit || c.id != widget.existingCategory!.id)
        .toList();

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
                // Header Title
                Text(
                  isEdit ? 'Edit Category' : 'Create Category',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 20),

                // Name Input Field
                AppTextField(
                  label: 'Name',
                  hintText: 'Enter category name',
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Category name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Parent Category (Optional) Dropdown
                const Text(
                  'Parent Category (Optional)',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  initialValue: _selectedParentId,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: buttonColor1),
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 15,
                    color: primaryColor,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('None (Top Level)', style: TextStyle(fontFamily: 'Urbanist')),
                    ),
                    ...parentOptions.map(
                      (c) => DropdownMenuItem<int?>(
                        value: c.id,
                        child: Text(c.name, style: const TextStyle(fontFamily: 'Urbanist')),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedParentId = val;
                    });
                  },
                ),

                const SizedBox(height: 18),

                // Description Multiline Input Field
                const Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(fontFamily: 'Urbanist', fontSize: 15, color: primaryColor),
                  decoration: InputDecoration(
                    hintText: 'Enter category description...',
                    hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: buttonColor1),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons: Cancel and CREATE / SAVE
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
                              isEdit ? 'SAVE' : 'CREATE',
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
