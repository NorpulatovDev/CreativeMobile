import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _amountFormat = NumberFormat('#,###', 'en_US');

/// Display an amount grouped by thousands with a space separator:
/// 300000 -> "300 000", 150500 -> "150 500".
String formatAmount(num value) =>
    _amountFormat.format(value.toInt()).replaceAll(',', ' ');

/// Strip grouping (and any other non-digits) from a money input so it can be
/// parsed: "300 000" -> "300000".
String amountDigits(String input) => input.replaceAll(RegExp(r'[^\d]'), '');

/// Groups a money field's digits with spaces as the user types:
/// 300000 -> "300 000". Strip with [amountDigits] before parsing on submit.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = amountDigits(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    // Drop leading zeros ("0500" -> "500") but keep a lone "0".
    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final formatted = formatAmount(int.parse(normalized));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
