/// Whether a dual-mode field is expressed as a percentage or dollar amount.
enum InputMode { percentage, amount }

/// A field that can be entered as either a percentage of some base amount
/// or as an absolute dollar amount.
///
/// Used for down payment, closing costs, property tax, and maintenance —
/// all of which the user can toggle between "20%" and "$120,000".
/// Both values are always stored so toggling doesn't lose data.
class DualModeValue {
  final InputMode mode;
  final double percentage;
  final double amount;

  const DualModeValue({
    this.mode = InputMode.percentage,
    required this.percentage,
    required this.amount,
  });

  DualModeValue copyWith({
    InputMode? mode,
    double? percentage,
    double? amount,
  }) {
    return DualModeValue(
      mode: mode ?? this.mode,
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DualModeValue &&
          runtimeType == other.runtimeType &&
          mode == other.mode &&
          percentage == other.percentage &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(mode, percentage, amount);

  @override
  String toString() =>
      'DualModeValue($percentage% / \$$amount [$mode])';
}
