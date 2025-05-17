import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/models/exercise.dart';
import 'package:frontend/presentation/screens/start/start-screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/utils/constants.dart';
import '../../../../data/models/exam.dart';
import '../../../../data/services/firebase_srv.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({Key? key}) : super(key: key);

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  List<Exam> statisticsData = [];
  late Exam selectedExam;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      final exams = await FirebaseService.getExams();

      setState(() {
        statisticsData = exams;
        if (exams.isNotEmpty) {
          selectedExam = exams.firstWhere(
                (exam) => exam.year == 2025,
            orElse: () => exams.first,
          );
        }
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading statistics: $e");
      setState(() {
        isLoading = false;
      });
    }
  }



  void selectStatistic(Exam stat) {
    setState(() {
      selectedExam = stat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (statisticsData.isEmpty) {
      return MainSurfaceCard(
        title: 'Current Exercise',
        boxFlex: 2,
        child: Center(
          child: Text(
            'Keine Daten verfügbar.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (statisticsData.isEmpty) {
      return MainSurfaceCard(
        title: 'Current Exercise',
        boxFlex: 2,
        child: Center(
          child: Text(
            'Keine Daten verfügbar.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }


    return MainSurfaceCard(
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
              // 👈 Wrap the entire left side in a scroll view
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(selectedExam.year.toString(), style: kHeaderStyle),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CircularPercentIndicator(
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      progressColor: colorScheme.onPrimaryFixedVariant,
                      radius: 70.0,
                      lineWidth: 12.0,
                      percent: 0.0, // update as needed
                      center: Text("0%", style: percentageStyle),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ),
                  const Divider(thickness: 2),
                  Column(
                    children: [
                      CategoryProgress(
                        title: 'Stochastik',
                        done: 0,
                        total: selectedExam.exercises
                            .where((e) => e.exerciseTopic == ExerciseTopic.stochastic)
                            .length,
                      ),
                      CategoryProgress(
                        title: 'Analysis',
                        done: 0,
                        total: selectedExam.exercises
                            .where((e) => e.exerciseTopic == ExerciseTopic.analysis)
                            .length,
                      ),
                      CategoryProgress(
                        title: 'Geometrie',
                        done: 0,
                        total: selectedExam.exercises
                            .where((e) => e.exerciseTopic == ExerciseTopic.geometry)
                            .length,
                      ),
                      CategoryProgress(
                        title: 'Pflichtaufgaben',
                        done: 0,
                        total: selectedExam.exercises
                            .where((e) => e.exerciseTopic == ExerciseTopic.mandatory)
                            .length,
                      ),
                    ],
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
                  final isSelected = stat.year == selectedExam.year;
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
                            "— ${stat.year} —",
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
                                //TODO insert real percentage
                                percent: double.parse(0.0.toString()),
                                center: Text(
                                  "${0.0}%",
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
                                    "${0.0}/${stat.exercises.where((exercise) => exercise.exerciseTopic == ExerciseTopic.stochastic)} Stochastik",
                                    style: TextStyle(
                                      color:
                                      isSelected
                                          ? colorScheme
                                          .onPrimaryContainer
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "${0.0}/${stat.exercises.where((exercise) => exercise.exerciseTopic == ExerciseTopic.analysis)} Analysis",
                                    style: TextStyle(
                                      color:
                                      isSelected
                                          ? colorScheme
                                          .onPrimaryContainer
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "${0.0}/${stat.exercises..where((exercise) => exercise.exerciseTopic == ExerciseTopic.geometry)} Geometrie",
                                    style: TextStyle(
                                      color:
                                      isSelected
                                          ? colorScheme
                                          .onPrimaryContainer
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "${0.0}/${stat.exercises..where((exercise) => exercise.exerciseTopic == ExerciseTopic.mandatory)} Pflichtaufgaben",
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
    final colorScheme = Theme.of(context).colorScheme;
    // avoid division by zero:
    final double? progress = (total > 0)
        ? done / total
        : 0.0; // or `null` if you want an indeterminate bar

    return Container(
      margin: const EdgeInsets.all(5.0),
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
              // only pass a value when it's valid:
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
