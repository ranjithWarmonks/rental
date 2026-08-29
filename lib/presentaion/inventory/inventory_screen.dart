import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/features/inventory/controllers/inventory_bloc.dart';
import 'package:rental/features/inventory/views/items_list_view.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryBloc(),
      child: const ItemsListView(),
    );
  }
}
