class FormValidators {
  /// Validates Phone Number (7 to 15 digits, allows +, -, spaces, parentheses)
  static String? validatePhone(String? val, {bool isRequired = true}) {
    if (val == null || val.trim().isEmpty) {
      if (isRequired) return 'Phone number is required';
      return null;
    }
    final clean = val.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(clean)) {
      return 'Enter a valid phone number (7-15 digits)';
    }
    return null;
  }

  /// Validates Email address format
  static String? validateEmail(String? val, {bool isRequired = false}) {
    if (val == null || val.trim().isEmpty) {
      if (isRequired) return 'Email address is required';
      return null;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates Monetary Amounts and Decimal numbers (e.g. 500, 500.50)
  static String? validateAmount(
    String? val, {
    bool isRequired = true,
    double minAmount = 0.0,
    String label = 'Amount',
  }) {
    if (val == null || val.trim().isEmpty) {
      if (isRequired) return '$label is required';
      return null;
    }
    final clean = val.replaceAll('₹', '').replaceAll(',', '').trim();
    final d = double.tryParse(clean);
    if (d == null) {
      return 'Enter a valid number or decimal (e.g. 500.00)';
    }
    if (d < minAmount) {
      return '$label cannot be negative';
    }
    return null;
  }

  /// Format dynamic number or string cleanly to 2 decimal places (e.g. 500.00)
  static String formatDecimal(dynamic val) {
    if (val == null) return '0.00';
    if (val is num) return val.toDouble().toStringAsFixed(2);
    final clean = val.toString().replaceAll('₹', '').replaceAll(',', '').trim();
    final d = double.tryParse(clean);
    return d != null ? d.toStringAsFixed(2) : '0.00';
  }

  /// Clean numeric phone string (digits and leading + only)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\+0-9]'), '');
  }

  /// Formats phone number into a single clean string with country code (e.g. +919539962345)
  static String formatPhoneWithCountryCode(String phone, {String defaultCountryCode = '+91'}) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (clean.isEmpty) return '';
    if (clean.startsWith('+')) {
      return clean;
    }
    if (clean.startsWith('00')) {
      return '+${clean.substring(2)}';
    }
    if (clean.length == 10) {
      return '$defaultCountryCode$clean';
    }
    return clean.startsWith('+') ? clean : '$defaultCountryCode$clean';
  }
}
