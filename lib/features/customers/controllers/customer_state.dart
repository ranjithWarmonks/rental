import 'package:flutter/foundation.dart';
import '../models/customer_model.dart';

enum CustomerStatus { initial, loading, success, failure }

@immutable
class CustomerState {
  final CustomerStatus status;
  final List<CustomerModel> customers;
  final CustomerModel? selectedCustomer;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.selectedCustomer,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  CustomerState copyWith({
    CustomerStatus? status,
    List<CustomerModel>? customers,
    CustomerModel? selectedCustomer,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
