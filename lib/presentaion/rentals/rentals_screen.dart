import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/features/rentals/controllers/rental_bloc.dart';
import 'package:rental/features/rentals/views/rentals_list_view.dart';

class RentalsScreen extends StatelessWidget {
  const RentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RentalBloc(),
      child: const RentalsListView(),
    );
  }
}
