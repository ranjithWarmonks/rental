import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/rental_service.dart';
import 'rental_event.dart';
import 'rental_state.dart';

class RentalBloc extends Bloc<RentalEvent, RentalState> {
  final RentalService _rentalService;

  RentalBloc({RentalService? rentalService})
      : _rentalService = rentalService ?? RentalService(),
        super(const RentalState()) {
    on<FetchRentals>(_onFetchRentals);
    on<FilterRentals>(_onFilterRentals);
    on<SearchRentals>(_onSearchRentals);
    on<CreateRentalSubmitted>(_onCreateRentalSubmitted);
    on<UpdateRentalSubmitted>(_onUpdateRentalSubmitted);
    on<ProcessRentalReturn>(_onProcessRentalReturn);
    on<SelectRentalForDetails>(_onSelectRentalForDetails);
  }

  Future<void> _onFetchRentals(
      FetchRentals event, Emitter<RentalState> emit) async {
    emit(state.copyWith(status: RentalStatus.loading, errorMessage: null));
    try {
      final list = await _rentalService.getRentals(
        filter: event.filter,
        searchQuery: event.searchQuery,
      );
      emit(state.copyWith(
        status: RentalStatus.success,
        rentals: list,
        currentFilter: event.filter,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RentalStatus.failure,
        errorMessage: 'Failed to fetch rentals.',
      ));
    }
  }

  Future<void> _onFilterRentals(
      FilterRentals event, Emitter<RentalState> emit) async {
    add(FetchRentals(filter: event.filter, searchQuery: state.searchQuery));
  }

  Future<void> _onSearchRentals(
      SearchRentals event, Emitter<RentalState> emit) async {
    add(FetchRentals(filter: state.currentFilter, searchQuery: event.query));
  }

  Future<void> _onCreateRentalSubmitted(
      CreateRentalSubmitted event, Emitter<RentalState> emit) async {
    emit(state.copyWith(status: RentalStatus.loading, errorMessage: null));
    try {
      final created = await _rentalService.addRental(
        event.rental,
        customerId: event.customerId ?? 1,
        locationId: event.locationId ?? 1,
        paymentMode: event.paymentMode ?? 'cash',
        notes: event.notes,
      );
      final list = await _rentalService.getRentals(
        filter: state.currentFilter,
        searchQuery: state.searchQuery,
      );
      emit(state.copyWith(
        status: RentalStatus.success,
        rentals: list,
        selectedRental: created,
        successMessage: 'Rental ${created.id} created successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RentalStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateRentalSubmitted(
      UpdateRentalSubmitted event, Emitter<RentalState> emit) async {
    emit(state.copyWith(status: RentalStatus.loading, errorMessage: null));
    try {
      final updated = await _rentalService.updateRental(event.rental);
      final list = await _rentalService.getRentals(
        filter: state.currentFilter,
        searchQuery: state.searchQuery,
      );
      emit(state.copyWith(
        status: RentalStatus.success,
        rentals: list,
        selectedRental: updated,
        successMessage: 'Rental ${updated.id} updated successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RentalStatus.failure,
        errorMessage: 'Failed to update rental.',
      ));
    }
  }

  Future<void> _onProcessRentalReturn(
      ProcessRentalReturn event, Emitter<RentalState> emit) async {
    emit(state.copyWith(status: RentalStatus.loading, errorMessage: null));
    try {
      final updated = await _rentalService.processReturn(event.rentalId);
      final list = await _rentalService.getRentals(
        filter: state.currentFilter,
        searchQuery: state.searchQuery,
      );
      emit(state.copyWith(
        status: RentalStatus.success,
        rentals: list,
        selectedRental: updated,
        successMessage: 'Rental ${updated.id} processed as RETURNED!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RentalStatus.failure,
        errorMessage: 'Failed to process return.',
      ));
    }
  }

  Future<void> _onSelectRentalForDetails(
      SelectRentalForDetails event, Emitter<RentalState> emit) async {
    emit(state.copyWith(selectedRental: event.rental));
    try {
      final targetId = event.rental.dbId ?? event.rental.id;
      final detailed = await _rentalService.getRentalDetails(targetId);
      emit(state.copyWith(selectedRental: detailed));
    } catch (_) {}
  }
}
