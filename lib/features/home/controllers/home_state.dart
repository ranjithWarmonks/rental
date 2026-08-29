import 'package:flutter/foundation.dart';
import '../models/dashboard_model.dart';

enum HomeStatus { initial, loading, success, failure }

@immutable
class HomeState {
  final HomeStatus status;
  final int selectedTabIndex;
  final DashboardOverviewModel? dashboardData;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.selectedTabIndex = 0,
    this.dashboardData,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    int? selectedTabIndex,
    DashboardOverviewModel? dashboardData,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      dashboardData: dashboardData ?? this.dashboardData,
      errorMessage: errorMessage,
    );
  }
}
