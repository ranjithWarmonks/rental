import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import 'package:rental/shared/utils/form_validators.dart';
import '../models/customer_model.dart';
import '../models/customer_api_models.dart';

class CustomerService {
  Future<List<CustomerModel>> getCustomers({String searchQuery = ''}) async {
    final url = searchQuery.isEmpty
        ? customersApiName
        : '$customersApiName?q=$searchQuery';

    final res = await ApiManager().getCall(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      List<dynamic> rawList = [];

      if (data is Map && data.containsKey('data')) {
        final dataVal = data['data'];
        if (dataVal is List) {
          rawList = dataVal;
        } else if (dataVal is Map && dataVal.containsKey('data') && dataVal['data'] is List) {
          rawList = dataVal['data'];
        } else if (dataVal is Map) {
          rawList = [dataVal];
        }
      } else if (data is List) {
        rawList = data;
      }

      final parsedList = rawList.map((raw) {
        final apiItem = CustomerApiModel.fromJson(Map<String, dynamic>.from(raw));
        return CustomerModel(
          id: 'CUST-${apiItem.id}',
          name: apiItem.name,
          phone: apiItem.phone,
          email: apiItem.email ?? '',
          address: apiItem.address ?? '',
          city: apiItem.address ?? 'City',
          customerType: apiItem.customerType ?? 'Retail',
          idProofType: apiItem.idProofType ?? 'Driver License',
          idProofNumber: apiItem.idProofNumber ?? '',
          notes: apiItem.notes,
          totalRentals: 0,
          activeRentals: 0,
          totalSpent: 0.0,
          joinedDate: '2026-08-21',
        );
      }).toList();

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return parsedList
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.phone.toLowerCase().contains(q) ||
                c.email.toLowerCase().contains(q))
            .toList();
      }

      return parsedList;
    } else {
      throw Exception('Failed to load customers (${res.statusCode})');
    }
  }

  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    final cleanPhone = FormValidators.formatPhoneWithCountryCode(customer.phone);
    final req = CreateCustomerRequest(
      name: customer.name,
      phone: cleanPhone,
      email: customer.email.isNotEmpty ? customer.email : null,
      address: customer.address.isNotEmpty ? customer.address : null,
      customerType: customer.customerType,
      idProofType: customer.idProofType,
      idProofNumber: customer.idProofNumber,
      notes: customer.notes != null && customer.notes!.isNotEmpty ? customer.notes : null,
    );

    final res = await ApiManager().postCall(
      customersApiName,
      jsonEncode(req.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final rawData = data is Map && data.containsKey('data') ? data['data'] : data;
      if (rawData is Map && rawData.containsKey('id')) {
        return customer.copyWith(id: 'CUST-${rawData['id']}', phone: cleanPhone);
      }
      return customer.copyWith(phone: cleanPhone);
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message') ? data['message'] : 'Failed to add customer';
      throw Exception(msg);
    }
  }

  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    final rawId = int.tryParse(customer.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final cleanPhone = FormValidators.formatPhoneWithCountryCode(customer.phone);
    final req = CreateCustomerRequest(
      name: customer.name,
      phone: cleanPhone,
      email: customer.email.isNotEmpty ? customer.email : null,
      address: customer.address.isNotEmpty ? customer.address : null,
      customerType: customer.customerType,
      idProofType: customer.idProofType,
      idProofNumber: customer.idProofNumber,
      notes: customer.notes != null && customer.notes!.isNotEmpty ? customer.notes : null,
    );

    final res = await ApiManager().patchCall(
      customerDetailApiName(rawId),
      jsonEncode(req.toJson()),
    );

    if (res.statusCode == 200) {
      return customer.copyWith(phone: cleanPhone);
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message') ? data['message'] : 'Failed to update customer';
      throw Exception(msg);
    }
  }

  Future<CustomerModel> quickAddCustomer({
    required String name,
    required String phone,
    String customerType = 'Retail',
  }) async {
    final cleanPhone = FormValidators.formatPhoneWithCountryCode(phone);
    final req = QuickCustomerRequest(
      name: name,
      phone: cleanPhone,
      customerType: customerType,
    );

    final res = await ApiManager().postCall(
      customersQuickApiName,
      jsonEncode(req.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final rawData = data is Map && data.containsKey('data') ? data['data'] : data;
      final int newId = (rawData is Map && rawData.containsKey('id'))
          ? rawData['id']
          : DateTime.now().millisecondsSinceEpoch;

      return CustomerModel(
        id: 'CUST-$newId',
        name: name,
        phone: phone,
        email: '',
        address: '',
        city: 'City',
        customerType: customerType,
        totalRentals: 0,
        activeRentals: 0,
        totalSpent: 0.0,
        joinedDate: '2026-08-21',
      );
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message') ? data['message'] : 'Failed to quick add customer';
      throw Exception(msg);
    }
  }
}
