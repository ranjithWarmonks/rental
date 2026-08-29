import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import 'package:rental/shared/utils/form_validators.dart';
import '../controllers/rental_bloc.dart';
import '../controllers/rental_event.dart';
import '../models/rental_model.dart';
import 'add_rental_view.dart';
import 'rentals_list_view.dart';

class RentalSummaryView extends StatelessWidget {
  final RentalModel rental;
  final bool isEditMode;

  const RentalSummaryView({
    super.key,
    required this.rental,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<RentalBloc>();
      return _RentalSummaryViewContent(rental: rental, isEditMode: isEditMode);
    } catch (_) {
      return BlocProvider(
        create: (context) => RentalBloc(),
        child: _RentalSummaryViewContent(rental: rental, isEditMode: isEditMode),
      );
    }
  }
}

class _RentalSummaryViewContent extends StatefulWidget {
  final RentalModel rental;
  final bool isEditMode;

  const _RentalSummaryViewContent({
    required this.rental,
    required this.isEditMode,
  });

  @override
  State<_RentalSummaryViewContent> createState() => _RentalSummaryViewContentState();
}

class _RentalSummaryViewContentState extends State<_RentalSummaryViewContent> {
  String _paymentModeType = 'Full'; // Full, Partial, Credit
  String _selectedPaymentMode = 'UPI'; // UPI, Cash, Bank, Card
  final _amountReceivedController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final totalDue = widget.rental.totalAmount + widget.rental.securityDeposit;
    _amountReceivedController.text = '₹ ${totalDue.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    _amountReceivedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onPaymentModeTypeChanged(String mode, double totalDue) {
    setState(() {
      _paymentModeType = mode;
      if (mode == 'Full') {
        _amountReceivedController.text = '₹ ${totalDue.toStringAsFixed(2)}';
      } else if (mode == 'Credit') {
        _amountReceivedController.text = '₹ 0.00';
      } else if (mode == 'Partial') {
        final half = totalDue / 2;
        _amountReceivedController.text = '₹ ${half.toStringAsFixed(2)}';
      }
    });
  }

  void _confirmAndSubmit() {
    final totalDue = widget.rental.totalAmount + widget.rental.securityDeposit;
    final cleanText = _amountReceivedController.text.replaceAll('₹', '').replaceAll(',', '').trim();
    final double userPaidAmount = double.tryParse(cleanText) ?? 0.0;
    final double updatedBalanceDue = totalDue - userPaidAmount;

    final updatedRental = widget.rental.copyWith(
      paidAmount: userPaidAmount,
      balanceDue: updatedBalanceDue > 0 ? updatedBalanceDue : 0.0,
      paymentStatus: userPaidAmount >= totalDue
          ? 'FULL'
          : (userPaidAmount > 0 ? 'PARTIAL' : 'DUE'),
      payments: userPaidAmount > 0
          ? [
              PaymentLogModel(
                id: 'pay_new',
                amount: userPaidAmount,
                date: widget.rental.pickupDate,
                mode: _selectedPaymentMode,
              ),
            ]
          : [],
    );

    if (widget.isEditMode) {
      context.read<RentalBloc>().add(UpdateRentalSubmitted(updatedRental));
    } else {
      context.read<RentalBloc>().add(
        CreateRentalSubmitted(
          updatedRental,
          customerId: updatedRental.customerId,
          locationId: updatedRental.locationId ?? 1,
          paymentMode: _selectedPaymentMode.toLowerCase(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : 'Pick up from main gate.',
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditMode ? 'Rental updated successfully!' : 'Rental created successfully!',
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
        backgroundColor: buttonColor1,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RentalsListView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.rental;
    final totalDue = r.totalAmount + r.securityDeposit;

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText.h2(
          'Summary & Payment',
          fontSize: 20,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Header (1 Details -> 2 Items -> 3 Payment)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle(number: '1', label: 'Details', isCompleted: true),
                  _buildStepConnector(isCompleted: true),
                  _buildStepCircle(number: '2', label: 'Items', isCompleted: true),
                  _buildStepConnector(isCompleted: true),
                  _buildStepCircle(number: '3', label: 'Payment', isCompleted: true, isActive: true),
                ],
              ),

              const SizedBox(height: 24),

              // Customer Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        AppText.caption('CUSTOMER', fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: primaryColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.h3(r.customerName, fontSize: 16),
                            AppText.caption(r.customerPhone, fontSize: 13),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Rental Period Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        AppText.caption('RENTAL PERIOD', fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.h3('${r.pickupDate} - ${r.returnDate}', fontSize: 16),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppText(
                            r.duration,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Items Rented Card
              Container(
                padding: const EdgeInsets.all(16),
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
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            AppText.caption('ITEMS RENTED', fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddRentalView(existingRental: r),
                              ),
                            );
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: buttonColor1,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...r.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.restaurant_outlined, size: 18, color: primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(item.name, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          AppText.caption('x${item.quantity}', fontSize: 13),
                          const SizedBox(width: 16),
                          AppText('₹${item.total.toStringAsFixed(2)}', fontWeight: FontWeight.bold, fontSize: 14),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Financial Summary Card
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
                    AppText.h2('Financial Summary', fontSize: 18),
                    const SizedBox(height: 14),
                    _buildSummaryRow('Subtotal', '₹${r.subtotal.toStringAsFixed(2)}'),
                    if (r.discount > 0)
                      _buildSummaryRow('Discount (10%)', '-₹${r.discount.toStringAsFixed(2)}', isNegative: true),
                    if (r.tax > 0)
                      _buildSummaryRow('Tax (5%)', '₹${r.tax.toStringAsFixed(2)}'),
                    _buildSummaryRow('Rental Total', '₹${r.totalAmount.toStringAsFixed(2)}', isBold: true),
                    _buildSummaryRow('Security Deposit (Refundable)', '₹${r.securityDeposit.toStringAsFixed(2)}'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.h2('Total Due', fontSize: 20),
                        AppText.h1('₹${totalDue.toStringAsFixed(2)}', fontSize: 22, color: primaryColor),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Payment Details Container
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
                    AppText.h2('Payment', fontSize: 18),
                    const SizedBox(height: 14),

                    AppText.caption('PAYMENT AMOUNT', fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),

                    // Payment Amount Chips
                    Row(
                      children: ['Full', 'Partial', 'Credit'].map((mode) {
                        final isSel = _paymentModeType == mode;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => _onPaymentModeTypeChanged(mode, totalDue),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSel ? buttonColor1.withValues(alpha: 0.08) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSel ? buttonColor1 : Colors.grey.shade300,
                                    width: isSel ? 1.5 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    mode,
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 13,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                      color: isSel ? buttonColor1 : primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'AMOUNT RECEIVED',
                      hintText: '₹ 0.00',
                      controller: _amountReceivedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => FormValidators.validateAmount(val, isRequired: false, label: 'Amount Received'),
                    ),

                    const SizedBox(height: 16),

                    AppText.caption('MODE OF PAYMENT', fontWeight: FontWeight.bold),
                    const SizedBox(height: 8),

                    // 2x2 Payment Mode Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.2,
                      children: [
                        _buildPaymentMethodTile('UPI', Icons.qr_code_scanner_rounded),
                        _buildPaymentMethodTile('Cash', Icons.payments_outlined),
                        _buildPaymentMethodTile('Bank', Icons.account_balance_outlined),
                        _buildPaymentMethodTile('Card', Icons.credit_card_rounded),
                      ],
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'NOTES (OPTIONAL)',
                      hintText: 'Add any transaction notes...',
                      controller: _notesController,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          child: Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: widget.isEditMode ? 'Confirm & Update' : 'Confirm & Create Rental',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _confirmAndSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle({
    required String number,
    required String label,
    required bool isCompleted,
    bool isActive = false,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? buttonColor1 : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: buttonColor1, width: 1.5),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isCompleted ? Colors.white : buttonColor1,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? buttonColor1 : Colors.grey.shade600,
            fontFamily: 'Urbanist',
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Container(
      width: 48,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isCompleted ? buttonColor1 : Colors.grey.shade300,
    );
  }

  Widget _buildSummaryRow(String title, String amount, {bool isNegative = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            title,
            color: isBold ? primaryColor : Colors.grey.shade600,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          AppText(
            amount,
            color: isNegative ? Colors.redAccent : primaryColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(String name, IconData icon) {
    final isSelected = _selectedPaymentMode == name;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMode = name),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? buttonColor1 : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? buttonColor1 : primaryColor),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? buttonColor1 : primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
