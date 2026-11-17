import 'package:flutter_test/flutter_test.dart';
import 'package:individual_assigments/models/baggage_fare.dart';
import 'package:individual_assigments/utils/formatters.dart';

void main() {
  group('BaggageFare.calculate', () {
    test('25 kg Economy at RM15 gives 5 kg excess and RM81.00 total', () {
      final BaggageFare fare = BaggageFare.calculate(
        ticketClass: TicketClass.economy,
        weightKg: 25,
        ratePerKg: 15,
      );

      expect(fare.allowanceKg, 20);
      expect(fare.excessWeightKg, closeTo(5, 0.000001));
      expect(fare.charge, closeTo(75, 0.000001));
      expect(fare.serviceTax, closeTo(6, 0.000001));
      expect(fare.totalPayable, closeTo(81, 0.000001));
    });

    test('18 kg Economy at RM15 has no excess weight and costs nothing', () {
      final BaggageFare fare = BaggageFare.calculate(
        ticketClass: TicketClass.economy,
        weightKg: 18,
        ratePerKg: 15,
      );

      expect(fare.excessWeightKg, 0);
      expect(fare.charge, 0);
      expect(fare.serviceTax, 0);
      expect(fare.totalPayable, 0);
    });

    test('55 kg Business at RM12 gives 15 kg excess and RM194.40 total', () {
      final BaggageFare fare = BaggageFare.calculate(
        ticketClass: TicketClass.business,
        weightKg: 55,
        ratePerKg: 12,
      );

      expect(fare.allowanceKg, 40);
      expect(fare.excessWeightKg, closeTo(15, 0.000001));
      expect(fare.charge, closeTo(180, 0.000001));
      expect(fare.serviceTax, closeTo(14.4, 0.000001));
      expect(fare.totalPayable, closeTo(194.4, 0.000001));
    });

    test('42.5 kg Business at RM12 supports decimal weights', () {
      final BaggageFare fare = BaggageFare.calculate(
        ticketClass: TicketClass.business,
        weightKg: 42.5,
        ratePerKg: 12,
      );

      expect(fare.excessWeightKg, closeTo(2.5, 0.000001));
      expect(fare.charge, closeTo(30, 0.000001));
      expect(fare.serviceTax, closeTo(2.4, 0.000001));
      expect(fare.totalPayable, closeTo(32.4, 0.000001));
    });

    test('excess weight is never negative, even at 0 kg', () {
      final BaggageFare fare = BaggageFare.calculate(
        ticketClass: TicketClass.business,
        weightKg: 0,
        ratePerKg: 20,
      );

      expect(fare.excessWeightKg, 0);
      expect(fare.totalPayable, 0);
    });

    test('service tax is 8% of the excess baggage charge', () {
      final BaggageFare fare = BaggageFare.calculate(
        ticketClass: TicketClass.economy,
        weightKg: 30,
        ratePerKg: 10,
      );

      expect(BaggageFare.serviceTaxRate, 0.08);
      expect(fare.charge, closeTo(100, 0.000001));
      expect(fare.serviceTax, closeTo(8, 0.000001));
      expect(fare.totalPayable, closeTo(108, 0.000001));
    });
  });

  group('Formatters', () {
    test('formatMoney always shows two decimal places and the RM prefix', () {
      expect(formatMoney(81), 'RM 81.00');
      expect(formatMoney(32.4), 'RM 32.40');
      expect(formatMoney(0), 'RM 0.00');
    });

    test('formatWeight removes unnecessary trailing zeros', () {
      expect(formatWeight(20), '20');
      expect(formatWeight(2.5), '2.5');
      expect(formatWeight(42.5), '42.5');
      expect(formatWeight(0), '0');
    });
  });
}
