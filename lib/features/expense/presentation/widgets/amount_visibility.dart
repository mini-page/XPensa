import 'package:intl/intl.dart';

String maskAmount(String value, {bool masked = false}) {
  return masked ? '••••' : value;
}

String formatSignedAmount(
  double amount,
  NumberFormat currency, {
  required bool masked,
}) {
  if (amount == 0) {
    return maskAmount(currency.format(0), masked: masked);
  }

  final absolute = maskAmount(currency.format(amount.abs()), masked: masked);
  return '${amount > 0 ? '+' : '-'}$absolute';
}
