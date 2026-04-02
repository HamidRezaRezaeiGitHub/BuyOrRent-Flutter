/// Rounding control for monetary values.
///
/// - [none]: full floating-point precision.
/// - [cents]: round to 2 decimal places (currency precision).
enum RoundMode { none, cents }

/// Round [value] according to [mode].
///
/// With [RoundMode.cents], rounds to the nearest cent (2 decimal places).
/// With [RoundMode.none], returns the value unchanged.
double roundMoney(double value, RoundMode mode) {
  if (mode == RoundMode.cents) {
    return (value * 100).roundToDouble() / 100;
  }
  return value;
}
