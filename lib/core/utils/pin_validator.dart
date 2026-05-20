/// Validation rules for the 6-digit admin PIN.
class PinValidator {
  PinValidator._();

  static const int length = 6;

  /// Returns an error message, or null when the PIN is acceptable.
  ///
  /// Rules:
  ///  - exactly 6 digits
  ///  - not all the same digit (e.g. 111111)
  ///  - not a strictly ascending run (e.g. 123456)
  ///  - not a strictly descending run (e.g. 654321)
  static String? validate(String pin) {
    if (pin.length != length) {
      return 'PIN must be exactly $length digits.';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'PIN must contain digits only.';
    }
    final digits = pin.split('').map(int.parse).toList();

    final allSame = digits.every((d) => d == digits.first);
    if (allSame) {
      return 'PIN cannot be all the same digit.';
    }

    var ascending = true;
    var descending = true;
    for (var i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) ascending = false;
      if (digits[i] != digits[i - 1] - 1) descending = false;
    }
    if (ascending || descending) {
      return 'PIN cannot be a sequential number.';
    }
    return null;
  }

  static bool isValid(String pin) => validate(pin) == null;
}
