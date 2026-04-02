/// User inputs for the rent scenario.
class RentInput {
  /// Current monthly rent in CAD.
  final double monthlyRent;

  /// Expected annual rent increase as a percentage (e.g. 2.5 means 2.5%).
  final double rentIncreaseRate;

  const RentInput({required this.monthlyRent, required this.rentIncreaseRate});

  RentInput copyWith({double? monthlyRent, double? rentIncreaseRate}) {
    return RentInput(
      monthlyRent: monthlyRent ?? this.monthlyRent,
      rentIncreaseRate: rentIncreaseRate ?? this.rentIncreaseRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RentInput &&
          runtimeType == other.runtimeType &&
          monthlyRent == other.monthlyRent &&
          rentIncreaseRate == other.rentIncreaseRate;

  @override
  int get hashCode => Object.hash(monthlyRent, rentIncreaseRate);

  @override
  String toString() =>
      'RentInput(monthlyRent: $monthlyRent, '
      'rentIncreaseRate: $rentIncreaseRate)';
}
