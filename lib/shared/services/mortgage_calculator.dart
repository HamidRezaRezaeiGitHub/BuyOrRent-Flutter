import '../models/mortgage_amortization_result.dart';
import 'financial_math.dart';
import 'round_mode.dart';

/// Generate a complete month-by-month mortgage amortization schedule.
///
/// Returns `null` when inputs are invalid (negative price, rate, or
/// out-of-range down payment). Callers from validated UI can safely
/// assert the result is non-null.
///
/// The final month's payment is adjusted so the balance reaches exactly
/// zero, absorbing any accumulated rounding residue.
MortgageAmortizationResult? calculateMortgageAmortization({
  required double purchasePrice,
  required double downPaymentPercentage,
  required double annualInterestRate,
  required int amortizationYears,
  RoundMode roundMode = RoundMode.cents,
}) {
  // --- Validation ---
  if (purchasePrice <= 0 || amortizationYears <= 0) return null;
  if (downPaymentPercentage < 0 || downPaymentPercentage > 100) return null;
  if (annualInterestRate < 0) return null;

  // --- Derived values ---
  final loanAmount = purchasePrice * (1 - downPaymentPercentage / 100);
  final monthlyRate = annualInterestRate > 0
      ? (annualInterestRate / 12) / 100
      : 0.0;
  final totalMonths = amortizationYears * 12;

  final monthlyPayment = calculatePeriodicPayment(
    principal: loanAmount,
    periodicRate: monthlyRate,
    totalPeriods: totalMonths,
    roundMode: roundMode,
  );

  // --- Build schedule ---
  final months = <AmortizationMonth>[];
  var balance = loanAmount;
  var cumulativePrincipal = 0.0;
  var cumulativeInterest = 0.0;

  for (var i = 1; i <= totalMonths; i++) {
    final balanceStart = balance;
    final interest = roundMoney(balanceStart * monthlyRate, roundMode);

    final int year = ((i - 1) ~/ 12) + 1;
    final int monthInYear = ((i - 1) % 12) + 1;

    if (i == totalMonths) {
      // Final month: pay off exactly the remaining balance.
      final principal = balanceStart;
      final finalPayment = principal + interest;

      cumulativePrincipal += principal;
      cumulativeInterest += interest;

      months.add(
        AmortizationMonth(
          index: i,
          year: year,
          monthInYear: monthInYear,
          payment: roundMoney(finalPayment, roundMode),
          interest: roundMoney(interest, roundMode),
          principal: roundMoney(principal, roundMode),
          balanceStart: roundMoney(balanceStart, roundMode),
          balanceEnd: 0,
          cumulativePrincipal: roundMoney(cumulativePrincipal, roundMode),
          cumulativeInterest: roundMoney(cumulativeInterest, roundMode),
        ),
      );
    } else {
      final principal = roundMoney(monthlyPayment - interest, roundMode);
      balance = roundMoney(balanceStart - principal, roundMode);

      cumulativePrincipal += principal;
      cumulativeInterest += interest;

      months.add(
        AmortizationMonth(
          index: i,
          year: year,
          monthInYear: monthInYear,
          payment: roundMoney(monthlyPayment, roundMode),
          interest: roundMoney(interest, roundMode),
          principal: roundMoney(principal, roundMode),
          balanceStart: roundMoney(balanceStart, roundMode),
          balanceEnd: roundMoney(balance, roundMode),
          cumulativePrincipal: roundMoney(cumulativePrincipal, roundMode),
          cumulativeInterest: roundMoney(cumulativeInterest, roundMode),
        ),
      );
    }
  }

  final totalPrincipalPaid = roundMoney(loanAmount, roundMode);
  final totalInterestPaid = roundMoney(cumulativeInterest, roundMode);

  return MortgageAmortizationResult(
    monthlyPayment: roundMoney(monthlyPayment, roundMode),
    totalPrincipalPaid: totalPrincipalPaid,
    totalInterestPaid: totalInterestPaid,
    totalPaid: roundMoney(totalPrincipalPaid + totalInterestPaid, roundMode),
    months: months,
  );
}
