import 'package:flutter/foundation.dart';
import '../models/customer_model.dart';

@immutable
abstract class CustomerEvent {
  const CustomerEvent();
}

class FetchCustomers extends CustomerEvent {
  final String searchQuery;
  const FetchCustomers({this.searchQuery = ''});
}

class SearchCustomers extends CustomerEvent {
  final String query;
  const SearchCustomers(this.query);
}

class AddCustomerSubmitted extends CustomerEvent {
  final CustomerModel customer;
  const AddCustomerSubmitted(this.customer);
}

class UpdateCustomerSubmitted extends CustomerEvent {
  final CustomerModel customer;
  const UpdateCustomerSubmitted(this.customer);
}

class SelectCustomerForDetails extends CustomerEvent {
  final CustomerModel customer;
  const SelectCustomerForDetails(this.customer);
}
