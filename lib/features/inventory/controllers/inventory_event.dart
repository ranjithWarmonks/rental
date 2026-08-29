import '../models/inventory_models.dart';

abstract class InventoryEvent {
  const InventoryEvent();
}

class FetchItems extends InventoryEvent {
  final String searchQuery;
  const FetchItems({this.searchQuery = ''});
}

class SearchItems extends InventoryEvent {
  final String query;
  const SearchItems(this.query);
}

class AddItemRequested extends InventoryEvent {
  final CreateItemRequest request;
  const AddItemRequested(this.request);
}

class UpdateItemRequested extends InventoryEvent {
  final int id;
  final CreateItemRequest request;
  const UpdateItemRequested({required this.id, required this.request});
}

class DeleteItemRequested extends InventoryEvent {
  final int id;
  const DeleteItemRequested(this.id);
}
