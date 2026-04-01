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

class CanadaConfig {
  CanadaConfig._();

  // Rent
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

  // Purchase
  static const purchasePrice = FieldConfig(
    min: 100000,
    max: 3000000,
    defaultValue: 600000,
  );
  static const mortgageRate = FieldConfig(
    min: 0,
    max: 15,
    defaultValue: 5.5,
  );
  static const mortgageLength = FieldConfig(
    min: 1,
    max: 40,
    defaultValue: 25,
  );
  static const downPayment = FieldConfig(
    min: 0,
    max: 100,
    defaultValue: 20,
  );
  static const closingCosts = FieldConfig(
    min: 0,
    max: 5,
    defaultValue: 1.5,
  );
  static const propertyTax = FieldConfig(
    min: 0,
    max: 5,
    defaultValue: 0.75,
  );
  static const maintenance = FieldConfig(
    min: 0,
    max: 10,
    defaultValue: 1,
  );
  static const assetAppreciation = FieldConfig(
    min: -5,
    max: 20,
    defaultValue: 3,
  );

  // Investment
  static const investmentReturn = FieldConfig(
    min: -20,
    max: 100,
    defaultValue: 7.5,
  );
}
