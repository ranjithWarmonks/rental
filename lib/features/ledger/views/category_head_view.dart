import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_dialog.dart';
import 'package:rental/shared/widgets/app_text.dart';
import '../models/ledger_models.dart';
import '../services/category_head_service.dart';

class CategoryHeadView extends StatefulWidget {
  const CategoryHeadView({super.key});

  @override
  State<CategoryHeadView> createState() => _CategoryHeadViewState();
}

class _CategoryHeadViewState extends State<CategoryHeadView> {
  final CategoryHeadService _service = CategoryHeadService();
  final TextEditingController _categoryNameController = TextEditingController();

  String _selectedType = 'Income';
  List<LedgerCategoryModel> _categories = [];
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final list = await _service.getCategories();
    if (mounted) {
      setState(() {
        _categories = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _addCategory() async {
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter category name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isAdding = true);
    final newCat = await _service.addCategory(_selectedType, name);
    _categoryNameController.clear();

    if (mounted) {
      setState(() {
        _categories.add(newCat);
        _isAdding = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "${newCat.name}" added!'),
          backgroundColor: buttonColor1,
        ),
      );
    }
  }

  void _confirmDeleteCategory(LedgerCategoryModel category) {
    AppDialog.show(
      context: context,
      title: 'Delete Category?',
      message: 'Are you sure you want to delete "${category.name}"?',
      type: AppDialogType.error,
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        await _service.deleteCategory(category.id);
        if (mounted) {
          setState(() {
            _categories.removeWhere((c) => c.id == category.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${category.name}" deleted.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomeCategories = _categories.where((c) => c.type.toLowerCase() == 'income').toList();
    final expenseCategories = _categories.where((c) => c.type.toLowerCase() == 'expense').toList();

    final isDesktopOrTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          'Category Head Management',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: buttonColor1))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section: ADD CATEGORY HEAD CARD (Matching input_file_0.png)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ADD CATEGORY HEAD',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Input Bar Row
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 500;
                            return isMobile
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          _buildTypeDropdown(),
                                          const SizedBox(width: 10),
                                          Expanded(child: _buildNameTextField()),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: _buildAddButton(),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      _buildTypeDropdown(),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildNameTextField()),
                                      const SizedBox(width: 12),
                                      _buildAddButton(),
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Section: Categories Lists (Income & Expense)
                  if (isDesktopOrTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildIncomeCard(incomeCategories)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildExpenseCard(expenseCategories)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildIncomeCard(incomeCategories),
                        const SizedBox(height: 20),
                        _buildExpenseCard(expenseCategories),
                      ],
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3B82F6)),
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF1E293B),
          ),
          items: ['Income', 'Expense'].map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(type),
                  if (_selectedType == type) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check, size: 14, color: Color(0xFF1E293B)),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedType = val);
          },
        ),
      ),
    );
  }

  Widget _buildNameTextField() {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _categoryNameController,
        style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Category name',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontFamily: 'Urbanist',
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: _isAdding ? null : _addCategory,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF818CF8), // Purple accent tint matching screenshot
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _isAdding
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildIncomeCard(List<LedgerCategoryModel> categories) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green Header Bar (Matching input_file_0.png)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5), // Soft green tint
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Text(
              'INCOME CATEGORIES',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF059669),
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Categories List
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No income categories',
                  style: TextStyle(fontFamily: 'Urbanist', color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _confirmDeleteCategory(cat),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(List<LedgerCategoryModel> categories) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red/Pink Header Bar (Matching input_file_0.png)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2), // Soft pink/red tint
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Text(
              'EXPENSE CATEGORIES',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE11D48),
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Categories List
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No expense categories',
                  style: TextStyle(fontFamily: 'Urbanist', color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _confirmDeleteCategory(cat),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
