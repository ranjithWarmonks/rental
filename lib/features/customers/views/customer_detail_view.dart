import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_dialog.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../controllers/customer_bloc.dart';
import '../controllers/customer_event.dart';
import '../controllers/customer_state.dart';
import '../models/customer_model.dart';

class CustomerDetailView extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailView({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<CustomerBloc>();
      return _CustomerDetailViewContent(customer: customer);
    } catch (_) {
      return BlocProvider(
        create: (context) => CustomerBloc(),
        child: _CustomerDetailViewContent(customer: customer),
      );
    }
  }
}

class _CustomerDetailViewContent extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerDetailViewContent({required this.customer});

  void _showEditCustomerModal(BuildContext context, CustomerModel c) {
    final nameCtrl = TextEditingController(text: c.name);
    final phoneCtrl = TextEditingController(text: c.phone);
    final emailCtrl = TextEditingController(text: c.email);
    final addressCtrl = TextEditingController(text: c.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h2('Edit Customer Details', fontSize: 20),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Customer Name',
              hintText: 'Enter customer name',
              controller: nameCtrl,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Phone Number',
              hintText: 'Enter phone number',
              controller: phoneCtrl,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Email Address',
              hintText: 'Enter email address',
              controller: emailCtrl,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Address',
              hintText: 'Enter address',
              controller: addressCtrl,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Save Changes',
              onPressed: () {
                final updated = c.copyWith(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                );
                context.read<CustomerBloc>().add(UpdateCustomerSubmitted(updated));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        final c = state.selectedCustomer?.id == customer.id
            ? state.selectedCustomer!
            : customer;

        return Scaffold(
          backgroundColor: scaffoldColor,
          appBar: AppBar(
            backgroundColor: scaffoldColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: AppText.h2(c.name, fontSize: 20),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: primaryColor),
                onPressed: () => _showEditCustomerModal(context, c),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Main Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: buttonColor1.withValues(alpha: 0.1),
                          child: Text(
                            c.name.substring(0, c.name.length > 1 ? 2 : 1).toUpperCase(),
                            style: const TextStyle(
                              color: buttonColor1,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                              fontSize: 26,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppText.h1(c.name, fontSize: 22, textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        AppText.caption('Customer since ${c.joinedDate}', fontSize: 13),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 16),

                        // Quick Contact Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildContactBtn(
                              icon: Icons.phone,
                              label: 'Call',
                              color: buttonColor1,
                              onTap: () {
                                AppDialog.show(context: context, title: 'Call Customer', message: 'Dialing ${c.phone}...');
                              },
                            ),
                            _buildContactBtn(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: 'WhatsApp',
                              color: const Color(0xFF25D366),
                              onTap: () {
                                AppDialog.show(context: context, title: 'WhatsApp', message: 'Opening chat with ${c.phone}...');
                              },
                            ),
                            _buildContactBtn(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              color: const Color(0xFF3B82F6),
                              onTap: () {
                                AppDialog.show(context: context, title: 'Email Customer', message: 'Opening mail to ${c.email}...');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Financial Metrics Overview
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'TOTAL SPENT',
                          value: '₹${c.totalSpent.toStringAsFixed(0)}',
                          valueColor: buttonColor1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'TOTAL RENTALS',
                          value: '${c.totalRentals}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'ACTIVE',
                          value: '${c.activeRentals}',
                          valueColor: c.activeRentals > 0 ? const Color(0xFFD97706) : primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Detailed Contact Info Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.h3('Contact & Address', fontSize: 16),
                        const SizedBox(height: 14),
                        _buildInfoRow(Icons.phone_outlined, 'Phone', c.phone),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.email_outlined, 'Email', c.email),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.location_on_outlined, 'Address', '${c.address}, ${c.city}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rental History Section
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.h3('Rental History', fontSize: 16),
                        const SizedBox(height: 14),
                        _buildRentalHistoryRow(
                          id: 'RNT-00125',
                          dates: '10 Aug → 12 Aug',
                          amount: '₹4,850',
                          status: 'ACTIVE',
                        ),
                        const Divider(height: 20),
                        _buildRentalHistoryRow(
                          id: 'RNT-00098',
                          dates: '01 Jun → 04 Jun',
                          amount: '₹12,400',
                          status: 'RETURNED',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Urbanist',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({required String label, required String value, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.caption(label, fontWeight: FontWeight.bold, fontSize: 10),
          const SizedBox(height: 4),
          AppText.h2(value, fontSize: 18, color: valueColor ?? primaryColor),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.caption(label, fontWeight: FontWeight.bold),
              const SizedBox(height: 2),
              AppText(value, fontWeight: FontWeight.w600, fontSize: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRentalHistoryRow({
    required String id,
    required String dates,
    required String amount,
    required String status,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h3(id, fontSize: 14),
            const SizedBox(height: 2),
            AppText.caption(dates, fontSize: 12),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppText(amount, fontWeight: FontWeight.bold, color: buttonColor1, fontSize: 14),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: status == 'ACTIVE' ? buttonColor1 : Colors.grey,
                fontFamily: 'Urbanist',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
