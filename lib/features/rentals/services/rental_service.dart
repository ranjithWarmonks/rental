import 'dart:convert';
import 'package:rental/shared/api/api_manager.dart';
import 'package:rental/shared/api/api_name.dart';
import '../models/rental_model.dart';
import '../models/rental_api_models.dart';

class RentalService {
  double parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  int parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  String formatDateStr(dynamic val) {
    if (val == null) return '';
    final str = val.toString();
    try {
      final dt = DateTime.parse(str);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return str.split('T').first;
    }
  }

  String _toApiDateTimeStr(String dateStr) {
    if (dateStr.trim().isEmpty) return '2026-08-21 14:00:00';
    if (dateStr.contains(' ')) return dateStr;
    try {
      final parts = dateStr.trim().split('-');
      if (parts.length == 3) {
        if (parts[0].length == 4) {
          // YYYY-MM-DD
          return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')} 14:00:00';
        } else {
          // DD-MM-YYYY
          return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')} 14:00:00';
        }
      }
    } catch (_) {}
    return '$dateStr 14:00:00';
  }

  String calculateDuration(String pickupDateStr, String returnDateStr, {String? rawDuration}) {
    if (rawDuration != null && rawDuration.trim().isNotEmpty && rawDuration != 'null' && rawDuration != '1 Day') {
      return rawDuration;
    }
    try {
      DateTime? parseDt(String str) {
        if (str.isEmpty) return null;
        final clean = str.split('T').first.split(' ').first;
        final parts = clean.split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          final p0 = int.tryParse(parts[0]);
          final p1 = int.tryParse(parts[1]);
          final p2 = int.tryParse(parts[2]);
          if (p0 != null && p1 != null && p2 != null) {
            if (parts[0].length == 4) {
              return DateTime(p0, p1, p2);
            } else if (parts[2].length == 4) {
              return DateTime(p2, p1, p0);
            }
          }
        }
        return DateTime.tryParse(clean);
      }

      final pDate = parseDt(pickupDateStr);
      final rDate = parseDt(returnDateStr);

      if (pDate != null && rDate != null) {
        final diff = rDate.difference(pDate).inDays;
        final days = diff > 0 ? diff : 1;
        return '$days ${days == 1 ? 'Day' : 'Days'}';
      }
    } catch (_) {}
    return rawDuration ?? '1 Day';
  }

  RentalModel _parseRentalFromRaw(Map<String, dynamic> raw) {
    final itemsList = (raw['items'] as List? ?? []).map((i) {
      final itemDetail = i['item'] is Map ? i['item'] : {};
      final itemName = itemDetail['name'] ?? i['item_name'] ?? i['name'] ?? 'Item';
      final itemRate = parseDouble(i['unit_price'] ?? i['price_per_day'] ?? itemDetail['flat_price'] ?? itemDetail['rental_price_per_day']);
      final pMode = (i['pricing_mode'] ?? itemDetail['pricing_mode'] ?? 'day').toString();
      final itemTotal = parseDouble(i['total'] ?? i['subtotal']);
      final itemQty = parseInt(i['quantity']);

      return RentedItemModel(
        id: (i['id'] ?? itemDetail['id'] ?? 0).toString(),
        name: itemName,
        quantity: itemQty > 0 ? itemQty : 1,
        ratePerDay: itemRate,
        total: itemTotal > 0 ? itemTotal : (itemQty * itemRate),
        pricingMode: pMode,
      );
    }).toList();

    final paymentsList = (raw['payments'] as List? ?? []).map((p) {
      final pAmt = parseDouble(p['amount']);
      return PaymentLogModel(
        id: (p['id'] ?? 0).toString(),
        amount: pAmt,
        date: formatDateStr(p['created_at'] ?? p['payment_date'] ?? p['date']),
        mode: (p['method'] ?? p['payment_mode'] ?? p['type'] ?? 'Cash').toString().toUpperCase(),
      );
    }).toList();

    final custMap = raw['customer'] is Map ? raw['customer'] : {};
    final custName = custMap['name'] ?? raw['customer_name'] ?? 'Customer';
    final custPhone = custMap['phone'] ?? raw['customer_phone'] ?? '';

    final pickupDateStr = formatDateStr(raw['rental_date']);
    final returnDateStr = formatDateStr(raw['expected_return_date']);

    final double totalAmt = parseDouble(raw['final_amount'] ?? raw['total_amount'] ?? raw['grand_total']);
    final double subtotalAmt = parseDouble(raw['total_amount'] ?? raw['subtotal']);
    final double discountAmt = parseDouble(raw['discount_amount'] ?? raw['discount']);
    final double depositAmt = parseDouble(raw['security_deposit'] ?? raw['deposit_received']);
    final double calculatedPaid = paymentsList.fold<double>(0.0, (sum, p) => sum + p.amount);
    final double paidAmt = parseDouble(raw['paid_amount'] ?? (calculatedPaid > 0 ? calculatedPaid : totalAmt));
    final double balDue = (totalAmt - paidAmt) > 0 ? (totalAmt - paidAmt) : parseDouble(raw['balance_due']);

    final int rawDbId = parseInt(raw['id']);

    return RentalModel(
      dbId: rawDbId > 0 ? rawDbId : null,
      id: raw['rental_number']?.toString() ?? (rawDbId > 0 ? 'REN-$rawDbId' : 'REN-${raw['id']}'),
      customerId: parseInt(raw['customer_id'] ?? custMap['id']),
      customerName: custName,
      customerPhone: custPhone,
      pickupDate: pickupDateStr.isNotEmpty ? pickupDateStr : '14-03-2026',
      returnDate: returnDateStr.isNotEmpty ? returnDateStr : '15-03-2026',
      duration: calculateDuration(pickupDateStr, returnDateStr, rawDuration: raw['duration']?.toString()),
      createdBy: raw['created_by']?.toString() ?? 'Admin',
      status: (raw['status'] ?? 'CONFIRMED').toString().toUpperCase(),
      totalAmount: totalAmt,
      paidAmount: paidAmt,
      balanceDue: balDue,
      securityDeposit: depositAmt,
      subtotal: subtotalAmt > 0 ? subtotalAmt : totalAmt,
      discount: discountAmt,
      tax: parseDouble(raw['tax']),
      items: itemsList,
      payments: paymentsList,
    );
  }

  Future<List<RentalModel>> getRentals({String filter = 'All', String searchQuery = ''}) async {
    final queryParams = <String>[];
    if (filter != 'All') queryParams.add('filter=${filter.toLowerCase()}');
    if (searchQuery.isNotEmpty) queryParams.add('search=$searchQuery');

    final url = queryParams.isEmpty
        ? rentalsApiName
        : '$rentalsApiName?${queryParams.join('&')}';

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

      return rawList.map((raw) => _parseRentalFromRaw(Map<String, dynamic>.from(raw))).toList();
    } else {
      throw Exception('Failed to load rentals list (${res.statusCode})');
    }
  }

  Future<RentalModel> getRentalDetails(dynamic id) async {
    int targetId = 0;
    if (id is RentalModel) {
      targetId = id.dbId ?? parseInt(id.id.replaceAll(RegExp(r'[^0-9]'), ''));
    } else if (id is int && id > 0) {
      targetId = id;
    } else if (id != null) {
      targetId = parseInt(id.toString().replaceAll(RegExp(r'[^0-9]'), ''));
    }

    if (targetId <= 0) {
      throw Exception('Invalid rental ID: $id');
    }

    final res = await ApiManager().getCall(rentalDetailApiName(targetId));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final raw = body is Map && body.containsKey('data') ? body['data'] : body;
      if (raw is Map) {
        return _parseRentalFromRaw(Map<String, dynamic>.from(raw));
      }
      throw Exception('Invalid rental detail response format');
    } else {
      throw Exception('Failed to load rental details (${res.statusCode})');
    }
  }

  Future<RentalModel> addRental(
    RentalModel rental, {
    int customerId = 7,
    int locationId = 1,
    String paymentMode = 'cash',
    String? notes,
  }) async {
    final effectiveCustomerId = (rental.customerId != null && rental.customerId! > 0)
        ? rental.customerId!
        : (customerId > 0 ? customerId : 7);

    final paymentsList = rental.payments.isNotEmpty
        ? rental.payments.map((p) {
            return RentalOrderPaymentRequest(
              type: 'advance',
              method: p.mode.isNotEmpty ? p.mode.toLowerCase() : paymentMode.toLowerCase(),
              amount: p.amount,
              notes: 'Advance payment at rental creation',
            );
          }).toList()
        : (rental.paidAmount > 0
            ? [
                RentalOrderPaymentRequest(
                  type: 'advance',
                  method: paymentMode.toLowerCase(),
                  amount: rental.paidAmount,
                  notes: 'Advance payment at rental creation',
                ),
              ]
            : null);

    final req = RentalOrderRequest(
      customerId: effectiveCustomerId,
      locationId: locationId > 0 ? locationId : 1,
      rentalDate: _toApiDateTimeStr(rental.pickupDate),
      expectedReturnDate: _toApiDateTimeStr(rental.returnDate),
      discountPercentage: rental.discount,
      depositReceived: rental.securityDeposit,
      paymentMode: paymentMode.toLowerCase(),
      notes: notes ?? 'Rental created via app',
      totalAmount: rental.subtotal > 0 ? rental.subtotal : rental.totalAmount,
      discountAmount: rental.discount,
      finalAmount: rental.totalAmount,
      items: rental.items.map((i) {
        final itemIdInt = parseInt(i.id);
        final uPrice = i.ratePerDay > 0 ? i.ratePerDay : (i.total / (i.quantity > 0 ? i.quantity : 1));
        final pMode = i.pricingMode.isNotEmpty ? i.pricingMode.toLowerCase() : 'day';
        return RentalOrderItemRequest(
          itemId: itemIdInt > 0 ? itemIdInt : 5,
          quantity: i.quantity.toDouble(),
          pricingMode: pMode,
          unitPrice: uPrice,
          discount: 0.0,
          total: i.total > 0 ? i.total : (i.quantity * uPrice),
          customPrice: uPrice,
        );
      }).toList(),
      payments: paymentsList,
    );


    final res = await ApiManager().postCall(
      rentalsApiName,
      jsonEncode(req.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      if (data is Map) {
        final rData = data.containsKey('data') && data['data'] is Map ? data['data'] : data;
        final rawId = parseInt(rData['id']);
        final rentalNum = rData['rental_number']?.toString() ?? (rawId > 0 ? 'REN-$rawId' : 'R-${rData['id'] ?? '01'}');
        return rental.copyWith(
          dbId: rawId > 0 ? rawId : rental.dbId,
          id: rentalNum,
        );
      }
      return rental;
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message')
          ? data['message']
          : 'Failed to create rental (${res.statusCode})';
      throw Exception(msg);
    }
  }

  Future<RentalModel> updateRental(RentalModel rental) async {
    return rental;
  }

  Future<RentalModel> processReturn(String rentalId) async {
    final rawId = int.tryParse(rentalId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (rawId <= 0) {
      throw Exception('Invalid rental ID for return: $rentalId');
    }
    final req = RentalReturnRequest(
      notes: 'Returned',
      items: [],
    );

    final res = await ApiManager().postCall(
      rentalReturnApiName(rawId),
      jsonEncode(req.toJson()),
    );

    if (res.statusCode == 200) {
      return RentalModel(
        id: rentalId,
        customerName: 'Customer',
        customerPhone: '',
        pickupDate: '2026-08-20',
        returnDate: '2026-08-22',
        duration: '2 Days',
        createdBy: 'Admin',
        status: 'RETURNED',
        totalAmount: 0.0,
        paidAmount: 0.0,
        balanceDue: 0.0,
        securityDeposit: 0.0,
        subtotal: 0.0,
        items: [],
        payments: [],
      );
    } else {
      final data = jsonDecode(res.body);
      final msg = data is Map && data.containsKey('message') ? data['message'] : 'Failed to process return';
      throw Exception(msg);
    }
  }
}
