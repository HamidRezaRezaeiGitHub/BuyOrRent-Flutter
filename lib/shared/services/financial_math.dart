import 'dart:math' as math;

import 'round_mode.dart';

/// Apply compound growth to a [baseValue] over [periods].
///
/// `result = baseValue × (1 + annualRate / 100) ^ periods`
///
/// This is a general-purpose formula used for:
/// - Rent increases: `compoundGrowth(monthlyRent, yearIndex, 2.5)`
/// - Asset appreciation: `compoundGrowth(homeValue, years, 3.0)`
/// - Investment returns: `compoundGrowth(principal, years, 7.5)`
///
/// [periods] is 0-based: period 0 returns [baseValue] unchanged.
double compoundGrowth({
  required double baseValue,
  required int periods,
  required double annualRatePercent,
  RoundMode roundMode = RoundMode.none,
}) {
  if (periods == 0) return roundMoney(baseValue, roundMode);

  final result = baseValue * math.pow(1 + annualRatePercent / 100, periods);
  return roundMoney(result, roundMode);
}

/// Calculate the fixed periodic payment for a loan (amortization formula).
///
/// Uses the standard formula:
/// - rate > 0: `M = P × [r(1+r)^n] / [(1+r)^n − 1]`
/// - rate = 0: `M = P / n`
///
/// Where P = principal, r = periodic rate (decimal), n = total periods.
///
/// Works for any period length — pass monthly rate for monthly payments,
/// annual rate for annual payments, etc.
double calculatePeriodicPayment({
  required double principal,
  required double periodicRate,
  required int totalPeriods,
  RoundMode roundMode = RoundMode.cents,
}) {
  assert(principal >= 0);
  assert(totalPeriods > 0);

  if (periodicRate == 0) {
    return roundMoney(principal / totalPeriods, roundMode);
  }

  final factor = math.pow(1 + periodicRate, totalPeriods);
  final payment = principal * (periodicRate * factor) / (factor - 1);
  return roundMoney(payment, roundMode);
}
