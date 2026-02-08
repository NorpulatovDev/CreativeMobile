import 'package:flutter/services.dart';

/// Phone number formatter for Uzbekistan numbers
/// Formats: +998 XX XXX XX XX
class UzbekPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Get only digits from the new text
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit to 9 digits (after +998)
    final truncated = digitsOnly.substring(0, digitsOnly.length > 9 ? 9 : digitsOnly.length);
    
    // Build formatted string
    final buffer = StringBuffer('+998');
    
    if (truncated.isNotEmpty) {
      buffer.write(' ');
      
      // First 2 digits
      if (truncated.length >= 1) {
        buffer.write(truncated.substring(0, truncated.length >= 2 ? 2 : truncated.length));
      }
      
      // Next 3 digits
      if (truncated.length > 2) {
        buffer.write(' ');
        buffer.write(truncated.substring(2, truncated.length >= 5 ? 5 : truncated.length));
      }
      
      // Next 2 digits
      if (truncated.length > 5) {
        buffer.write(' ');
        buffer.write(truncated.substring(5, truncated.length >= 7 ? 7 : truncated.length));
      }
      
      // Last 2 digits
      if (truncated.length > 7) {
        buffer.write(' ');
        buffer.write(truncated.substring(7));
      }
    }
    
    final formatted = buffer.toString();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Validator for Uzbek phone numbers
class PhoneValidator {
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon raqamini kiriting';
    }
    
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length != 9) {
      return 'To\'liq raqamni kiriting';
    }
    
    // Check if starts with valid Uzbek operator codes
    // final validPrefixes = ['90', '91', '93', '94', '95', '97', '98', '99', '88', '33'];
    // final prefix = digitsOnly.substring(0, 2);
    
    // if (!validPrefixes.contains(prefix)) {
    //   return 'Noto\'g\'ri operator kodi';
    // }
    
    return null;
  }
  
  /// Convert formatted phone to API format: +998XXXXXXXXX
  static String toApiFormat(String formatted) {
    final digitsOnly = formatted.replaceAll(RegExp(r'[^\d]'), '');
    return '+998$digitsOnly';
  }
  
  /// Convert API format to display format: +998 XX XXX XX XX
  static String toDisplayFormat(String apiFormat) {
    final digitsOnly = apiFormat.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 9) return apiFormat;
    
    final phone = digitsOnly.substring(digitsOnly.length - 9);
    return '+998 ${phone.substring(0, 2)} ${phone.substring(2, 5)} ${phone.substring(5, 7)} ${phone.substring(7)}';
  }
}