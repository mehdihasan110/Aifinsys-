import 'package:flutter/material.dart';
import 'highlight_card.dart';

import '../../../data/utils/statistics_helper.dart';

class HighlightCardsSection extends StatelessWidget {
  final StatisticsHelper stats;
  final String currency;

  const HighlightCardsSection({
    super.key,
    required this.stats,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HighlightCard(
                title: "Income",
                amount: stats.totalIncome,
                color: Theme.of(context).colorScheme.secondary,
                currency: currency,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HighlightCard(
                title: "Expense",
                amount: stats.totalSpending,
                color: Colors.redAccent,
                currency: currency,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        HighlightCard(
          title: "Total Savings",
          amount: stats.totalSaved,
          color: Theme.of(context).colorScheme.primary,
          currency: currency,
          icon: Icons.savings_outlined,
          fullWidth: true,
        ),
      ],
    );
  }
}
