import '../models/inventory_models.dart';

enum InventoryStatus { initial, loading, success, failure }

class InventoryState {
  final InventoryStatus status;
  final List<InventoryItemModel> items;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.items = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  InventoryState copyWith({
    InventoryStatus? status,
    List<InventoryItemModel>? items,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
  }) {
    return InventoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
