import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/shared/theme/app_color.dart';
import '../../categories/models/category_model.dart';
import '../../categories/services/category_service.dart';
import '../../units/models/unit_model.dart';
import '../../units/services/unit_service.dart';
import '../controllers/inventory_bloc.dart';
import '../controllers/inventory_event.dart';
import '../models/inventory_models.dart';

class AddEditItemView extends StatefulWidget {
  final InventoryItemModel? itemToEdit;

  const AddEditItemView({super.key, this.itemToEdit});

  @override
  State<AddEditItemView> createState() => _AddEditItemViewState();
}

class _AddEditItemViewState extends State<AddEditItemView> {
  final _formKey = GlobalKey<FormState>();

  final CategoryService _categoryService = CategoryService();
  final UnitService _unitService = UnitService();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _rateController;
  late final TextEditingController _depositController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _replacementController;
  late final TextEditingController _damageFeeController;

  int? _selectedCategoryId;
  int? _selectedUnitId;
  String _pricingMode = 'day'; // 'day' (Per day) or 'flat' (Flat price)
  String _status = 'active'; // 'active' or 'inactive'
  String _availableFor = 'rental'; // 'rental', 'sale', or 'both'
  bool _autoGenerateSku = true;

  List<CategoryModel> _categories = [];
  List<UnitModel> _units = [];
  bool _isLoadingDropdowns = true;

  bool get isEdit => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _skuController = TextEditingController(text: item?.sku ?? '');
    _rateController = TextEditingController(text: item != null ? item.pricePerDay.toStringAsFixed(2) : '0.00');
    _depositController = TextEditingController(text: item != null ? item.depositAmount.toStringAsFixed(2) : '0.00');
    _salePriceController = TextEditingController(text: item?.salePrice != null ? item!.salePrice!.toStringAsFixed(2) : '');
    _replacementController = TextEditingController(text: item != null ? item.replacementCost.toStringAsFixed(2) : '0.00');
    _damageFeeController = TextEditingController(text: item != null ? item.damageFee.toStringAsFixed(2) : '0.00');

