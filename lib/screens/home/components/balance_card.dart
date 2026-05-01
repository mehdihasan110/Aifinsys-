import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/bloc/app_bloc.dart';
import '../../../data/bloc/expense_bloc.dart';
import '../../../theme.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ExpenseBloc>();
    final appBloc = context.watch<AppBloc>();
    final currencyFormat = NumberFormat.currency(
      symbol: appBloc.currency,
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Row: Eye Icon & Balance ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle Visibility Button
                InkWell(
                  onTap: () => setState(() => _isVisible = !_isVisible),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      _isVisible
                          ? Icons.remove_red_eye_outlined
                          : Icons.visibility_off_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),

                // Balance Display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _isVisible
                          ? currencyFormat.format(bloc.totalBalance)
                          : "(¬_¬)", // The hidden face
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Current Balance",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Graph Area ---
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Consumer<ExpenseBloc>(
              builder: (context, bloc, _) {
                final result = bloc.getBalanceHistory(90);
                final days = result.key;
                final history = result.value;

                if (history.isEmpty) {
                  return Center(
                    child: Text(
                      "No data for this period",
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                double minY = history[0];
                double maxY = history[0];
                for (final v in history) {
                  if (v < minY) minY = v;
                  if (v > maxY) maxY = v;
                }

                // Add some padding to Y axis
                final range = maxY - minY;
                minY = minY - (range * 0.1);
                maxY = maxY + (range * 0.1);

                // If all values are same
                if (range == 0) {
                  minY -= 100;
                  maxY += 100;
                }

                final spots = history.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value);
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (days - 1).toDouble(),
                          minY: minY,
                          maxY: maxY,
                          lineTouchData: const LineTouchData(enabled: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.1,
                              color: AppTheme.primaryGreen,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: AppTheme.greenGraphGradient,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Last $days days",
                              style: GoogleFonts.outfit(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // --- Bottom Stats Row ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  "INCOMING",
                  "+${currencyFormat.format(bloc.totalIncoming)}",
                ),
                _buildStatItem(
                  context,
                  "OUTGOING",
                  "-${currencyFormat.format(bloc.totalOutgoing)}",
                ),
                _buildStatItem(
                  context,
                  "INVESTED",
                  currencyFormat.format(bloc.totalInvested),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    Color? labelColor,
  }) {
    final theme = Theme.of(context);
    final color = labelColor ?? theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isVisible ? value : "*****",
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
