import 'package:flutter/foundation.dart';
import '../models/rental_model.dart';

enum RentalStatus { initial, loading, success, failure }

@immutable
class RentalState {
  final RentalStatus status;
  final List<RentalModel> rentals;
  final RentalModel? selectedRental;
  final String currentFilter;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const RentalState({
    this.status = RentalStatus.initial,
    this.rentals = const [],
    this.selectedRental,
    this.currentFilter = 'All',
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  RentalState copyWith({
    RentalStatus? status,
    List<RentalModel>? rentals,
    RentalModel? selectedRental,
    String? currentFilter,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
  }) {
    return RentalState(
      status: status ?? this.status,
      rentals: rentals ?? this.rentals,
      selectedRental: selectedRental ?? this.selectedRental,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
