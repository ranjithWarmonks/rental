import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_dialog.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../controllers/inventory_bloc.dart';
import '../controllers/inventory_event.dart';
import '../controllers/inventory_state.dart';
import '../models/inventory_models.dart';
import 'add_edit_item_view.dart';
import 'item_availability_view.dart';

class ItemsListView extends StatefulWidget {
  const ItemsListView({super.key});

  @override
  State<ItemsListView> createState() => _ItemsListViewState();
}

class _ItemsListViewState extends State<ItemsListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(const FetchItems());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddModal() {
    final bloc = context.read<InventoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const AddEditItemView(),
        ),
      ),
    );
  }

  void _openEditModal(InventoryItemModel item) {
    final bloc = context.read<InventoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AddEditItemView(itemToEdit: item),
        ),
      ),
    );
  }

  void _confirmDelete(InventoryItemModel item) {
    AppDialog.show(
      context: context,
      title: 'Delete Item?',
      message: 'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
      type: AppDialogType.error,
      primaryButtonText: 'Delete',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () {
        Navigator.pop(context);
        context.read<InventoryBloc>().add(DeleteItemRequested(item.id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Inventory Items',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            tooltip: 'Availability Checker',
            icon: const Icon(Icons.event_available_rounded, color: primaryColor, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ItemAvailabilityView(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Add Item',
            icon: const Icon(Icons.add_circle_outline_rounded, color: buttonColor1, size: 26),
            onPressed: _openAddModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: buttonColor1,
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search & Filter Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Search Items',
                      hintText: 'Search items by name, SKU...',
                      controller: _searchController,
                      prefixIcon: Icons.search_rounded,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context.read<InventoryBloc>().add(const SearchItems(''));
                              },
                            )
                          : null,
                      onChanged: (query) {
                        context.read<InventoryBloc>().add(SearchItems(query));
                      },
                    ),
                  ],
                ),
              ),

              // Items List Body
              Expanded(
                child: state.status == InventoryStatus.loading && state.items.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: buttonColor1))
                    : state.items.isEmpty
                        ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const AppText('No inventory items found', fontSize: 16, fontWeight: FontWeight.w600),
                                const SizedBox(height: 16),
                                AppButton(
                                  text: 'Add First Item',
                                  icon: Icons.add_rounded,
                                  onPressed: _openAddModal,
                                ),
                              ],
                            ),
                          ))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.items.length,
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return _buildItemCard(item);
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddModal,
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
      ),
    );
  }

  Widget _buildItemCard(InventoryItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Icon Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: buttonColor1.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: buttonColor1,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & SKU
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        item.name,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.sku,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Rate in Rupees (Must) & Deposit
                Row(
                  children: [
                    AppText(
                      '₹${item.pricePerDay.toStringAsFixed(0)}',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: buttonColor1,
                    ),
                    Text(
                      ' / day',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    if (item.depositAmount > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: buttonColor1.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Deposit: ₹${item.depositAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: buttonColor1,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Stock Badge & Action Buttons (Edit / Delete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${item.stockAtLocation ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ],
                    ),

                    // Actions Row (Edit & Delete)
                    Row(
                      children: [
                        // Edit Button
                        InkWell(
                          onTap: () => _openEditModal(item),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: buttonColor1.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: buttonColor1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Delete Button
                        InkWell(
                          onTap: () => _confirmDelete(item),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
