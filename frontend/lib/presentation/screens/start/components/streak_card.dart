import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/presentation/screens/start/start-screen.dart';

import '../../../../core/utils/constants.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  late Future<Map<String, dynamic>> _streakDataFuture;

  @override
  void initState() {
    super.initState();
    _streakDataFuture = loadStreakData();
  }

  Future<Map<String, dynamic>> loadStreakData() async {
    final String jsonString = await rootBundle.loadString('assets/streak.json');
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: _streakDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fehler: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Keine Daten verfügbar.'));
        }

        final data = snapshot.data!;
        final int streak = data['streak'];
        final double goal = (data['goal'] as num).toDouble();
        final List<dynamic> tenDayLearnProgress = data['tenDayLearnProgress'];

        final List<int> minutesList =
            tenDayLearnProgress.map((e) => e['minutes'] as int).toList();
        final int maxMinutes = minutesList.reduce((a, b) => a > b ? a : b);
        final int minMinutes = minutesList.reduce((a, b) => a < b ? a : b);

        return MainSurfaceCard(
          title: 'Streak',
          boxFlex: 1,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(streak.toString(), style: kHeaderStyle),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.local_fire_department,
                          color: flameColor,
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Du hast dein\nLernziel $streak Tage\nlang erreicht',
                        style: smallTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.onPrimaryFixedVariant,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minY: minMinutes - 10,
                        maxY: maxMinutes + 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots:
                                tenDayLearnProgress.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key.toDouble();
                                  final minutes = entry.value['minutes'] as int;
                                  return FlSpot(index, minutes.toDouble());
                                }).toList(),
                            isCurved: false,
                            isStrokeCapRound: false,
                            barWidth: 0,
                            color: Colors.transparent,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter:
                                  (spot, percent, barData, index) =>
                                      FlDotCirclePainter(
                                        radius: 4,
                                        color:
                                            colorScheme.onPrimaryFixedVariant,
                                        strokeWidth: 0,
                                      ),
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: goal,
                              color: colorScheme.onPrimaryFixedVariant,
                              strokeWidth: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
