import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/customer_service.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerService _customerService;

  CustomerBloc({CustomerService? customerService})
      : _customerService = customerService ?? CustomerService(),
        super(const CustomerState()) {
    on<FetchCustomers>(_onFetchCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<AddCustomerSubmitted>(_onAddCustomerSubmitted);
    on<UpdateCustomerSubmitted>(_onUpdateCustomerSubmitted);
    on<SelectCustomerForDetails>(_onSelectCustomerForDetails);
  }

  Future<void> _onFetchCustomers(
      FetchCustomers event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading, errorMessage: null));
    try {
      final list = await _customerService.getCustomers(
        searchQuery: event.searchQuery,
      );
      emit(state.copyWith(
        status: CustomerStatus.success,
        customers: list,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomerStatus.success,
        customers: [],
        errorMessage: null,
      ));
    }
  }

  Future<void> _onSearchCustomers(
      SearchCustomers event, Emitter<CustomerState> emit) async {
    add(FetchCustomers(searchQuery: event.query));
  }

  Future<void> _onAddCustomerSubmitted(
      AddCustomerSubmitted event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading, errorMessage: null));
    try {
      final created = await _customerService.addCustomer(event.customer);
      final list = await _customerService.getCustomers(searchQuery: state.searchQuery);
      emit(state.copyWith(
        status: CustomerStatus.success,
        customers: list,
        selectedCustomer: created,
        successMessage: 'Customer ${created.name} added successfully!',
      ));
    } catch (e) {
      final list = await _customerService.getCustomers(searchQuery: state.searchQuery);
      emit(state.copyWith(
        status: CustomerStatus.success,
        customers: list,
        selectedCustomer: event.customer,
      ));
    }
  }

  Future<void> _onUpdateCustomerSubmitted(
      UpdateCustomerSubmitted event, Emitter<CustomerState> emit) async {
    emit(state.copyWith(status: CustomerStatus.loading, errorMessage: null));
    try {
      final updated = await _customerService.updateCustomer(event.customer);
      final list = await _customerService.getCustomers(searchQuery: state.searchQuery);
      emit(state.copyWith(
        status: CustomerStatus.success,
        customers: list,
        selectedCustomer: updated,
        successMessage: 'Customer ${updated.name} updated successfully!',
      ));
    } catch (e) {
      final list = await _customerService.getCustomers(searchQuery: state.searchQuery);
      emit(state.copyWith(
        status: CustomerStatus.success,
        customers: list,
        selectedCustomer: event.customer,
      ));
    }
  }

  void _onSelectCustomerForDetails(
      SelectCustomerForDetails event, Emitter<CustomerState> emit) {
    emit(state.copyWith(selectedCustomer: event.customer));
  }
}
