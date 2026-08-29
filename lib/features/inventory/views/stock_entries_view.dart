import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../models/stock_entry_model.dart';
import '../services/stock_entry_service.dart';
import 'add_stock_entry_view.dart';

class StockEntriesView extends StatefulWidget {
  const StockEntriesView({super.key});

  @override
  State<StockEntriesView> createState() => _StockEntriesViewState();
}

class _StockEntriesViewState extends State<StockEntriesView> {
  final StockEntryService _stockEntryService = StockEntryService();
  final TextEditingController _searchController = TextEditingController();

  List<StockEntryModel> _entries = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStockEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStockEntries([String searchQuery = '']) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final list = await _stockEntryService.getStockEntries(searchQuery: searchQuery);
      if (mounted) {
        setState(() {
          _entries = list;
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

  void _openAddStockEntryScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddStockEntryView()),
    );
    if (result == true) {
      _loadStockEntries(_searchController.text.trim());
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
          'Stock Entries',
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
            onPressed: () => _loadStockEntries(_searchController.text.trim()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddStockEntryScreen,
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Stock Entries',
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
                label: 'Search Stock Entries',
                hintText: 'Search by item name or note...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => _loadStockEntries(val),
              ),
            ),

            // Content
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
                                  onPressed: () => _loadStockEntries(),
                                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                  label: const Text('Try Again', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor1),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _entries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.input_rounded, size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No stock entries found',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap "+ Add Stock Entries" to record inward inventory stock',
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
                              onRefresh: () => _loadStockEntries(_searchController.text.trim()),
                              color: buttonColor1,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: _entries.length,
                                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                                itemBuilder: (ctx, idx) {
                                  final entry = _entries[idx];

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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Row 1: Item Name & Type Badge
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entry.itemName,
                                                  style: const TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.green.shade100),
                                                ),
                                                child: Text(
                                                  entry.type,
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    color: Colors.green.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 6),

                                          // Quantity info
                                          Row(
                                            children: [
                                              Text(
                                                'Inward Qty: +${entry.quantity}',
                                                style: const TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),

                                          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Note: ${entry.notes}',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ],

                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade400),
                                              const SizedBox(width: 4),
                                              Text(
                                                entry.createdBy,
                                                style: TextStyle(fontFamily: 'Urbanist', fontSize: 12, color: Colors.grey.shade500),
                                              ),
                                              const Spacer(),
                                              if (entry.createdAt.isNotEmpty)
                                                Text(
                                                  entry.createdAt,
                                                  style: TextStyle(fontFamily: 'Urbanist', fontSize: 12, color: Colors.grey.shade500),
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
