/// User inputs for the investment scenario.
class InvestmentInput {
  /// Expected annual return on investments as a percentage
  /// (e.g. 7.5 means 7.5%).
  final double investmentReturn;

  const InvestmentInput({required this.investmentReturn});

  InvestmentInput copyWith({double? investmentReturn}) {
    return InvestmentInput(
      investmentReturn: investmentReturn ?? this.investmentReturn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentInput &&
          runtimeType == other.runtimeType &&
          investmentReturn == other.investmentReturn;

  @override
  int get hashCode => investmentReturn.hashCode;

  @override
  String toString() => 'InvestmentInput(investmentReturn: $investmentReturn)';
}
