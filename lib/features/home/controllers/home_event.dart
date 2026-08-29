import 'package:flutter/foundation.dart';

@immutable
abstract class HomeEvent {
  const HomeEvent();
}

class FetchDashboardData extends HomeEvent {
  const FetchDashboardData();
}

class ChangeBottomNavTab extends HomeEvent {
  final int tabIndex;
  const ChangeBottomNavTab(this.tabIndex);
}
