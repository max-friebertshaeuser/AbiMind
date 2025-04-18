import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:frontend/core/utils/constants.dart';

class StarScreen extends StatelessWidget {
  const StarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const TextStyle percentageStyle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFF584178),
    );

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
                                  style: kHeaderStyle
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child:CircularPercentIndicator(
                                    // TODO : Change Import Stats
                                    radius: 80.0,
                                    lineWidth: 12.0,
                                    percent: double.parse(statistic['solvedPercentageNumeric'].toString()),
                                    center: Text("${(statistic['solvedPercentage']).toString()}%", style: percentageStyle),
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                ),
                                Divider(thickness: 2),
                                Container(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: const [
                                        CathegorieProgress(title: 'Stochastik', done: 7, total: 10),
                                        CathegorieProgress(title: 'Analysis', done: 8, total: 10),
                                        CathegorieProgress(title: 'Geometrie', done: 10, total: 10),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
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
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF584178),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                "$done/$total",
                style: const TextStyle(fontSize: 11, color: Color(0xFF584178)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFD3BFFF), // Light pastel purple
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF584178),
              ), // Deep purple
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
          Text(
            title,
            style: kHeaderStyle
          ),
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
