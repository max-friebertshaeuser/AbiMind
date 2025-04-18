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
                          child: Container(
                            margin: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const ExerciseCards(
                              year: 2024,
                              percent: 0.65,
                              topics: {
                                'Stochastik': {0: 7, 1: 10},
                                'Analysis': {0: 8, 1: 10},
                                'Geometrie': {0: 10, 1: 10},
                              },
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
  final double percent; // between 0.0 and 1.0
  final Map<String, Map<int, int>> topics; // e.g. {'Stochastik': [2, 8]}

  const ExerciseCards({
    Key? key,
    required this.year,
    required this.percent,
    required this.topics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(year.toString(), style: kHeaderStyle),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: CircularPercentIndicator(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
              progressColor:
                  Theme.of(context).colorScheme.onPrimaryFixedVariant,
              radius: 70.0,
              lineWidth: 12.0,
              percent: percent,
              center: Text(
                "${(percent * 100).toStringAsFixed(0)}%",
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
                children:
                    topics.entries.map((entry) {
                      return CathegorieProgress(
                        title: entry.key,
                        done: entry.value[0] ?? 0,
                        total: entry.value[1] ?? 1, // Avoid division by zero
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
