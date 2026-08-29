import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_dialog.dart';
import 'package:rental/shared/widgets/app_status_badge.dart';
import 'package:rental/shared/widgets/app_text.dart';
import '../controllers/rental_bloc.dart';
import '../controllers/rental_event.dart';
import '../controllers/rental_state.dart';
import '../models/rental_model.dart';
import 'add_rental_view.dart';
import '../services/rental_service.dart';
import 'package:rental/shared/utils/invoice_pdf_generator.dart';

class RentalDetailView extends StatelessWidget {
  final RentalModel rental;

  const RentalDetailView({
    super.key,
    required this.rental,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<RentalBloc>();
      return _RentalDetailViewContent(rental: rental);
    } catch (_) {
      return BlocProvider(
        create: (context) => RentalBloc(),
        child: _RentalDetailViewContent(rental: rental),
      );
    }
  }
}

class _RentalDetailViewContent extends StatefulWidget {
  final RentalModel rental;

  const _RentalDetailViewContent({required this.rental});

  @override
  State<_RentalDetailViewContent> createState() => _RentalDetailViewContentState();
}

class _RentalDetailViewContentState extends State<_RentalDetailViewContent> {
  RentalModel? _fetchedRental;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadFullDetails();
  }

  Future<void> _loadFullDetails() async {
    setState(() => _isLoadingDetails = true);
    try {
      final targetId = widget.rental.dbId ?? widget.rental.id;
      final detailed = await RentalService().getRentalDetails(targetId);
      if (mounted) {
        setState(() {
          _fetchedRental = detailed;
          _isLoadingDetails = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalBloc, RentalState>(
      builder: (context, state) {
        final currentRental = _fetchedRental ??
            (state.selectedRental?.id == widget.rental.id
                ? state.selectedRental!
                : widget.rental);

        return Scaffold(
          backgroundColor: scaffoldColor,
          appBar: AppBar(
            backgroundColor: scaffoldColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: AppText.h2(
              currentRental.id,
              fontSize: 20,
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: primaryColor),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRentalView(existingRental: currentRental),
                      ),
                    );
                  } else if (value == 'share') {
                    InvoicePdfGenerator.shareInvoice(context, currentRental);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Edit Rental', style: TextStyle(fontFamily: 'Urbanist')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share_outlined, size: 18, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Share Invoice', style: TextStyle(fontFamily: 'Urbanist')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Record Card
                  Container(
                    padding: const EdgeInsets.all(18),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText.h1(currentRental.id, fontSize: 20),
                            AppStatusBadge.fromStatus(currentRental.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.business_outlined, size: 16, color: primaryColor),
                            const SizedBox(width: 6),
                            AppText(currentRental.customerName, fontWeight: FontWeight.bold),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            AppText.caption(currentRental.customerPhone, fontSize: 13),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 16),

                        // Dates Grid
                        Row(
                          children: [
                            Expanded(child: _buildDetailField('RENTAL DATE', currentRental.pickupDate)),
                            Expanded(child: _buildDetailField('RETURN DATE', currentRental.returnDate)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDetailField('DURATION', currentRental.duration)),
                            Expanded(child: _buildDetailField('CREATED BY', currentRental.createdBy)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rented Items Card
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
                        AppText.h2('Rented Items', fontSize: 18),
                        const SizedBox(height: 14),
                        if (_isLoadingDetails && currentRental.items.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(color: buttonColor1),
                            ),
                          )
                        else if (currentRental.items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'No items found for this rental',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...currentRental.items.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                                      AppText(
                                        item.name.isNotEmpty ? item.name : 'Rented Item',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      AppText.caption('${item.quantity} qty × ₹${item.ratePerDay.toStringAsFixed(0)}/day'),
                                    ],
                                  ),
                                ),
                                AppText('₹${item.total.toStringAsFixed(0)}', fontWeight: FontWeight.bold, fontSize: 15),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Financial Summary Card
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
                        AppText.h2('Financial Summary', fontSize: 18),
                        const SizedBox(height: 14),
                        _buildRow('Subtotal', '₹${currentRental.subtotal.toStringAsFixed(0)}'),
                        _buildRow('Discount', '-₹${currentRental.discount.toStringAsFixed(0)}', isNegative: true),
                        _buildRow('Rental Total', '₹${currentRental.totalAmount.toStringAsFixed(0)}', isBold: true),
                        _buildRow('Paid', '₹${currentRental.paidAmount.toStringAsFixed(0)}', color: buttonColor1),
                        const SizedBox(height: 10),

                        // Balance Due Highlight Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText('Balance Due', fontWeight: FontWeight.bold, fontSize: 14),
                              AppText(
                                '₹${currentRental.balanceDue.toStringAsFixed(0)}',
                                fontWeight: FontWeight.bold,
                                color: currentRental.balanceDue > 0 ? Colors.redAccent : primaryColor,
                                fontSize: 15,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        _buildRow('Deposit', '₹${currentRental.securityDeposit.toStringAsFixed(0)}', icon: Icons.info_outline_rounded),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payments History Card
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText.h2('Payments', fontSize: 18),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All', style: TextStyle(color: buttonColor1, fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (currentRental.payments.isEmpty)
                          AppText.caption('No payments recorded yet.')
                        else
                          ...currentRental.payments.map((p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: buttonColor1.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.payments_outlined, color: buttonColor1, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText('₹${p.amount.toStringAsFixed(0)}', fontWeight: FontWeight.bold, fontSize: 14),
                                      AppText.caption(p.date, fontSize: 12),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    p.mode,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2x2 Grid Action Buttons
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildActionButton(
                        icon: Icons.credit_card_rounded,
                        label: 'Add Payment',
                        onTap: () {
                          AppDialog.show(context: context, title: 'Add Payment', message: 'Record new payment transaction.');
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share Invoice',
                        onTap: () {
                          InvoicePdfGenerator.shareInvoice(context, currentRental);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.print_outlined,
                        label: 'Print Invoice',
                        onTap: () {
                          InvoicePdfGenerator.shareInvoice(context, currentRental);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.cancel_outlined,
                        label: 'Cancel Rental',
                        isDestructive: true,
                        onTap: () {
                          AppDialog.show(
                            context: context,
                            title: 'Cancel Rental',
                            message: 'Are you sure you want to cancel this rental order?',
                            type: AppDialogType.error,
                            secondaryButtonText: 'No',
                            primaryButtonText: 'Yes, Cancel',
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: AppButton.secondary(
                text: 'Process Return',
                icon: Icons.assignment_return_outlined,
                onPressed: () {
                  context.read<RentalBloc>().add(ProcessRentalReturn(currentRental.id));
                  AppDialog.show(
                    context: context,
                    title: 'Process Return',
                    message: 'Rental ${currentRental.id} marked as RETURNED.',
                    type: AppDialogType.success,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.caption(label, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        const SizedBox(height: 2),
        AppText(value, fontWeight: FontWeight.w600, fontSize: 14),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isNegative = false, bool isBold = false, Color? color, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
              ],
              AppText(label, color: Colors.grey.shade700, fontSize: 14),
            ],
          ),
          AppText(
            value,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isNegative ? Colors.redAccent : (color ?? primaryColor),
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDestructive ? const Color(0xFFFEE2E2) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDestructive ? const Color(0xFFFCA5A5) : Colors.grey.shade300,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isDestructive ? const Color(0xFFDC2626) : primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDestructive ? const Color(0xFFDC2626) : primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
