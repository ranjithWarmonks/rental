import 'package:flutter/foundation.dart';
import '../models/rental_model.dart';

@immutable
abstract class RentalEvent {
  const RentalEvent();
}

class FetchRentals extends RentalEvent {
  final String filter;
  final String searchQuery;
  const FetchRentals({this.filter = 'All', this.searchQuery = ''});
}

class FilterRentals extends RentalEvent {
  final String filter;
  const FilterRentals(this.filter);
}

class SearchRentals extends RentalEvent {
  final String query;
  const SearchRentals(this.query);
}

class CreateRentalSubmitted extends RentalEvent {
  final RentalModel rental;
  final int? customerId;
  final int? locationId;
  final String? paymentMode;
  final String? notes;

  const CreateRentalSubmitted(
    this.rental, {
    this.customerId,
    this.locationId,
    this.paymentMode,
    this.notes,
  });
}

class UpdateRentalSubmitted extends RentalEvent {
  final RentalModel rental;
  const UpdateRentalSubmitted(this.rental);
}

class ProcessRentalReturn extends RentalEvent {
  final String rentalId;
  const ProcessRentalReturn(this.rentalId);
}

class SelectRentalForDetails extends RentalEvent {
  final RentalModel rental;
  const SelectRentalForDetails(this.rental);
}
