class FieldConfig {
  final double min;
  final double max;
  final double defaultValue;

  const FieldConfig({
    required this.min,
    required this.max,
    required this.defaultValue,
  });
}

/// Config for a field that can be entered as a percentage or dollar amount.
class DualModeFieldConfig {
  final FieldConfig percentage;
  final FieldConfig amount;

  const DualModeFieldConfig({required this.percentage, required this.amount});
}

class CanadaConfig {
  CanadaConfig._();

  // -- Rent --
  static const monthlyRent = FieldConfig(
    min: 0,
    max: 10000,
    defaultValue: 2000,
  );
  static const rentIncreaseRate = FieldConfig(
    min: 0,
    max: 20,
    defaultValue: 2.5,
  );

  // -- Purchase --
  static const purchasePrice = FieldConfig(
    min: 100000,
    max: 3000000,
    defaultValue: 600000,
  );
  static const mortgageRate = FieldConfig(min: 0, max: 15, defaultValue: 5.5);
  static const mortgageLength = FieldConfig(min: 1, max: 40, defaultValue: 25);

  static const downPayment = DualModeFieldConfig(
    percentage: FieldConfig(min: 0, max: 100, defaultValue: 20),
    amount: FieldConfig(min: 0, max: 3000000, defaultValue: 120000),
  );

  static const closingCosts = DualModeFieldConfig(
    percentage: FieldConfig(min: 0, max: 5, defaultValue: 1.5),
    amount: FieldConfig(min: 0, max: 100000, defaultValue: 12000),
  );

  static const propertyTax = DualModeFieldConfig(
    percentage: FieldConfig(min: 0, max: 5, defaultValue: 0.75),
    amount: FieldConfig(min: 0, max: 50000, defaultValue: 4500),
  );

  static const maintenance = DualModeFieldConfig(
    percentage: FieldConfig(min: 0, max: 10, defaultValue: 1),
    amount: FieldConfig(min: 0, max: 100000, defaultValue: 6000),
  );

  static const assetAppreciation = FieldConfig(
    min: -5,
    max: 20,
    defaultValue: 3,
  );

  // -- Investment --
  static const investmentReturn = FieldConfig(
    min: -20,
    max: 100,
    defaultValue: 7.5,
  );
}
