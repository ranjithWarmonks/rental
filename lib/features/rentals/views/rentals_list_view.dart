import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_bottom_nav_bar.dart';
import 'package:rental/shared/widgets/app_dialog.dart';
import 'package:rental/shared/widgets/app_status_badge.dart';
import 'package:rental/shared/widgets/app_text.dart';
import '../controllers/rental_bloc.dart';
import '../controllers/rental_event.dart';
import '../controllers/rental_state.dart';
import '../models/rental_model.dart';
import 'add_rental_view.dart';
import 'rental_detail_view.dart';

class RentalsListView extends StatelessWidget {
  const RentalsListView({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<RentalBloc>();
      return const _RentalsListViewContent();
    } catch (_) {
      return BlocProvider(
        create: (context) => RentalBloc(),
        child: const _RentalsListViewContent(),
      );
    }
  }
}

class _RentalsListViewContent extends StatefulWidget {
  const _RentalsListViewContent();

  @override
  State<_RentalsListViewContent> createState() => _RentalsListViewContentState();
}

class _RentalsListViewContentState extends State<_RentalsListViewContent> {
  final _searchController = TextEditingController();
  final List<String> _filters = ['All', 'Active', 'Due Today', 'Overdue', 'Returned'];

  @override
  void initState() {
    super.initState();
    context.read<RentalBloc>().add(const FetchRentals());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldColor,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 10),
            const AppText.h3(
              'PropManager Pro',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: primaryColor, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Banner & Search/Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h1('Rentals', fontSize: 24),
                const SizedBox(height: 16),

                // Search Bar + Filter Tune Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14),
                          onChanged: (query) {
                            context.read<RentalBloc>().add(SearchRentals(query));
                          },
                          decoration: InputDecoration(
                            hintText: 'Search rentals...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune_rounded, color: primaryColor, size: 20),
                        onPressed: () {
                          AppDialog.show(
                            context: context,
                            title: 'Filter Rentals',
                            message: 'Advanced date range and category filters.',
                            type: AppDialogType.info,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal Filter Chips
          BlocBuilder<RentalBloc, RentalState>(
            buildWhen: (previous, current) => previous.currentFilter != current.currentFilter,
            builder: (context, state) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = state.currentFilter.toLowerCase() == f.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          f,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : primaryColor,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: buttonColor1, // #059669
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? buttonColor1 : Colors.grey.shade300,
                          ),
                        ),
                        showCheckmark: false,
                        onSelected: (_) {
                          context.read<RentalBloc>().add(FilterRentals(f));
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Rentals Cards List
          Expanded(
            child: BlocBuilder<RentalBloc, RentalState>(
              builder: (context, state) {
                if (state.status == RentalStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: buttonColor1),
                  );
                }

                if (state.rentals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        AppText(
                          'No rental records found',
                          color: Colors.grey.shade600,
                          style: AppTextStyle.h3,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: state.rentals.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = state.rentals[index];
                    return _buildRentalCard(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRentalView()),
          );
        },
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Rental',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildRentalCard(BuildContext context, RentalModel item) {
    final isOverdue = item.status.toUpperCase() == 'OVERDUE';

    return Container(
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<RentalBloc>().add(SelectRentalForDetails(item));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RentalDetailView(rental: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header ID & Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.id,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  Row(
                    children: [
                      AppStatusBadge.fromStatus(item.status),
                      if (item.paymentStatus == 'PARTIAL') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'PARTIAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4338CA),
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Customer Name
              AppText.h2(
                item.customerName,
                fontSize: 18,
              ),

              const SizedBox(height: 8),

              // Date Range or Overdue Alert Line
              if (isOverdue && item.overdueNotes != null) ...[
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      item.overdueNotes!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: Colors.grey.shade600, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${item.pickupDate} → ${item.returnDate}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 14),

              // Footer Total Amount & Arrow Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL AMOUNT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${item.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: buttonColor1, // #059669
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
