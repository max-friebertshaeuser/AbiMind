import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/presentation/screens/start/start-screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/utils/constants.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({Key? key}) : super(key: key);

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  List<Map<String, dynamic>> statisticsData = [];
  late Map<String, dynamic> selectedStatistic;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    final String response = await rootBundle.loadString(
      'assets/exerciseProgress.json',
    );
    final List<dynamic> data = jsonDecode(response);

    setState(() {
      statisticsData = List<Map<String, dynamic>>.from(data);
      selectedStatistic = statisticsData.firstWhere(
            (stat) => stat['currentYear'] == 2025,
        orElse: () => statisticsData.first,
      );
      isLoading = false;
    });
  }

  void selectStatistic(Map<String, dynamic> stat) {
    setState(() {
      selectedStatistic = stat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return MainSurfaceCard(
      title: 'Current Exercise',
      boxFlex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /// Left: Big Selected Card
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    selectedStatistic['currentYear'].toString(),
                    style: kHeaderStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CircularPercentIndicator(
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      progressColor: colorScheme.onPrimaryFixedVariant,
                      radius: 70.0,
                      lineWidth: 12.0,
                      percent: double.parse(
                        selectedStatistic['solvedPercentageNumeric'].toString(),
                      ),
                      center: Text(
                        "${selectedStatistic['solvedPercentage']}%",
                        style: percentageStyle,
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ),
                  const Divider(thickness: 2),
                  Container(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CategoryProgress(
                            title: 'Stochastik',
                            done: selectedStatistic['stochastikDone'],
                            total: selectedStatistic['stochastikTotal'],
                          ),
                          CategoryProgress(
                            title: 'Analysis',
                            done: selectedStatistic['analysisDone'],
                            total: selectedStatistic['analysisTotal'],
                          ),
                          CategoryProgress(
                            title: 'Geometrie',
                            done: selectedStatistic['geometrieDone'],
                            total: selectedStatistic['geometrieTotal'],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Vertical Divider
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            child: const VerticalDivider(thickness: 2, width: 10),
          ),

          /// Right: Scrollable Mini Cards
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children:
                statisticsData.map((stat) {
                  final isSelected =
                      stat['currentYear'] ==
                          selectedStatistic['currentYear'];
                  return GestureDetector(
                    onTap: () => selectStatistic(stat),

                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.onPrimaryFixedVariant,
                          width: 2,
                        ),
                        color:
                        isSelected
                            ? colorScheme.primaryContainer.withOpacity(
                          0.5,
                        )
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // Center the year
                        children: [
                          Text(
                            "— ${stat['currentYear']} —",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                              isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularPercentIndicator(
                                backgroundColor:
                                colorScheme.surfaceContainerHigh,
                                progressColor:
                                colorScheme.onPrimaryFixedVariant,
                                radius: 30.0,
                                lineWidth: 8.0,
                                percent: double.parse(
                                  stat['solvedPercentageNumeric']
                                      .toString(),
                                ),
                                center: Text(
                                  "${stat['solvedPercentage']}%",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    isSelected
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                              ),

                              const SizedBox(width: 20),

                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${stat['stochastikDone']}/${stat['stochastikTotal']} Stochastik",
                                    style: TextStyle(
                                      color:
                                      isSelected
                                          ? colorScheme
                                          .onPrimaryContainer
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "${stat['analysisDone']}/${stat['analysisTotal']} Analysis",
                                    style: TextStyle(
                                      color:
                                      isSelected
                                          ? colorScheme
                                          .onPrimaryContainer
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "${stat['geometrieDone']}/${stat['geometrieTotal']} Geometrie",
                                    style: TextStyle(
                                      color:
                                      isSelected
                                          ? colorScheme
                                          .onPrimaryContainer
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class CategoryProgress extends StatelessWidget {
  final String title;
  final int done;
  final int total;

  const CategoryProgress({
    super.key,
    required this.title,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double progress = done / total;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: smallTextStyle),
              const Spacer(),
              Text("$done/$total", style: smallTextStyle),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHigh,
              color: colorScheme.onPrimaryFixedVariant,
            ),
          ),
        ],
      ),
    );
  }
}