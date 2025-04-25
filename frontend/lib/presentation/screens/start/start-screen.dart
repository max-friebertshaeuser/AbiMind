import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:frontend/core/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';

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
                children: [
                  Card(
                    title: 'Current Exercise',
                    boxFlex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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
                                  statistic['currentYear'].toString(),
                                  style: kHeaderStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: CircularPercentIndicator(
                                    backgroundColor:
                                        colorScheme.surfaceContainerHigh,
                                    progressColor:
                                        colorScheme.onPrimaryFixedVariant,
                                    // TODO : Change Import Stats
                                    radius: 70.0,
                                    lineWidth: 12.0,
                                    percent: double.parse(
                                      statistic['solvedPercentageNumeric']
                                          .toString(),
                                    ),
                                    center: Text(
                                      "${(statistic['solvedPercentage']).toString()}%",
                                      style: percentageStyle,
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                ),
                                Divider(thickness: 2),
                                Container(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: const [
                                        CategoryProgress(
                                          title: 'Stochastik',
                                          done: 7,
                                          total: 10,
                                        ),
                                        CategoryProgress(
                                          title: 'Analysis',
                                          done: 8,
                                          total: 10,
                                        ),
                                        CategoryProgress(
                                          title: 'Geometrie',
                                          done: 10,
                                          total: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 20.0,
                          ),
                          child: VerticalDivider(thickness: 2, width: 10),
                        ),
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.all(10.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  ExerciseCards(
                                    year: 2023,
                                    percent: 0.65,
                                    topics: {
                                      'Stochastik': [7, 10],
                                      'Analysis': [8, 10],
                                      'Geometrie': [10, 10],
                                    },
                                  ),
                                  ExerciseCards(
                                    year: 2024,
                                    percent: 0.65,
                                    topics: {
                                      'Stochastik': [7, 10],
                                      'Analysis': [8, 10],
                                      'Geometrie': [10, 10],
                                    },
                                  ),
                                  ExerciseCards(
                                    year: 2025,
                                    percent: 0.75,
                                    topics: {
                                      'Stochastik': [8, 10],
                                      'Analysis': [9, 10],
                                      'Geometrie': [10, 10],
                                    },
                                  ),
                                  ExerciseCards(
                                    year: 2026,
                                    percent: 0.85,
                                    topics: {
                                      'Stochastik': [9, 10],
                                      'Analysis': [10, 10],
                                      'Geometrie': [10, 10],
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    title: 'Streak',
                    boxFlex: 1,
                    child: Row(
                      children: [
                        // Left side: Fire icon and streak info
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    streak['streak'].toString(),
                                    style: kHeaderStyle,
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.local_fire_department,
                                    color: colorScheme.onPrimaryFixedVariant,
                                    size: 32,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Du hast dein\nLernziel ${streak['streak'].toString()} Tage\nlang erreicht',
                                  style: smallTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right side: Dots and line chart
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.symmetric(
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
                                  // allows room below baseline
                                  maxY: maxMinutes + 10,
                                  // allows room above baseline
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots:
                                          tenDayLearnProgress
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                                final index =
                                                    entry.key.toDouble();
                                                final minutes =
                                                    entry.value['minutes']
                                                        as int;
                                                return FlSpot(
                                                  index,
                                                  minutes.toDouble(),
                                                );
                                              })
                                              .toList(),
                                      isCurved: false,
                                      isStrokeCapRound: false,
                                      barWidth: 0,
                                      color: Colors.transparent,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (
                                              spot,
                                              percent,
                                              barData,
                                              index,
                                            ) => FlDotCirclePainter(
                                              radius: 4,
                                              color:
                                                  colorScheme
                                                      .onPrimaryFixedVariant,
                                              strokeWidth: 0,
                                            ),
                                      ),
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                  extraLinesData: ExtraLinesData(
                                    horizontalLines: [
                                      HorizontalLine(
                                        y: double.parse(
                                          streak['goal'].toString(),
                                        ),
                                        color:
                                            colorScheme.onPrimaryFixedVariant,
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
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Card(
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
                                children: [
                                  CustomTaskCard(
                                    title: 'Textaufgabe',
                                    description:
                                        'Untersuche eine Pyramide geometrisch, bestimme Flächen, Symmetrien, Ebenen und einen speziellen Punkt, und beschreibe den entstehenden Rotationskörper.',
                                    tags: [
                                      'Finished',
                                      'Geometrie',
                                      'Keine Hilfsmittel',
                                    ],
                                  ),
                                  CustomTaskCard(
                                    title: 'Ohne Anwendung',
                                    description:
                                        'Untersuche eine Funktion, bestimme Extremstellen, Wendepunkte und Flächeninhalte, und interpretiere alles im Sachzusammenhang.',
                                    tags: ['Analysis', 'Alle Hilfsmittel'],
                                  ),
                                  CustomTaskCard(
                                    title: 'Textaufgabe',
                                    description:
                                        'Beschreibe die geometrischen Eigenschaften einer Pyramide, analysiere Symmetrien und konstruiere den Rotationskörper.',
                                    tags: ['Geometrie', 'Keine Hilfsmittel'],
                                  ),
                                  CustomTaskCard(
                                    title: 'Ohne Anwendung',
                                    description:
                                        'Berechne die Extrempunkte und Wendepunkte einer Funktion und deute sie im gegebenen Kontext.',
                                    tags: ['Analysis', 'Alle Hilfsmittel'],
                                  ),
                                  CustomTaskCard(
                                    title: 'Textaufgabe',
                                    description:
                                        'Analysiere die Pyramidenstruktur geometrisch, leite Rotationskörper ab und bestimme charakteristische Punkte.',
                                    tags: ['Geometrie', 'Keine Hilfsmittel'],
                                  ),
                                  CustomTaskCard(
                                    title: 'Ohne Anwendung',
                                    description:
                                        'Finde die Flächeninhalte unter einer Kurve, berechne Extremwerte und interpretiere die Ergebnisse sachlich.',
                                    tags: ['Analysis', 'Alle Hilfsmittel'],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CategoryToggleBar(
                      categories: ['Geometrie', 'Analysis', 'Statistics'],
                      selected: ['Geometrie', 'Analysis'], // initial selected
                      onSelectionChanged: (selected) {
                        // TODO: update your filtering logic here
                        print('Selected categories: $selected');
                      },
                    ),
                  ],
                ),
              ),
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
          // Year Centered
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

class Card extends StatelessWidget {
  const Card({
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
                                  ? Colors.white
                                  : colorScheme.onPrimaryFixedVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
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
