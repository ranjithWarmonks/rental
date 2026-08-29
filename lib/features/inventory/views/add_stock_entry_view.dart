import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/services/location_service.dart';
import 'package:rental/features/auth/models/auth_models.dart';
import '../models/inventory_models.dart';
import '../models/stock_entry_model.dart';
import '../services/inventory_service.dart';
import '../services/stock_entry_service.dart';

class AddStockEntryView extends StatefulWidget {
  const AddStockEntryView({super.key});

  @override
  State<AddStockEntryView> createState() => _AddStockEntryViewState();
}

class _AddStockEntryViewState extends State<AddStockEntryView> {
  final InventoryService _inventoryService = InventoryService();
  final StockEntryService _stockEntryService = StockEntryService();
  final LocationService _locationService = LocationService();

  List<InventoryItemModel> _inventoryItems = [];
  List<StoreLocationModel> _locations = [];
  int? _selectedLocationId;
  bool _isLoadingItems = true;
  bool _isSubmitting = false;

  final List<StockEntryRow> _rows = [
    StockEntryRow(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _inventoryService.getItems(),
        _locationService.getLocations(),
      ]);
      if (mounted) {
        final items = results[0] as List<InventoryItemModel>;
        final locs = results[1] as List<StoreLocationModel>;
        setState(() {
          _inventoryItems = items;
          _locations = locs;
          if (locs.isNotEmpty) {
            _selectedLocationId = locs.firstWhere((l) => l.isDefault, orElse: () => locs.first).id;
          }
          _isLoadingItems = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingItems = false);
      }
    }
  }

  void _addRow() {
    setState(() {
      _rows.add(StockEntryRow(locationId: _selectedLocationId ?? 1));
    });
  }

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows.removeAt(index);
    });
  }

  int get _filledRowsCount => _rows.where((r) => r.isFilled).length;

  Future<void> _saveAllEntries() async {
    final validRows = _rows.where((r) => r.itemId != null && r.quantity > 0).toList();

    if (validRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an item and enter a quantity for at least 1 row.', style: TextStyle(fontFamily: 'Urbanist')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _stockEntryService.submitStockEntries(
        validRows,
        locationId: _selectedLocationId ?? 1,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock entries saved successfully!', style: TextStyle(fontFamily: 'Urbanist')),
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
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [

            const Text(
              'Add Stock Entries',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '$_filledRowsCount of ${_rows.length} rows filled',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _saveAllEntries,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor1,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 20, color: Colors.white),
                label: const Text(
                  'Save All Entries',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Entry Card Container
              Container(
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle Note
                    Text(
                      'Fill in the rows below. Leave empty rows blank — they will be ignored. Click + Add Row to add more lines.',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),

                    if (_locations.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 18, color: primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Store Location:',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedLocationId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.grey),
                                  items: _locations.map((loc) {
                                    return DropdownMenuItem<int>(
                                      value: loc.id,
                                      child: Text(
                                        '${loc.name}${loc.code != null ? " (${loc.code})" : ""}',
                                        style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedLocationId = val;
                                        for (var r in _rows) {
                                          r.locationId = val;
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Table Layout Header Row (Desktop only)
                    if (MediaQuery.of(context).size.width > 600)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 24, child: Text('#', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                            SizedBox(width: 8),
                            Expanded(flex: 3, child: Text('ITEM *', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                            SizedBox(width: 8),
                            Expanded(flex: 3, child: Text('TYPE *', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                            SizedBox(width: 8),
                            Expanded(flex: 2, child: Text('QUANTITY *', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                            SizedBox(width: 8),
                            Expanded(flex: 3, child: Text('NOTES', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                            SizedBox(width: 24),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Entry Rows ListView
                    _isLoadingItems
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator(color: buttonColor1)),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _rows.length,
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                            itemBuilder: (ctx, idx) {
                              final row = _rows[idx];
                              return _buildEntryRow(row, idx);
                            },
                          ),

                    const SizedBox(height: 16),

                    // Add Row Button
                    OutlinedButton.icon(
                      onPressed: _addRow,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: Colors.grey.shade300, style: BorderStyle.solid),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        '+ Add Row',
                        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryRow(StockEntryRow row, int index) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    if (isMobile) {
      return _buildMobileEntryCard(row, index);
    }
    return _buildDesktopEntryRow(row, index);
  }

  Widget _buildMobileEntryCard(StockEntryRow row, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Row Number, Type Dropdown, Delete Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '# ${index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: row.type,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
                      items: const [
                        DropdownMenuItem(
                          value: 'opening_stock',
                          child: Text('Opening Stock', style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: primaryColor)),
                        ),
                        DropdownMenuItem(
                          value: 'purchase',
                          child: Text('Purchase', style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: primaryColor)),
                        ),
                        DropdownMenuItem(
                          value: 'inward',
                          child: Text('Inward', style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: primaryColor)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            row.type = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _removeRow(index),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: _rows.length > 1 ? Colors.grey.shade600 : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ITEM * Selection Dropdown
          const Text(
            'ITEM *',
            style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: row.itemId,
                isExpanded: true,
                hint: Text('Select item...', style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: Colors.grey.shade500)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
                items: _inventoryItems.map((item) {
                  return DropdownMenuItem<int?>(
                    value: item.id,
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, color: primaryColor),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    row.itemId = val;
                    final matches = _inventoryItems.where((i) => i.id == val);
                    if (matches.isNotEmpty) {
                      row.itemName = matches.first.name;
                    }
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quantity & Notes side-by-side
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUANTITY *',
                      style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: buttonColor1)),
                      ),
                      onChanged: (val) {
                        row.quantity = double.tryParse(val.trim()) ?? 0.0;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOTES',
                      style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Optional note...',
                        hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: buttonColor1)),
                      ),
                      onChanged: (val) {
                        row.notes = val;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopEntryRow(StockEntryRow row, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // # Index
        SizedBox(
          width: 24,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ITEM * Dropdown
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: row.itemId,
                isExpanded: true,
                hint: Text('Select item...', style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: Colors.grey.shade500)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
                items: _inventoryItems.map((item) {
                  return DropdownMenuItem<int?>(
                    value: item.id,
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: primaryColor),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    row.itemId = val;
                    final matches = _inventoryItems.where((i) => i.id == val);
                    if (matches.isNotEmpty) {
                      row.itemName = matches.first.name;
                    }
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // TYPE * Dropdown
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: row.type,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey),
                items: const [
                  DropdownMenuItem(
                    value: 'opening_stock',
                    child: Text('Opening Stock', style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: primaryColor)),
                  ),
                  DropdownMenuItem(
                    value: 'purchase',
                    child: Text('Purchase', style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: primaryColor)),
                  ),
                  DropdownMenuItem(
                    value: 'inward',
                    child: Text('Inward', style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: primaryColor)),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      row.type = val;
                    });
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // QUANTITY * Field
        Expanded(
          flex: 2,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontFamily: 'Urbanist', fontSize: 13, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: buttonColor1)),
            ),
            onChanged: (val) {
              row.quantity = double.tryParse(val.trim()) ?? 0.0;
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 8),

        // NOTES Field
        Expanded(
          flex: 3,
          child: TextField(
            style: const TextStyle(fontFamily: 'Urbanist', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Optional note...',
              hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: buttonColor1)),
            ),
            onChanged: (val) {
              row.notes = val;
            },
          ),
        ),
        const SizedBox(width: 6),

        // Delete Action (x)
        InkWell(
          onTap: () => _removeRow(index),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: _rows.length > 1 ? Colors.grey.shade400 : Colors.grey.shade200,
            ),
          ),
        ),
      ],
    );
  }
}
