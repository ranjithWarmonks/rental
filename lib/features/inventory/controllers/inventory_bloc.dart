import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/inventory_service.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryService _service;

  InventoryBloc({InventoryService? service})
      : _service = service ?? InventoryService(),
        super(const InventoryState()) {
    on<FetchItems>(_onFetchItems);
    on<SearchItems>(_onSearchItems);
    on<AddItemRequested>(_onAddItem);
    on<UpdateItemRequested>(_onUpdateItem);
    on<DeleteItemRequested>(_onDeleteItem);
  }

  Future<void> _onFetchItems(
    FetchItems event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    try {
      final items = await _service.getItems(searchQuery: event.searchQuery);
      emit(state.copyWith(
        status: InventoryStatus.success,
        items: items,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSearchItems(
    SearchItems event,
    Emitter<InventoryState> emit,
  ) async {
    add(FetchItems(searchQuery: event.query));
  }

  Future<void> _onAddItem(
    AddItemRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    try {
      final newItem = await _service.addItem(event.request);
      final updatedList = List<dynamic>.from(state.items)..insert(0, newItem);
      emit(state.copyWith(
        status: InventoryStatus.success,
        items: updatedList.cast(),
        successMessage: 'Item "${newItem.name}" added successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItemRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    try {
      final updatedItem = await _service.updateItem(event.id, event.request);
      final updatedList = state.items.map((i) => i.id == event.id ? updatedItem : i).toList();
      emit(state.copyWith(
        status: InventoryStatus.success,
        items: updatedList,
        successMessage: 'Item "${updatedItem.name}" updated successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItemRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    try {
      await _service.deleteItem(event.id);
      final updatedList = state.items.where((i) => i.id != event.id).toList();
      emit(state.copyWith(
        status: InventoryStatus.success,
        items: updatedList,
        successMessage: 'Item deleted successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
