import 'package:flutter/material.dart';

import '../models/baggage_fare.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Displays one completed calculation with the total amount highlighted.
class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.fare});

  final BaggageFare fare;

  @override
  Widget build(BuildContext context) {
    final bool hasExcess = fare.excessWeightKg > 0;

    return Card(
      key: const Key('resultCard'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 21,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Calculation summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SummaryRow(
              label: 'Ticket class',
              value: fare.ticketClass.label,
            ),
            _SummaryRow(
              label: 'Baggage allowance',
              value: '${formatWeight(fare.allowanceKg)} kg',
            ),
            _SummaryRow(
              label: 'Actual baggage weight',
              value: '${formatWeight(fare.weightKg)} kg',
            ),
            _SummaryRow(
              label: 'Excess baggage weight',
              value: '${formatWeight(fare.excessWeightKg)} kg',
              highlight: hasExcess,
            ),
            _SummaryRow(
              label: 'Excess baggage charge',
              value: formatMoney(fare.charge),
            ),
            _SummaryRow(
              label: 'Service tax (8%)',
              value: formatMoney(fare.serviceTax),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.navyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total amount payable',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatMoney(fare.totalPayable),
                    key: const Key('totalAmount'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  if (!hasExcess) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Within the allowance - no excess fee.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Rate used: ${formatMoney(fare.ratePerKg)} per kg',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.mutedText,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.accent : AppColors.navy,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
