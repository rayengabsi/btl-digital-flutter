/// Formats a monetary value with comma-grouped thousands and exactly two
/// decimal places, e.g. `12500.8` -> `"12,500.80"` and `2500` -> `"2,500.00"`.
String formatAmountWithComma(double value) {
  final fixed = value.toStringAsFixed(2);
  final dotIndex = fixed.indexOf('.');
  final whole = fixed.substring(0, dotIndex);
  final decimals = fixed.substring(dotIndex + 1);
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(whole[i]);
  }
  return '$buffer.$decimals';
}