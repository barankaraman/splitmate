import 'package:intl/intl.dart';

/// Utility class for formatting monetary values consistently.
/// Currency: Turkish Lira (₺)
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter =
      NumberFormat.compact(locale: 'tr_TR');

  /// Formats [amount] as ₺12,50
  static String format(double amount) => _formatter.format(amount);

  /// Formats [amount] compactly with a leading ₺. e.g. ₺1,2B
  static String formatCompact(double amount) =>
      '₺${_compactFormatter.format(amount)}';

  /// Returns a positive or negative-signed formatted string.
  static String formatSigned(double amount) {
    final formatted = _formatter.format(amount.abs());
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Parses a string like "12.50" or "12,50" to a double. Returns null on failure.
  static double? tryParse(String input) =>
      double.tryParse(input.replaceAll(',', '.'));
}
