import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/features/rentals/views/add_rental_view.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_bottom_nav_bar.dart';
import 'package:rental/shared/widgets/app_dialog.dart';
import 'package:rental/shared/widgets/app_status_badge.dart';
import 'package:rental/shared/widgets/app_text.dart';
import '../controllers/home_bloc.dart';
import '../controllers/home_event.dart';
import '../controllers/home_state.dart';
import '../../notifications/views/notifications_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor, // #F8FAFC
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: primaryColor, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsView(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: buttonColor1),
            );
          }

          final data = state.dashboardData;
          if (data == null) {
            return const Center(
              child: AppText('No data available.'),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Subtitle
                AppText(
                  'Good morning, ${data.userName}',
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                const SizedBox(height: 4),
                AppText.h1(
                  "Here's today's overview",
                  fontSize: 22,
                ),

                const SizedBox(height: 20),

                // 2x2 Quick Action Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.6,
                  children: [
                    _buildQuickActionCard(
                      title: 'New Rental',
                      icon: Icons.add_shopping_cart_rounded,
                      isPrimary: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddRentalView()),
                        );
                      },
                    ),
                    _buildQuickActionCard(
                      title: 'New Sale',
                      icon: Icons.point_of_sale_rounded,
                      isPrimary: false,
                      onTap: () {},
                    ),
                    _buildQuickActionCard(
                      title: 'Return',
                      icon: Icons.assignment_return_outlined,
                      isPrimary: false,
                      onTap: () {},
                    ),
                    _buildQuickActionCard(
                      title: 'Payment',
                      icon: Icons.account_balance_wallet_outlined,
                      isPrimary: false,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2x2 Overview Metrics Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricCard(
                      label: "TODAY'S RENTALS",
                      value: '${data.todayRentals}',
                      icon: Icons.shopping_cart_outlined,
                      iconColor: buttonColor1,
                    ),
                    _buildMetricCard(
                      label: "TODAY'S RETURNS",
                      value: '${data.todayReturns}',
                      icon: Icons.keyboard_return_rounded,
                      iconColor: primaryColor,
                    ),
                    _buildMetricCard(
                      label: "OVERDUE RENTALS",
                      value: '${data.overdueRentals}',
                      icon: Icons.warning_amber_rounded,
                      iconColor: const Color(0xFFDC2626),
                      bgColor: const Color(0xFFFEE2E2),
                      valueColor: const Color(0xFFDC2626),
                      labelColor: const Color(0xFF991B1B),
                    ),
                    _buildMetricCard(
                      label: "PENDING PAYMENTS",
                      value: data.pendingPaymentsAmount,
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: buttonColor1,
                      leftBorderColor: buttonColor1,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Important Alerts Section
                AppText.h2('Important Alerts', fontSize: 18),
                const SizedBox(height: 14),

                ...data.alerts.map((alert) => _buildAlertCard(alert)),

                const SizedBox(height: 28),

                // Recent Rentals Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.h2('Recent Rentals', fontSize: 18),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'VIEW ALL',
                        style: TextStyle(
                          color: buttonColor1,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Recent Rentals Table / List Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: AppText.caption('ID', fontWeight: FontWeight.bold)),
                            Expanded(flex: 4, child: AppText.caption('Customer', fontWeight: FontWeight.bold)),
                            Expanded(flex: 3, child: AppText.caption('Amount', fontWeight: FontWeight.bold)),
                            Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: AppText.caption('Status', fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      // Rental List Items
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.recentRentals.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, index) {
                          final item = data.recentRentals[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: AppText(
                                    item.id,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: AppText(
                                    item.customerName,
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: AppText(
                                    item.amount,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: AppStatusBadge.fromStatus(item.status),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? buttonColor1 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : primaryColor,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isPrimary ? Colors.white : primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Urbanist',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    Color? bgColor,
    Color? valueColor,
    Color? labelColor,
    Color? leftBorderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            if (leftBorderColor != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(color: leftBorderColor),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: labelColor ?? Colors.grey.shade600,
                            letterSpacing: 0.5,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                      Icon(icon, color: iconColor, size: 20),
                    ],
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? primaryColor,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(dynamic alert) {
    final isOverdue = alert.isOverdueAlert;
    final bg = isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6);
    final border = isOverdue ? const Color(0xFFFCA5A5) : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isOverdue ? Icons.error_outline_rounded : Icons.inventory_2_outlined,
            color: isOverdue ? const Color(0xFFDC2626) : primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? const Color(0xFF991B1B) : primaryColor,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isOverdue ? const Color(0xFFB91C1C) : Colors.grey.shade700,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    AppDialog.show(
                      context: context,
                      title: alert.title,
                      message: 'Viewing details for ${alert.title}.',
                      type: isOverdue ? AppDialogType.warning : AppDialogType.info,
                    );
                  },
                  child: Text(
                    alert.actionLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isOverdue ? const Color(0xFF991B1B) : primaryColor,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
