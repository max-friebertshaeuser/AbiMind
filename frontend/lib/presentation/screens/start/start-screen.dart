import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:frontend/core/utils/constants.dart';

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
                                        CathegorieProgress(
                                          title: 'Stochastik',
                                          done: 7,
                                          total: 10,
                                        ),
                                        CathegorieProgress(
                                          title: 'Analysis',
                                          done: 8,
                                          total: 10,
                                        ),
                                        CathegorieProgress(
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
                              margin: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                // <- Wrap your cards inside a Column
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 0, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
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
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.onPrimaryFixedVariant,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 5,
              ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Circle
                  CircularPercentIndicator(
                    radius: 20.0,
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
                  const SizedBox(width: 16),
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
                                Text(
                                  "$done/$total ",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onPrimaryFixedVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class CathegorieProgress extends StatelessWidget {
  final String title;
  final int done;
  final int total;

  const CathegorieProgress({
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onPrimaryFixedVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                "$done/$total",
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onPrimaryFixedVariant,
                ),
              ),
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
