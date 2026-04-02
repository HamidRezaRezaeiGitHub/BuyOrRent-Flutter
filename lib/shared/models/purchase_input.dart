import 'dual_mode_value.dart';

/// User inputs for the purchase scenario.
class PurchaseInput {
  /// Property purchase price in CAD.
  final double purchasePrice;

  /// Annual mortgage interest rate as a percentage (e.g. 5.5 means 5.5%).
  final double mortgageRate;

  /// Mortgage amortization period in years.
  final int mortgageLength;

  /// Down payment (% of price or dollar amount).
  final DualModeValue downPayment;

  /// Closing costs (% of price or dollar amount).
  final DualModeValue closingCosts;

  /// Annual property tax (% of price or dollar amount).
  final DualModeValue propertyTax;

  /// Annual maintenance (% of price or dollar amount).
  final DualModeValue maintenance;

  /// Expected annual property appreciation as a percentage.
  final double assetAppreciationRate;

  const PurchaseInput({
    required this.purchasePrice,
    required this.mortgageRate,
    required this.mortgageLength,
    required this.downPayment,
    required this.closingCosts,
    required this.propertyTax,
    required this.maintenance,
    required this.assetAppreciationRate,
  });

  PurchaseInput copyWith({
    double? purchasePrice,
    double? mortgageRate,
    int? mortgageLength,
    DualModeValue? downPayment,
    DualModeValue? closingCosts,
    DualModeValue? propertyTax,
    DualModeValue? maintenance,
    double? assetAppreciationRate,
  }) {
    return PurchaseInput(
      purchasePrice: purchasePrice ?? this.purchasePrice,
      mortgageRate: mortgageRate ?? this.mortgageRate,
      mortgageLength: mortgageLength ?? this.mortgageLength,
      downPayment: downPayment ?? this.downPayment,
      closingCosts: closingCosts ?? this.closingCosts,
      propertyTax: propertyTax ?? this.propertyTax,
      maintenance: maintenance ?? this.maintenance,
      assetAppreciationRate:
          assetAppreciationRate ?? this.assetAppreciationRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseInput &&
          runtimeType == other.runtimeType &&
          purchasePrice == other.purchasePrice &&
          mortgageRate == other.mortgageRate &&
          mortgageLength == other.mortgageLength &&
          downPayment == other.downPayment &&
          closingCosts == other.closingCosts &&
          propertyTax == other.propertyTax &&
          maintenance == other.maintenance &&
          assetAppreciationRate == other.assetAppreciationRate;

  @override
  int get hashCode => Object.hash(
    purchasePrice,
    mortgageRate,
    mortgageLength,
    downPayment,
    closingCosts,
    propertyTax,
    maintenance,
    assetAppreciationRate,
  );

  @override
  String toString() =>
      'PurchaseInput(price: $purchasePrice, '
      'rate: $mortgageRate%, '
      'term: ${mortgageLength}yr, '
      'downPayment: $downPayment)';
}