    if (item != null) {
      _selectedCategoryId = item.categoryId > 0 ? item.categoryId : null;
      _selectedUnitId = item.unitId > 0 ? item.unitId : null;
      _pricingMode = item.pricingMode == 'flat' ? 'flat' : 'day';
      _status = item.status == 'inactive' ? 'inactive' : 'active';
      
      final mode = item.availableFor.toLowerCase();
      if (mode.contains('sale') && mode.contains('rental')) {
        _availableFor = 'both';
      } else if (mode.contains('sale')) {
        _availableFor = 'sale';
      } else {
        _availableFor = 'rental';
      }
      
      _autoGenerateSku = item.sku.isEmpty;
    }

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        _categoryService.getCategories(all: true),
        _unitService.getUnits(),
      ]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<CategoryModel>;
          _units = results[1] as List<UnitModel>;
          _isLoadingDropdowns = false;

          if (_selectedCategoryId == null && _categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
          if (_selectedUnitId == null && _units.isNotEmpty) {
            _selectedUnitId = _units.first.id;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDropdowns = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _rateController.dispose();
    _depositController.dispose();
    _salePriceController.dispose();
    _replacementController.dispose();
    _damageFeeController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      final generatedSku = 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final finalSku = _autoGenerateSku
          ? (isEdit && widget.itemToEdit!.sku.isNotEmpty ? widget.itemToEdit!.sku : generatedSku)
          : (_skuController.text.trim().isNotEmpty ? _skuController.text.trim() : generatedSku);

      final req = CreateItemRequest(
        name: _nameController.text.trim(),
        sku: finalSku,
        categoryId: _selectedCategoryId ?? 1,
        unitId: _selectedUnitId ?? 1,
        status: _status,
        availableFor: _availableFor,
        pricingMode: _pricingMode,
        pricePerDay: _availableFor == 'sale'
            ? 0.0
            : (double.tryParse(_rateController.text.trim()) ?? 0.0),
        depositAmount: _availableFor == 'sale'
            ? 0.0
            : (double.tryParse(_depositController.text.trim()) ?? 0.0),
        salePrice: _availableFor == 'rental'
            ? null
            : (_salePriceController.text.trim().isNotEmpty
                ? double.tryParse(_salePriceController.text.trim())
                : null),
        replacementCost: double.tryParse(_replacementController.text.trim()) ?? 0.0,
        damageFee: double.tryParse(_damageFeeController.text.trim()) ?? 0.0,
      );

      if (isEdit) {
        context.read<InventoryBloc>().add(UpdateItemRequested(
              id: widget.itemToEdit!.id,
              request: req,
            ));
      } else {
        context.read<InventoryBloc>().add(AddItemRequested(req));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 700;

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
          isEdit ? 'Edit Item' : 'Create Item',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
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
                  _isLoadingDropdowns
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator(color: buttonColor1)),
                        )
                      : isWideScreen
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildLeftColumn()),
                                const SizedBox(width: 24),
                                Expanded(child: _buildRightColumn()),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLeftColumn(),
                                const SizedBox(height: 20),
                                _buildRightColumn(),
                              ],
                            ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Footer Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor1,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text(
                          isEdit ? 'SAVE CHANGES' : 'CREATE ITEM',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
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
      ),
    );
  }

  // Left Column Fields
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Name
        _buildFieldLabel('Item Name', isRequired: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor),
          decoration: _buildInputDecoration(hint: 'e.g. Catering Table, Chair'),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Item Name is required';
            }
            return null;
          },
        ),

        const SizedBox(height: 18),

        // Category Dropdown
        _buildFieldLabel('Category'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _selectedCategoryId,
              isExpanded: true,
              hint: Text('Select a Category...', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.grey.shade500)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              items: _categories.map((cat) {
                return DropdownMenuItem<int?>(
                  value: cat.id,
                  child: Text(cat.name, style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // SKU / Internal ID & Auto-generate Checkbox Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildFieldLabel('SKU / Internal ID')),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _autoGenerateSku,
                    activeColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      setState(() {
                        _autoGenerateSku = val ?? true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Auto-generate',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),

        // SKU TextField
        TextFormField(
          controller: _skuController,
          enabled: !_autoGenerateSku,
          style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor),
          decoration: _buildInputDecoration(
            hint: _autoGenerateSku ? 'Auto-generated on save' : 'e.g. SKU-10023',
            fillColor: _autoGenerateSku ? Colors.grey.shade100 : Colors.white,
          ),
        ),

        const SizedBox(height: 18),

        // Status Dropdown
        _buildFieldLabel('Status'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _status,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              items: const [
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Active', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text('Inactive', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Available for Dropdown
        _buildFieldLabel('Available for'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _availableFor,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              items: const [
                DropdownMenuItem(
                  value: 'rental',
                  child: Text('Rental only', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                ),
                DropdownMenuItem(
                  value: 'sale',
                  child: Text('Sale only', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                ),
                DropdownMenuItem(
                  value: 'both',
                  child: Text('Rental & sale', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _availableFor = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rental vs sale lists and which price blocks appear below.',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // Right Column Fields
  Widget _buildRightColumn() {
    final showRentalBlock = _availableFor == 'rental' || _availableFor == 'both';
    final showSaleBlock = _availableFor == 'sale' || _availableFor == 'both';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Unit of Measure
        _buildFieldLabel('Unit of Measure'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _selectedUnitId,
              isExpanded: true,
              hint: Text('Select a Unit...', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.grey.shade500)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              items: _units.map((unit) {
                return DropdownMenuItem<int?>(
                  value: unit.id,
                  child: Text('${unit.name} (${unit.abbreviation})', style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedUnitId = val),
            ),
          ),
        ),

        if (showRentalBlock) ...[
          const SizedBox(height: 18),
          // RENTAL PRICING Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RENTAL PRICING',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 14),

                // Rental price mode
                _buildFieldLabel('Rental price mode'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _pricingMode,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                      items: const [
                        DropdownMenuItem(
                          value: 'day',
                          child: Text('Per day', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                        ),
                        DropdownMenuItem(
                          value: 'flat',
                          child: Text('Flat price', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _pricingMode = val);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Rental rate
                _buildFieldLabel(_pricingMode == 'day' ? 'Rental rate (per day)' : 'Flat rental price'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                  decoration: _buildInputDecoration(
                    hint: '0.00',
                    prefixText: '₹ ',
                    fillColor: Colors.white,
                  ),
                  validator: (val) {
                    if (showRentalBlock && (val == null || val.trim().isEmpty)) {
                      return 'Rental price is required';
                    }
                    if (val != null && val.trim().isNotEmpty && double.tryParse(val.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Rental deposit
                _buildFieldLabel('Rental deposit'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _depositController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                  decoration: _buildInputDecoration(
                    hint: '0.00',
                    prefixText: '₹ ',
                    fillColor: Colors.white,
                  ),
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty && double.tryParse(val.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],

        if (showSaleBlock) ...[
          const SizedBox(height: 18),
          // DIRECT SALE (RETAIL) Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DIRECT SALE (RETAIL)',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF92400E),
                  ),
                ),
                if (_availableFor == 'both') ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Optional separate unit price for counter / invoice sales. If you leave this empty, the new sale screen will default from rental flat or per-day rate.',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Sale unit price
                _buildFieldLabel(
                  _availableFor == 'sale' ? 'Sale unit price' : 'Sale unit price (optional)',
                  isRequired: _availableFor == 'sale',
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _salePriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                  decoration: _buildInputDecoration(
                    hint: '0.00',
                    prefixText: '₹ ',
                    fillColor: Colors.white,
                  ),
                  validator: (val) {
                    if (_availableFor == 'sale' && (val == null || val.trim().isEmpty)) {
                      return 'Sale unit price is required';
                    }
                    if (val != null && val.trim().isNotEmpty && double.tryParse(val.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),

        // Loss / replacement value & Damage fee side-by-side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Loss / replacement value'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _replacementController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    decoration: _buildInputDecoration(
                      hint: '0.00',
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty && double.tryParse(val.trim()) == null) {
                        return 'Enter valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Damage fee (if applicable)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _damageFeeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                    decoration: _buildInputDecoration(
                      hint: '0.00',
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                    ),
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty && double.tryParse(val.trim()) == null) {
                        return 'Enter valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    if (!isRequired) {
      return Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.grey.shade800,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    String? prefixText,
    TextStyle? prefixStyle,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.grey.shade400),
      prefixText: prefixText,
      prefixStyle: prefixStyle ?? const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
      filled: fillColor != null,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
    );
  }
}
