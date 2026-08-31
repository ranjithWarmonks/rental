import 'package:flutter/material.dart';
import 'package:rental/features/auth/models/auth_models.dart';
import 'package:rental/features/customers/models/customer_model.dart';
import 'package:rental/features/customers/services/customer_service.dart';
import 'package:rental/features/inventory/models/inventory_models.dart';
import 'package:rental/features/inventory/services/inventory_service.dart';
import 'package:rental/shared/services/location_service.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import 'package:rental/shared/utils/form_validators.dart';
import 'package:rental/shared/localization/app_language_controller.dart';
import '../models/rental_model.dart';
import 'rental_summary_view.dart';

class AddRentalView extends StatefulWidget {
  final RentalModel? existingRental; // If passed, edit mode is active

  const AddRentalView({super.key, this.existingRental});

  @override
  State<AddRentalView> createState() => _AddRentalViewState();
}

class _AddRentalViewState extends State<AddRentalView> {
  final _formKey = GlobalKey<FormState>();

  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _pickupDateController = TextEditingController();
  final _returnDateController = TextEditingController();

  List<RentedItemModel> _selectedItems = [];
  int? _selectedLocationId;
  List<StoreLocationModel> _locations = [];
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    if (widget.existingRental != null) {
      final r = widget.existingRental!;
      _customerNameController.text = r.customerName;
      _customerPhoneController.text = r.customerPhone;
      _pickupDateController.text = r.pickupDate;
      _returnDateController.text = r.returnDate;
      _selectedItems = List<RentedItemModel>.from(r.items);
      _selectedLocationId = r.locationId;
    } else {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      String formatDate(DateTime d) =>
          '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

      _pickupDateController.text = formatDate(now);
      _returnDateController.text = formatDate(tomorrow);
      _customerNameController.text = '';
      _customerPhoneController.text = '';
      _selectedItems = [];
    }
  }

  Future<void> _loadLocations() async {
    try {
      final locs = await LocationService().getLocations();
      if (mounted) {
        setState(() {
          _locations = locs;
          _isLoadingLocations = false;
          if (_selectedLocationId == null && locs.isNotEmpty) {
            final defaultLoc = locs.firstWhere((l) => l.isDefault, orElse: () => locs.first);
            _selectedLocationId = defaultLoc.id;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingLocations = false);
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _pickupDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  int get _rentalDays {
    try {
      final pText = _pickupDateController.text.trim();
      final rText = _returnDateController.text.trim();

      DateTime? parseDt(String str) {
        if (str.isEmpty) return null;
        final clean = str.split('T').first.split(' ').first;
        final parts = clean.split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          final p0 = int.tryParse(parts[0]);
          final p1 = int.tryParse(parts[1]);
          final p2 = int.tryParse(parts[2]);
          if (p0 != null && p1 != null && p2 != null) {
            if (parts[0].length == 4) {
              // YYYY-MM-DD
              return DateTime(p0, p1, p2);
            } else if (parts[2].length == 4) {
              // DD-MM-YYYY
              return DateTime(p2, p1, p0);
            }
          }
        }
        return DateTime.tryParse(clean);
      }

      final pDate = parseDt(pText);
      final rDate = parseDt(rText);

      if (pDate != null && rDate != null) {
        final diff = rDate.difference(pDate).inDays;
        return diff > 0 ? diff : 1;
      }
    } catch (_) {}
    return 1;
  }

  void _recalculateItemTotals() {
    final days = _rentalDays;
    setState(() {
      _selectedItems = _selectedItems.map((item) {
        final isFlat = item.pricingMode.toLowerCase() == 'flat';
        final newTotal = isFlat
            ? item.quantity * item.ratePerDay
            : item.quantity * item.ratePerDay * days;
        return item.copyWith(total: newTotal);
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final now = DateTime.now();
    DateTime initialDate = now;
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          initialDate = DateTime(year, month, day);
        }
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: buttonColor1,
              onPrimary: Colors.white,
              onSurface: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      setState(() {
        controller.text = formatted;
      });
      _recalculateItemTotals();
    }
  }

  int? _selectedCustomerId;

  void _openCustomerSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CustomerSelectionSheet(
        onCustomerSelected: (CustomerModel customer) {
          setState(() {
            _customerNameController.text = customer.name;
            _customerPhoneController.text = customer.phone;
            _selectedCustomerId = int.tryParse(customer.id.replaceAll(RegExp(r'[^0-9]'), ''));
          });
        },
      ),
    );
  }

  DateTime _parseDate(String str) {
    try {
      final parts = str.trim().split('-');
      if (parts.length == 3) {
        if (parts[0].length == 4) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        } else {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
    } catch (_) {}
    return DateTime.now();
  }

  void _openItemSelectionModal() {
    final pDate = _parseDate(_pickupDateController.text);
    final rDate = _parseDate(_returnDateController.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ItemSelectionSheet(
        rentalDays: _rentalDays,
        pickupDate: pDate,
        returnDate: rDate,
        onItemAdded: (RentedItemModel newItem) {
          setState(() {
            _selectedItems.add(newItem);
          });
        },
      ),
    );
  }

  void _proceedToSummary() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one item to rent.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final subtotal = _selectedItems.fold<double>(0, (sum, i) => sum + i.total);
      final discountAmount = 0.0;
      final tax = 0.0;
      final rentalTotal = subtotal;
      final deposit = 0.0;
      final totalDue = rentalTotal;

      final isEdit = widget.existingRental != null;

      final locMatches = _locations.where((l) => l.id == _selectedLocationId);
      final locName = locMatches.isNotEmpty ? locMatches.first.name : 'Main Store';

      final draftRental = RentalModel(
        id: isEdit ? widget.existingRental!.id : 'RNT-00${126 + DateTime.now().second}',
        customerId: _selectedCustomerId,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        locationId: _selectedLocationId ?? 1,
        locationName: locName,
        pickupDate: _pickupDateController.text.trim(),
        returnDate: _returnDateController.text.trim(),
        duration: '$_rentalDays ${_rentalDays == 1 ? 'Day' : 'Days'}',
        createdBy: 'Admin User',
        status: isEdit ? widget.existingRental!.status : 'ACTIVE',
        paymentStatus: 'PARTIAL',
        subtotal: subtotal,
        discount: discountAmount,
        tax: tax,
        totalAmount: rentalTotal,
        paidAmount: isEdit ? widget.existingRental!.paidAmount : totalDue,
        balanceDue: 0.0,
        securityDeposit: deposit,
        items: _selectedItems,
        payments: isEdit
            ? widget.existingRental!.payments
            : [
                PaymentLogModel(
                  id: 'pay_new',
                  amount: totalDue,
                  date: _pickupDateController.text.trim(),
                  mode: 'UPI',
                ),
              ],
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RentalSummaryView(
            rental: draftRental,
            isEditMode: isEdit,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingRental != null;
    final lang = AppLanguageController();

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText.h2(
          lang.text(isEdit ? 'edit_rental_header' : 'create_rental_header'),
          fontSize: 18,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: buttonColor1,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const AppText('Order & Customer Details', fontWeight: FontWeight.bold),
                      const Spacer(),
                      AppText.caption('Step 1 of 2', color: buttonColor1, fontWeight: FontWeight.w600),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Store / Godown Location Dropdown Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storefront_outlined, color: buttonColor1, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Store / Godown Location',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isLoadingLocations
                          ? const Center(child: CircularProgressIndicator(color: buttonColor1))
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  value: _selectedLocationId,
                                  isExpanded: true,
                                  hint: Text('Select Store / Godown...', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.grey.shade500)),
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: buttonColor1),
                                  items: _locations.map((loc) {
                                    return DropdownMenuItem<int?>(
                                      value: loc.id,
                                      child: Row(
                                        children: [
                                          Text(
                                            loc.name,
                                            style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
                                          ),
                                          if (loc.code != null && loc.code!.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '(${loc.code})',
                                              style: TextStyle(fontFamily: 'Urbanist', fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                          if (loc.isDefault) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: buttonColor1.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'DEFAULT',
                                                style: TextStyle(fontFamily: 'Urbanist', fontSize: 10, fontWeight: FontWeight.bold, color: buttonColor1),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedLocationId = val);
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Customer Info Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText.h3('Customer', fontSize: 16),
                          InkWell(
                            onTap: _openCustomerSelectionModal,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: buttonColor1.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_rounded, color: buttonColor1, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Select Customer',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: buttonColor1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Customer Name',
                        hintText: 'e.g. Royal Catering, Ranjith',
                        controller: _customerNameController,
                        isRequired: true,
                        prefixIcon: Icons.person_outline,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.people_alt_outlined, color: buttonColor1),
                          onPressed: _openCustomerSelectionModal,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Customer Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Phone Number',
                        hintText: 'e.g. +1 (555) 123-4567',
                        controller: _customerPhoneController,
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: (val) => FormValidators.validatePhone(val, isRequired: true),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Rental Dates Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.h3('Rental Duration ($_rentalDays ${_rentalDays == 1 ? 'Day' : 'Days'})', fontSize: 16),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Pickup Date',
                              hintText: 'DD-MM-YYYY',
                              controller: _pickupDateController,
                              isRequired: true,
                              readOnly: true,
                              onTap: () => _selectDate(context, _pickupDateController),
                              prefixIcon: Icons.calendar_today_outlined,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.event_outlined, color: buttonColor1, size: 18),
                                onPressed: () => _selectDate(context, _pickupDateController),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AppTextField(
                              label: 'Return Date',
                              hintText: 'DD-MM-YYYY',
                              controller: _returnDateController,
                              isRequired: true,
                              readOnly: true,
                              onTap: () => _selectDate(context, _returnDateController),
                              prefixIcon: Icons.event_available_outlined,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.event_outlined, color: buttonColor1, size: 18),
                                onPressed: () => _selectDate(context, _returnDateController),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Rented Items List & Add Button
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText.h3('Items Rented', fontSize: 16),
                          TextButton.icon(
                            onPressed: _openItemSelectionModal,
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: buttonColor1),
                            label: const Text(
                              'Add Item',
                              style: TextStyle(
                                color: buttonColor1,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _selectedItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No items added yet',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Urbanist',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedItems.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, idx) {
                                final item = _selectedItems[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: buttonColor1.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.inventory_2_outlined, size: 20, color: buttonColor1),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            AppText(item.name, fontWeight: FontWeight.bold),
                                            AppText.caption('${item.quantity} qty × ₹${item.ratePerDay.toStringAsFixed(0)} × $_rentalDays ${_rentalDays == 1 ? 'day' : 'days'}'),
                                          ],
                                        ),
                                      ),
                                      AppText('₹${item.total.toStringAsFixed(2)}', fontWeight: FontWeight.bold),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _selectedItems.removeAt(idx);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: AppButton(
            text: isEdit ? 'Save Changes & Continue' : 'Proceed to Summary',
            icon: Icons.arrow_forward_rounded,
            iconRight: true,
            onPressed: _proceedToSummary,
          ),
        ),
      ),
    );
  }
}

class _ItemSelectionSheet extends StatefulWidget {
  final int rentalDays;
  final DateTime pickupDate;
  final DateTime returnDate;
  final ValueChanged<RentedItemModel> onItemAdded;

  const _ItemSelectionSheet({
    required this.rentalDays,
    required this.pickupDate,
    required this.returnDate,
    required this.onItemAdded,
  });

  @override
  State<_ItemSelectionSheet> createState() => _ItemSelectionSheetState();
}

class _ItemSelectionSheetState extends State<_ItemSelectionSheet> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _searchController = TextEditingController();

  List<InventoryItemModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      final list = await _inventoryService.getItems(searchQuery: query);
      setState(() {
        _items = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _promptQuantityAndAdd(InventoryItemModel item) {
    final qtyController = TextEditingController(text: '1');
    int currentQty = 1;
    bool isCheckingStock = true;
    int availableStock = item.stockAtLocation ?? 0;
    String stockErrorMsg = '';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (isCheckingStock) {
            _inventoryService.checkItemAvailability(
              itemId: item.id,
              startDate: widget.pickupDate,
              endDate: widget.returnDate,
            ).then((res) {
              if (dialogCtx.mounted) {
                setDialogState(() {
                  isCheckingStock = false;
                  availableStock = res.availableQuantity;
                  if (availableStock <= 0) {
                    stockErrorMsg = 'Out of stock for selected dates!';
                  }
                });
              }
            }).catchError((_) {
              if (dialogCtx.mounted) {
                setDialogState(() {
                  isCheckingStock = false;
                });
              }
            });
          }

          final isQtyValid = !isCheckingStock && availableStock > 0 && currentQty <= availableStock;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Add "${item.name}"',
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate: ₹${item.pricePerDay.toStringAsFixed(0)} / day (${widget.rentalDays} ${widget.rentalDays == 1 ? 'day' : 'days'})',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    color: buttonColor1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Availability Status Badge
                if (isCheckingStock)
                  Row(
                    children: const [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: buttonColor1)),
                      SizedBox(width: 8),
                      Text('Checking availability...', style: TextStyle(fontFamily: 'Urbanist', fontSize: 12, color: Colors.grey)),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: availableStock > 0 ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: availableStock > 0 ? Colors.green.shade200 : Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          availableStock > 0 ? Icons.check_circle_outline : Icons.error_outline,
                          size: 16,
                          color: availableStock > 0 ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          availableStock > 0 ? 'Free Stock Available: $availableStock units' : 'Out of Stock for Selected Dates',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: availableStock > 0 ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                const Text(
                  'Quantity to Rent:',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: primaryColor),
                      onPressed: () {
                        if (currentQty > 1) {
                          setDialogState(() {
                            currentQty--;
                            qtyController.text = currentQty.toString();
                            if (currentQty <= availableStock) stockErrorMsg = '';
                          });
                        }
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed > 0) {
                            setDialogState(() {
                              currentQty = parsed;
                              if (currentQty > availableStock) {
                                stockErrorMsg = 'Only $availableStock units available!';
                              } else {
                                stockErrorMsg = '';
                              }
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: buttonColor1),
                      onPressed: () {
                        setDialogState(() {
                          currentQty++;
                          qtyController.text = currentQty.toString();
                          if (currentQty > availableStock) {
                            stockErrorMsg = 'Only $availableStock units available!';
                          } else {
                            stockErrorMsg = '';
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (stockErrorMsg.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    stockErrorMsg,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel', style: TextStyle(fontFamily: 'Urbanist', color: Colors.grey)),
              ),
              AppButton(
                text: 'Add to Order',
                height: 40,
                backgroundColor: isQtyValid ? buttonColor1 : Colors.grey.shade400,
                onPressed: isQtyValid
                    ? () {
                        final qty = int.tryParse(qtyController.text) ?? currentQty;
                        final isFlat = item.pricingMode.toLowerCase() == 'flat';
                        final calculatedTotal = isFlat
                            ? qty * item.pricePerDay
                            : qty * item.pricePerDay * widget.rentalDays;

                        final rentedItem = RentedItemModel(
                          id: item.id.toString(),
                          name: item.name,
                          quantity: qty,
                          ratePerDay: item.pricePerDay,
                          total: calculatedTotal,
                          pricingMode: item.pricingMode,
                        );

                        widget.onItemAdded(rentedItem);
                        Navigator.pop(dialogCtx); // Close quantity dialog
                        Navigator.pop(context); // Close bottom sheet
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Select Item from API', fontSize: 18, fontWeight: FontWeight.bold),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppTextField(
              label: 'Search Items',
              hintText: 'Search by item name or SKU...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
              onChanged: (val) {
                _fetchItems(val);
              },
            ),
          ),

          const SizedBox(height: 14),

          // Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: buttonColor1))
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          'No inventory items found',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _items.length,
                        separatorBuilder: (ctx, idx) => const Divider(),
                        itemBuilder: (ctx, idx) {
                          final item = _items[idx];
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              onTap: () => _promptQuantityAndAdd(item),
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: buttonColor1.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.inventory_2_rounded, color: buttonColor1, size: 22),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                'SKU: ${item.sku} • Stock: ${item.stockAtLocation ?? 0}',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${item.pricePerDay.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: buttonColor1,
                                    ),
                                  ),
                                  const Text(
                                    '/ day',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _CustomerSelectionSheet extends StatefulWidget {
  final ValueChanged<CustomerModel> onCustomerSelected;

  const _CustomerSelectionSheet({required this.onCustomerSelected});

  @override
  State<_CustomerSelectionSheet> createState() => _CustomerSelectionSheetState();
}

class _CustomerSelectionSheetState extends State<_CustomerSelectionSheet> {
  final _searchController = TextEditingController();
  final CustomerService _customerService = CustomerService();

  List<CustomerModel> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      final list = await _customerService.getCustomers(searchQuery: query);
      if (mounted) {
        setState(() {
          _customers = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openQuickAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _QuickAddCustomerDialog(
        onCustomerCreated: (newCust) {
          widget.onCustomerSelected(newCust);
          Navigator.pop(context); // Close customer selection sheet
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Customer',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openQuickAddDialog,
                  icon: const Icon(Icons.add_circle_outline, color: buttonColor1, size: 18),
                  label: const Text(
                    '+ Quick Add',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: buttonColor1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => _fetchCustomers(q),
              decoration: InputDecoration(
                hintText: 'Search by name, phone, email...',
                hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _fetchCustomers();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: buttonColor1),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: buttonColor1))
                : _customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No customers found',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _openQuickAddDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                              label: const Text(
                                '+ Quick Add Customer',
                                style: TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _customers.length,
                        separatorBuilder: (ctx, idx) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final c = _customers[idx];
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              onTap: () {
                                widget.onCustomerSelected(c);
                                Navigator.pop(context);
                              },
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: buttonColor1.withValues(alpha: 0.1),
                                child: Text(
                                  c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.bold,
                                    color: buttonColor1,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      c.customerType,
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
                              subtitle: Text(
                                'Phone: ${c.phone}${c.email.isNotEmpty ? ' • ${c.email}' : ''}',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddCustomerDialog extends StatefulWidget {
  final ValueChanged<CustomerModel> onCustomerCreated;

  const _QuickAddCustomerDialog({required this.onCustomerCreated});

  @override
  State<_QuickAddCustomerDialog> createState() => _QuickAddCustomerDialogState();
}

class _QuickAddCustomerDialogState extends State<_QuickAddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _customerType = 'Retail';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitQuickCustomer() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      try {
        final newCust = await CustomerService().quickAddCustomer(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          customerType: _customerType,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Customer ${newCust.name} added successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          widget.onCustomerCreated(newCust);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Add Customer',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Name',
                hintText: 'e.g. Quick Charlie',
                controller: _nameController,
                isRequired: true,
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Phone',
                hintText: 'e.g. +15550211',
                controller: _phoneController,
                isRequired: true,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (val) => FormValidators.validatePhone(val, isRequired: true),
              ),
              const SizedBox(height: 14),
              const Text(
                'Customer Type',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Retail', 'B2B', 'VIP'].map((type) {
                  final isSelected = _customerType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        type,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected ? Colors.white : buttonColor1,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: buttonColor1,
                      backgroundColor: buttonColor1.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _customerType = type);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuickCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor1,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Create Customer',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
