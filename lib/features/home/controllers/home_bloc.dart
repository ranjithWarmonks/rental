import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/home_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService _homeService;

  HomeBloc({HomeService? homeService})
      : _homeService = homeService ?? HomeService(),
        super(const HomeState()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<ChangeBottomNavTab>(_onChangeBottomNavTab);
  }

  Future<void> _onFetchDashboardData(
      FetchDashboardData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final data = await _homeService.fetchDashboardData();
      emit(state.copyWith(
        status: HomeStatus.success,
        dashboardData: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: 'Failed to load dashboard statistics.',
      ));
    }
  }

  void _onChangeBottomNavTab(
      ChangeBottomNavTab event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }
}
