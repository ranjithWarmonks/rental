import 'package:flutter/material.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../models/stock_adjustment_model.dart';
import '../services/stock_adjustment_service.dart';
import 'bulk_stock_adjustment_view.dart';

class StockAdjustmentsView extends StatefulWidget {
  const StockAdjustmentsView({super.key});

  @override
  State<StockAdjustmentsView> createState() => _StockAdjustmentsViewState();
}

class _StockAdjustmentsViewState extends State<StockAdjustmentsView> {
  final StockAdjustmentService _stockAdjustmentService = StockAdjustmentService();
  final TextEditingController _searchController = TextEditingController();

  List<StockAdjustmentModel> _adjustments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAdjustments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdjustments([String searchQuery = '']) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final list = await _stockAdjustmentService.getStockAdjustments(searchQuery: searchQuery);
      if (mounted) {
        setState(() {
          _adjustments = list;
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

  void _openBulkAdjustmentScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const BulkStockAdjustmentView()),
    );
    if (result == true) {
      _loadAdjustments(_searchController.text.trim());
    }
  }

  Color _getTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('add')) return Colors.blue.shade700;
    if (t.contains('deduct') || t.contains('sub')) return Colors.red.shade700;
    return Colors.purple.shade700;
  }

  Color _getTypeBgColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('add')) return Colors.blue.shade50;
    if (t.contains('deduct') || t.contains('sub')) return Colors.red.shade50;
    return Colors.purple.shade50;
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
          'Stock Adjustments',
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
            onPressed: () => _loadAdjustments(_searchController.text.trim()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBulkAdjustmentScreen,
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Bulk Adjustment',
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
                label: 'Search Adjustments',
                hintText: 'Search by item name or reason...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => _loadAdjustments(val),
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
                                  onPressed: () => _loadAdjustments(),
                                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                  label: const Text('Try Again', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white)),
                                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor1),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _adjustments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.tune_rounded, size: 56, color: Colors.grey.shade400),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No stock adjustments found',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap "+ Bulk Adjustment" to adjust inventory stock levels',
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
                              onRefresh: () => _loadAdjustments(_searchController.text.trim()),
                              color: buttonColor1,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: _adjustments.length,
                                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                                itemBuilder: (ctx, idx) {
                                  final adj = _adjustments[idx];
                                  final typeColor = _getTypeColor(adj.type);
                                  final typeBg = _getTypeBgColor(adj.type);

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
                                                  adj.itemName,
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
                                                  color: typeBg,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  adj.type,
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                    color: typeColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 6),

                                          // Quantity & Stock info
                                          Row(
                                            children: [
                                              Text(
                                                'Qty: ${adj.quantity > 0 ? (adj.type.contains('ADD') ? '+${adj.quantity}' : '${adj.quantity}') : '${adj.quantity}'}',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: typeColor,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Stock: ${adj.previousStock} ➔ ${adj.newStock}',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),

                                          if (adj.notes != null && adj.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Reason: ${adj.notes}',
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
                                                adj.createdBy,
                                                style: TextStyle(fontFamily: 'Urbanist', fontSize: 12, color: Colors.grey.shade500),
                                              ),
                                              const Spacer(),
                                              if (adj.createdAt.isNotEmpty)
                                                Text(
                                                  adj.createdAt,
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
