/// The ticket classes supported by the calculator.
///
/// Each class carries its own free baggage allowance, so the allowance is
/// never duplicated elsewhere in the app.
enum TicketClass {
  economy(label: 'Economy', allowanceKg: 20),
  business(label: 'Business', allowanceKg: 40);

  const TicketClass({required this.label, required this.allowanceKg});

  final String label;
  final int allowanceKg;
}

/// The result of one baggage fee calculation.
///
/// Create instances with [BaggageFare.calculate] so the formulas only live in
/// one place.
class BaggageFare {
  const BaggageFare({
    required this.ticketClass,
    required this.weightKg,
    required this.ratePerKg,
    required this.excessWeightKg,
    required this.charge,
    required this.serviceTax,
    required this.totalPayable,
  });

  /// Service tax charged on the excess baggage charge (8%).
  static const double serviceTaxRate = 0.08;

  final TicketClass ticketClass;
  final double weightKg;
  final double ratePerKg;
  final double excessWeightKg;
  final double charge;
  final double serviceTax;
  final double totalPayable;

  /// The free baggage allowance for the selected ticket class.
  double get allowanceKg => ticketClass.allowanceKg.toDouble();

  /// Calculates the excess weight, charge, 8% service tax and total payable.
  factory BaggageFare.calculate({
    required TicketClass ticketClass,
    required double weightKg,
    required double ratePerKg,
  }) {
    assert(weightKg >= 0, 'Baggage weight must not be negative.');
    assert(ratePerKg >= 0, 'Rate per kg must not be negative.');

    // Step 1: the allowance comes from the selected ticket class.
    final double allowance = ticketClass.allowanceKg.toDouble();

    // Step 2: excess weight is never allowed to become negative.
    final double excessWeight =
        (weightKg - allowance).clamp(0.0, double.infinity).toDouble();

    // Step 3: excess baggage charge.
    final double charge = excessWeight * ratePerKg;

    // Step 4: 8% service tax.
    final double serviceTax = charge * serviceTaxRate;

    // Step 5: total amount payable.
    final double totalPayable = charge + serviceTax;

    return BaggageFare(
      ticketClass: ticketClass,
      weightKg: weightKg,
      ratePerKg: ratePerKg,
      excessWeightKg: excessWeight,
      charge: charge,
      serviceTax: serviceTax,
      totalPayable: totalPayable,
    );
  }
}
