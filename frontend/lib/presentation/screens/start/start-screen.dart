import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:frontend/core/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StarScreen extends StatelessWidget {
  const StarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AbiMind',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {}, // Optional drawer
        ),
      ),
      body: Container(
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 1,
              child: Flex(
                direction: Axis.vertical,
                children: [ProgressCard(), StreakCard()],
              ),
            ),
            ExerciseCardList(),
          ],
        ),
      ),
    );
  }
}

class ExerciseCardList extends StatefulWidget {
  @override
  _ExerciseCardListState createState() => _ExerciseCardListState();
}

class _ExerciseCardListState extends State<ExerciseCardList> {
  // Store selected categories
  List<String> selectedCategories = ['Geometrie', 'Analysis'];

  // All tasks (you can also move this outside if you prefer)
  final List<Map<String, dynamic>> taskCardsData = [];

  @override
  void initState() {
    super.initState();
    loadTaskCardsData();
  }

  Future<void> loadTaskCardsData() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/exerciseData.json',
      );
      List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        taskCardsData.addAll(jsonData.cast<Map<String, dynamic>>());
      });
    } catch (e) {
      print('Error loading task cards data: $e');
    }
  }

  // Filter logic based on selected categories
  List<Map<String, dynamic>> get filteredTasks {
    return taskCardsData.where((task) {
      return task['tags'].any((tag) => selectedCategories.contains(tag));
    }).toList();
  }

  void onCategorySelectionChanged(List<String> newSelection) {
    setState(() {
      selectedCategories = newSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: MainSurfaceCard(
        title: 'Exercises',
        boxFlex: 1,
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            filteredTasks.map((task) {
                              return CustomTaskCard(
                                title: task['title'],
                                description: task['description'],
                                tags: List<String>.from(task['tags']),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CategoryToggleBar(
              categories: ['Geometrie', 'Analysis', 'Statistics'],
              selected: selectedCategories,
              onSelectionChanged: onCategorySelectionChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseCards extends StatelessWidget {
  final int year;
  final double percent;
  final Map<String, List<int>> topics;

  const ExerciseCards({
    Key? key,
    required this.year,
    required this.percent,
    required this.topics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colorScheme.primaryFixed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onPrimaryFixedVariant, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "— $year —",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1,
              color: colorScheme.onPrimaryFixedVariant,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Circle
                CircularPercentIndicator(
                  radius: 30.0,
                  lineWidth: 6.0,
                  percent: percent,
                  center: Text(
                    "${(percent * 100).round()}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: colorScheme.onPrimaryFixedVariant,
                    ),
                  ),
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  progressColor: colorScheme.onPrimaryFixedVariant,
                  circularStrokeCap: CircularStrokeCap.round,
                ),

                const SizedBox(width: 50),
                // Topics List
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      topics.entries.map((entry) {
                        final String topic = entry.key;
                        final int done = entry.value[0];
                        final int total = entry.value[1];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("$done/$total ", style: smallTextStyle),
                              Text(
                                topic,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onPrimaryFixedVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
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

class MainSurfaceCard extends StatelessWidget {
  const MainSurfaceCard({
    super.key,
    required this.title,
    required this.boxFlex,
    required this.child,
  });

  final String title;
  final int boxFlex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      flex: boxFlex,
      child: Column(
        children: [
          Text(title, style: kHeaderStyle),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryToggleBar extends StatefulWidget {
  final List<String> categories;
  final List<String> selected;
  final void Function(List<String>) onSelectionChanged;

  const CategoryToggleBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  State<CategoryToggleBar> createState() => _CategoryToggleBarState();
}

class _CategoryToggleBarState extends State<CategoryToggleBar> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = [...widget.selected];
  }

  void toggleCategory(String category) {
    setState(() {
      if (selected.contains(category)) {
        selected.remove(category);
      } else {
        selected.add(category);
      }
      widget.onSelectionChanged(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.onPrimaryFixedVariant, width: 2),
        borderRadius: BorderRadius.circular(40),
        color: colorScheme.primaryContainer,
      ),
      child: Row(
        children:
            widget.categories.map((category) {
              final isSelected = selected.contains(category);
              return Expanded(
                child: GestureDetector(
                  onTap: () => toggleCategory(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? colorScheme.onPrimaryFixedVariant
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check,
                          size: 18,
                          color:
                              isSelected
                                  ? whiteColor
                                  : colorScheme.onPrimaryFixedVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? whiteColor
                                    : colorScheme.onPrimaryFixedVariant,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class CustomTaskCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> tags;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        border: Border.all(color: colorScheme.onPrimaryFixedVariant, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children:
                tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tagColors[tag],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tag, style: lableTextStyle),
                  );
                }).toList(),
          ),
          const SizedBox(height: 10),
          Text(title, style: kHeaderStyle),
          const SizedBox(height: 6),
          Text(description, style: middleTextStyle),
        ],
      ),
    );
  }
}

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
