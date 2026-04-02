/// A single month's row in the mortgage amortization schedule.
class AmortizationMonth {
  /// Month sequence number (1-based, 1 to totalMonths).
  final int index;

  /// Year number (1-based, 1 to amortizationYears).
  final int year;

  /// Month within the year (1–12).
  final int monthInYear;

  /// Total payment for this month.
  final double payment;

  /// Interest portion of this month's payment.
  final double interest;

  /// Principal portion of this month's payment.
  final double principal;

  /// Outstanding balance at the start of this month (before payment).
  final double balanceStart;

  /// Outstanding balance at the end of this month (after payment).
  final double balanceEnd;

  /// Cumulative principal paid up to and including this month.
  final double cumulativePrincipal;

  /// Cumulative interest paid up to and including this month.
  final double cumulativeInterest;

  const AmortizationMonth({
    required this.index,
    required this.year,
    required this.monthInYear,
    required this.payment,
    required this.interest,
    required this.principal,
    required this.balanceStart,
    required this.balanceEnd,
    required this.cumulativePrincipal,
    required this.cumulativeInterest,
  });

  @override
  String toString() =>
      'AmortizationMonth(index: $index, year: $year, '
      'month: $monthInYear, payment: $payment, '
      'principal: $principal, interest: $interest, '
      'balance: $balanceEnd)';
}

/// Full result of a mortgage amortization calculation.
class MortgageAmortizationResult {
  /// Fixed monthly payment amount.
  final double monthlyPayment;

  /// Total principal paid over the full term.
  final double totalPrincipalPaid;

  /// Total interest paid over the full term.
  final double totalInterestPaid;

  /// Total amount paid (principal + interest).
  final double totalPaid;

  /// Month-by-month amortization schedule.
  final List<AmortizationMonth> months;

  const MortgageAmortizationResult({
    required this.monthlyPayment,
    required this.totalPrincipalPaid,
    required this.totalInterestPaid,
    required this.totalPaid,
    required this.months,
  });

  @override
  String toString() =>
      'MortgageAmortizationResult(monthlyPayment: $monthlyPayment, '
      'totalPaid: $totalPaid, '
      'totalInterest: $totalInterestPaid, '
      'months: ${months.length})';
}
