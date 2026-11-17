/// Formats a monetary value in Malaysian Ringgit with two decimal places.
///
/// Example: `formatMoney(81)` returns `RM 81.00`.
String formatMoney(double value) => 'RM ${value.toStringAsFixed(2)}';

/// Formats a weight in kilograms without unnecessary trailing zeros.
///
/// Examples: `formatWeight(5)` returns `5`, `formatWeight(2.5)` returns `2.5`.
String formatWeight(double value) {
  final String fixed = value.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}
