/// Utility for formatting currency.
///
/// In the assessment prompt, `formatCurrency(e.amount)` was noted as an
/// expensive operation (~3ms due to locale parsing).
///
/// In production, we:
/// 1. Use a memoization cache so identical amounts are not re-parsed.
/// 2. Pre-format or lazily cache formatted amounts in the model layer,
///    preventing main-thread frame drops during scrolling on low-end devices.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final Map<num, String> _cache = {};

  /// Formats [amount] in Indian Rupees (INR) format (e.g., ₹1,500).
  /// Results are memoized to avoid re-running expensive locale logic.
  static String format(num amount) {
    if (_cache.containsKey(amount)) {
      return _cache[amount]!;
    }

    final formatted = _formatToInr(amount);
    // Keep cache bounded to avoid memory bloating
    if (_cache.length > 5000) {
      _cache.clear();
    }
    _cache[amount] = formatted;
    return formatted;
  }

  static String _formatToInr(num amount) {
    // Format according to the Indian numbering system: ₹X,XX,XXX
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(0).split('.');
    var intPart = parts[0];

    if (intPart.length > 3) {
      final lastThree = intPart.substring(intPart.length - 3);
      final remaining = intPart.substring(0, intPart.length - 3);
      final buffer = StringBuffer();
      for (var i = 0; i < remaining.length; i++) {
        if (i > 0 && (remaining.length - i) % 2 == 0) {
          buffer.write(',');
        }
        buffer.write(remaining[i]);
      }
      intPart = '${buffer.toString()},$lastThree';
    }

    final sign = isNegative ? '-' : '';
    return '$sign₹$intPart';
  }
}

/// Standalone top-level function matching the assessment prompt signature.
String formatCurrency(num amount) => CurrencyFormatter.format(amount);
