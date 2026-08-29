import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import 'package:rental/features/profile/services/user_profile_service.dart';
import '../models/dashboard_model.dart';
import '../models/dashboard_summary_model.dart';

class HomeService {
  Future<DashboardOverviewModel> fetchDashboardData() async {
    final userProfile = await UserProfileService().getCachedProfile();
    final res = await ApiManager().getCall(dashboardSummaryApiName);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final summary = DashboardSummaryModel.fromJson(data);

      return DashboardOverviewModel(
        userName: userProfile.name,
        todayRentals: summary.activeRentals,
        todayReturns: summary.dueToday,
        overdueRentals: summary.overdue,
        pendingPaymentsAmount: '₹${summary.salesTodayTotal.toStringAsFixed(0)}',
        alerts: summary.overdue > 0 || summary.dueToday > 0
            ? [
                if (summary.overdue > 0)
                  DashboardAlertItem(
                    id: 'alt_1',
                    title: '${summary.overdue} Overdue rentals',
                    subtitle: 'Requires immediate follow-up.',
                    actionLabel: 'VIEW LIST',
                    isOverdueAlert: true,
                  ),
                if (summary.dueToday > 0)
                  DashboardAlertItem(
                    id: 'alt_2',
                    title: '${summary.dueToday} Returns expected today',
                    subtitle: 'Prepare inventory space.',
                    actionLabel: 'VIEW SCHEDULE',
                    isOverdueAlert: false,
                  ),
              ]
            : [],
        recentRentals: [],
      );
    } else {
      throw Exception('Failed to fetch dashboard summary (${res.statusCode})');
    }
  }
}
