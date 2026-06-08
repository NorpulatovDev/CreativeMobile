import 'package:flutter/services.dart';

/// Formats a phone number as the user types into the Uzbek standard:
/// +998 XX XXX XX XX  (17 chars total)
///
/// - Always prepends "+998 "
/// - Accepts exactly 9 subscriber digits after the country code
/// - Strips spaces when submitted (use .replaceAll(' ', '') on the value)
class UzbekPhoneNumberFormatter extends TextInputFormatter {
  static final _nonDigits = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Extract only digits from the raw input
    final digits = newValue.text.replaceAll(_nonDigits, '');

    // 2. If completely empty, reset to base prefix
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '+998 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }

    // 3. Strip the country code prefix if present, so we only work with
    //    the subscriber portion (up to 9 digits).
    String body = digits;
    if (body.startsWith('998')) {
      body = body.substring(3);
    }

    // Limit to 9 subscriber digits
    if (body.length > 9) {
      body = body.substring(0, 9);
    }

    // 4. Build the formatted string: +998 XX XXX XX XX
    final buffer = StringBuffer();
    buffer.write('+998 ');

    if (body.isNotEmpty) {
      // Operator code – 2 digits, e.g. 90
      buffer.write(body.substring(0, body.length >= 2 ? 2 : body.length));
      if (body.length > 2) buffer.write(' ');
    }

    if (body.length > 2) {
      // Next 3 digits, e.g. 123
      buffer.write(body.substring(2, body.length >= 5 ? 5 : body.length));
      if (body.length > 5) buffer.write(' ');
    }

    if (body.length > 5) {
      // Next 2 digits, e.g. 45
      buffer.write(body.substring(5, body.length >= 7 ? 7 : body.length));
      if (body.length > 7) buffer.write(' ');
    }

    if (body.length > 7) {
      // Last 2 digits, e.g. 67
      buffer.write(body.substring(7));
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
