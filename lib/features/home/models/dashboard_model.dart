class DashboardOverviewModel {
  final String userName;
  final int todayRentals;
  final int todayReturns;
  final int overdueRentals;
  final String pendingPaymentsAmount;
  final List<DashboardAlertItem> alerts;
  final List<RecentRentalItem> recentRentals;

  DashboardOverviewModel({
    required this.userName,
    required this.todayRentals,
    required this.todayReturns,
    required this.overdueRentals,
    required this.pendingPaymentsAmount,
    required this.alerts,
    required this.recentRentals,
  });
}

class DashboardAlertItem {
  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool isOverdueAlert;

  DashboardAlertItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.isOverdueAlert = false,
  });
}

class RecentRentalItem {
  final String id;
  final String customerName;
  final String amount;
  final String status;

  RecentRentalItem({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
  });
}
