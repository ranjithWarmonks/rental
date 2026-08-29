import 'package:flutter/material.dart';
import 'package:rental/features/inventory/models/inventory_models.dart';
import 'package:rental/features/inventory/models/item_availability_model.dart';
import 'package:rental/features/inventory/services/inventory_service.dart';
import 'package:rental/features/rentals/views/add_rental_view.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_text.dart';

class ItemAvailabilityView extends StatefulWidget {
  final int? initialItemId;

  const ItemAvailabilityView({
    super.key,
    this.initialItemId,
  });

  @override
  State<ItemAvailabilityView> createState() => _ItemAvailabilityViewState();
}

class _ItemAvailabilityViewState extends State<ItemAvailabilityView> {
  final InventoryService _inventoryService = InventoryService();

  List<InventoryItemModel> _items = [];
  InventoryItemModel? _selectedItem;

  DateTime? _rentalDate = DateTime.now();
  DateTime? _returnDate;

  bool _isChecking = false;
  ItemAvailabilityResult? _availabilityResult;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final list = await _inventoryService.getItems();
      if (mounted) {
        setState(() {
          _items = list;
          if (widget.initialItemId != null) {
            _selectedItem = _items.firstWhere(
              (i) => i.id == widget.initialItemId,
              orElse: () => _items.first,
            );
          } else if (_items.isNotEmpty) {
            _selectedItem = _items.first;
          }
        });
        _checkAvailabilityIfReady();
      }
    } catch (_) {}
  }

  String _formatDateDisplay(DateTime? date) {
    if (date == null) return 'dd-mm-yyyy';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$d-$m-$y';
  }

  Future<void> _selectRentalDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _rentalDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    setState(() {
      _rentalDate = pickedDate;
    });

    _checkAvailabilityIfReady();
  }

  Future<void> _selectReturnDate() async {
    final initial = _returnDate ?? (_rentalDate ?? DateTime.now()).add(const Duration(days: 1));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _rentalDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    setState(() {
      _returnDate = pickedDate;
    });

    _checkAvailabilityIfReady();
  }

  Future<void> _checkAvailabilityIfReady() async {
    final start = _rentalDate;
    final end = _returnDate;

    if (_selectedItem == null || start == null || end == null) {
      setState(() => _availabilityResult = null);
      return;
    }

    setState(() => _isChecking = true);
    try {
      final res = await _inventoryService.checkItemAvailability(
        itemId: _selectedItem!.id,
        startDate: start,
        endDate: end,
      );
      if (mounted) {
        setState(() {
          _availabilityResult = res;
          _isChecking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showItemSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText.h2('Select Item', fontSize: 18),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isSelected = item.id == _selectedItem?.id;
                    return ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? buttonColor1 : primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'SKU: ${item.sku} • In Stock: ${item.stockAtLocation}',
                        style: const TextStyle(fontFamily: 'Urbanist', fontSize: 12),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: buttonColor1)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedItem = item;
                        });
                        _checkAvailabilityIfReady();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText.h1('Availability Checker', fontSize: 22),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Field Design Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ITEM Selector Field
                    const AppText.caption(
                      'ITEM',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showItemSelectionBottomSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedItem?.name ?? 'Select item...',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 15,
                                  color: _selectedItem != null
                                      ? primaryColor
                                      : Colors.grey.shade400,
                                  fontWeight: _selectedItem != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Date & Time Row
                    Row(
                      children: [
                        // RENTAL DATE Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText.caption(
                                'RENTAL DATE',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectRentalDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _formatDateDisplay(_rentalDate),
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 13,
                                            fontWeight: _rentalDate != null
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: _rentalDate != null
                                                ? primaryColor
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 18,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // EXPECTED RETURN DATE Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText.caption(
                                'EXPECTED RETURN DATE',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectReturnDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _formatDateDisplay(_returnDate),
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 13,
                                            fontWeight: _returnDate != null
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: _returnDate != null
                                                ? primaryColor
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 18,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Status / Helper Text
                    if (_selectedItem == null || _rentalDate == null || _returnDate == null)
                      Text(
                        'Select an item and both dates to check availability.',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Loading Spinner
              if (_isChecking)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: buttonColor1),
                  ),
                ),

              // Availability Result Card
              if (!_isChecking && _availabilityResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _availabilityResult!.isAvailable
                          ? buttonColor1.withValues(alpha: 0.3)
                          : const Color(0xFFFCA5A5),
                    ),
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
                      // Status Banner Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _availabilityResult!.isAvailable
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _availabilityResult!.isAvailable
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: _availabilityResult!.isAvailable
                                  ? const Color(0xFF047857)
                                  : const Color(0xFFDC2626),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _availabilityResult!.isAvailable
                                    ? '${_availabilityResult!.availableQuantity} Units Available for Rent'
                                    : 'Item Out of Stock / Fully Booked',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _availabilityResult!.isAvailable
                                      ? const Color(0xFF047857)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Metrics Details Row
                      Row(
                        children: [
                          _buildMetricTile(
                            'TOTAL QTY',
                            '${_availabilityResult!.totalStock}',
                            Icons.inventory_2_outlined,
                          ),
                          const SizedBox(width: 12),
                          _buildMetricTile(
                            'BOOKED QTY',
                            '${_availabilityResult!.rentedCount}',
                            Icons.bookmark_outline_rounded,
                          ),
                          const SizedBox(width: 12),
                          _buildMetricTile(
                            'FREE QTY',
                            '${_availabilityResult!.availableQuantity}',
                            Icons.check_box_outlined,
                            isHighlight: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Action Button
                      AppButton(
                        text: 'Create Rental with Item',
                        backgroundColor: buttonColor1,
                        onPressed: _availabilityResult!.isAvailable
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddRentalView(),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlight ? buttonColor1.withValues(alpha: 0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlight ? buttonColor1.withValues(alpha: 0.3) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isHighlight ? buttonColor1 : Colors.grey.shade600,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isHighlight ? buttonColor1 : primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
