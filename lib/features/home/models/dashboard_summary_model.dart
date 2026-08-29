class DashboardSummaryModel {
  final int activeRentals;
  final int dueToday;
  final int overdue;
  final int salesTodayCount;
  final double salesTodayTotal;

  DashboardSummaryModel({
    required this.activeRentals,
    required this.dueToday,
    required this.overdue,
    required this.salesTodayCount,
    required this.salesTodayTotal,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      DashboardSummaryModel(
        activeRentals: json['active_rentals'] ?? 0,
        dueToday: json['due_today'] ?? 0,
        overdue: json['overdue'] ?? 0,
        salesTodayCount: json['sales_today_count'] ?? 0,
        salesTodayTotal: (json['sales_today_total'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'active_rentals': activeRentals,
        'due_today': dueToday,
        'overdue': overdue,
        'sales_today_count': salesTodayCount,
        'sales_today_total': salesTodayTotal,
      };
}
