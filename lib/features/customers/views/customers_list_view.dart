import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_bottom_nav_bar.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../controllers/customer_bloc.dart';
import '../controllers/customer_event.dart';
import '../controllers/customer_state.dart';
import '../models/customer_model.dart';
import 'customer_detail_view.dart';

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<CustomerBloc>();
      return const _CustomersListViewContent();
    } catch (_) {
      return BlocProvider(
        create: (context) => CustomerBloc(),
        child: const _CustomersListViewContent(),
      );
    }
  }
}

class _CustomersListViewContent extends StatefulWidget {
  const _CustomersListViewContent();

  @override
  State<_CustomersListViewContent> createState() => _CustomersListViewContentState();
}

class _CustomersListViewContentState extends State<_CustomersListViewContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const FetchCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomerModal(BuildContext context) {
    final customerBloc = context.read<CustomerBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: customerBloc,
        child: const _AddCustomerModalSheet(),
      ),
    );
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
        title: const AppText.h1('Customers', fontSize: 24),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: primaryColor, size: 24),
            onPressed: () => _showAddCustomerModal(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  context.read<CustomerBloc>().add(SearchCustomers(query));
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or email...',
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

          const SizedBox(height: 12),

          // Overview Metrics Bar
          BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              final totalCount = state.customers.length;
              final activeCount = state.customers.where((c) => c.activeRentals > 0).length;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: buttonColor1.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.people_outline, color: buttonColor1, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.caption(
                                    'TOTAL CUSTOMERS',
                                    fontWeight: FontWeight.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppText.h3('$totalCount', fontSize: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.business_center_outlined, color: Color(0xFFD97706), size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.caption(
                                    'ACTIVE RENTALS',
                                    fontWeight: FontWeight.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppText.h3('$activeCount', fontSize: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Customer List
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: buttonColor1),
                  );
                }

                if (state.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        AppText(
                          'No customers found',
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
                  itemCount: state.customers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = state.customers[index];
                    return _buildCustomerCard(context, c);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerModal(context),
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'Add Customer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerModel c) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<CustomerBloc>().add(SelectCustomerForDetails(c));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailView(customer: c),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: buttonColor1.withValues(alpha: 0.1),
                child: Text(
                  c.name.substring(0, c.name.length > 1 ? 2 : 1).toUpperCase(),
                  style: const TextStyle(
                    color: buttonColor1,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText.h3(
                            c.name,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (c.activeRentals > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${c.activeRentals} ACTIVE',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46),
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        AppText.caption(c.phone, fontSize: 13),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        AppText.caption(c.city, fontSize: 13),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        AppText.caption('Total Spent: ', fontWeight: FontWeight.bold),
                        AppText(
                          '₹${c.totalSpent.toStringAsFixed(0)}',
                          fontWeight: FontWeight.bold,
                          color: buttonColor1,
                          fontSize: 13,
                        ),
                        const SizedBox(width: 14),
                        AppText.caption('${c.totalRentals} Rentals'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: primaryColor,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCustomerModalSheet extends StatefulWidget {
  const _AddCustomerModalSheet();

  @override
  State<_AddCustomerModalSheet> createState() => _AddCustomerModalSheetState();
}

class _AddCustomerModalSheetState extends State<_AddCustomerModalSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _idProofNumberController = TextEditingController();
  final _notesController = TextEditingController();

  String _customerType = 'Retail';
  String _idProofType = 'Driver License';

  final List<String> _idProofTypes = [
    'Driver License',
    'Aadhaar Card',
    'Passport',
    'Voter ID',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _idProofNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState?.validate() ?? false) {
      final newCust = CustomerModel(
        id: 'CUST-00${DateTime.now().second}',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        city: 'City',
        customerType: _customerType,
        idProofType: _idProofType,
        idProofNumber: _idProofNumberController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        totalRentals: 0,
        activeRentals: 0,
        totalSpent: 0.0,
        joinedDate: '21 Aug 2026',
      );

      context.read<CustomerBloc>().add(AddCustomerSubmitted(newCust));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Create New Customer', fontSize: 18, fontWeight: FontWeight.bold),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Name (Required)
                    AppTextField(
                      label: 'Customer Name',
                      hintText: 'e.g. Robert Brown',
                      controller: _nameController,
                      isRequired: true,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Customer Name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone Number (Required)
                    AppTextField(
                      label: 'Phone Number',
                      hintText: 'e.g. +15550188',
                      controller: _phoneController,
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Phone Number is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Customer Type Selector (Regular, VIP, Corporate)
                    const AppText.label(
                      'Customer Type',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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

                    const SizedBox(height: 16),

                    // ID Proof Type (Optional Dropdown)
                    const Text(
                      'ID Proof Type',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _idProofType,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge_outlined, color: Colors.grey, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: buttonColor1, width: 1.5),
                        ),
                      ),
                      items: _idProofTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _idProofType = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // ID Proof Number (Optional)
                    AppTextField(
                      label: 'ID Proof Number',
                      hintText: 'e.g. DL-998812',
                      controller: _idProofNumberController,
                      isOptional: true,
                      prefixIcon: Icons.card_membership_outlined,
                    ),

                    const SizedBox(height: 16),

                    // Email Address (Optional)
                    AppTextField(
                      label: 'Email Address',
                      hintText: 'robert@example.com',
                      controller: _emailController,
                      isOptional: true,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 16),

                    // Address (Optional)
                    AppTextField(
                      label: 'Address',
                      hintText: '789 Broadway St',
                      controller: _addressController,
                      isOptional: true,
                      maxLines: 2,
                      prefixIcon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 16),

                    // Notes (Optional)
                    AppTextField(
                      label: 'Notes',
                      hintText: 'Premium customer...',
                      controller: _notesController,
                      isOptional: true,
                      maxLines: 2,
                      prefixIcon: Icons.note_alt_outlined,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Sticky Bottom Navigation Bar
          Container(
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
                text: 'Save Customer',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _saveCustomer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
