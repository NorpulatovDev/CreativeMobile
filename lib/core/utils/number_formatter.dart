import 'package:intl/intl.dart';

final _amountFormat = NumberFormat('#,###', 'en_US');

String formatAmount(double value) => _amountFormat.format(value.toInt());
