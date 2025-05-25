import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/models/exercise.dart';
import 'package:frontend/presentation/screens/start/start-screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/utils/constants.dart';
import '../../../../data/services/firebase_srv.dart';
import 'exercise_selection_bar.dart';
import 'package:flutter_tex/flutter_tex.dart';

class ExerciseCardList extends StatefulWidget {
  @override
  _ExerciseCardListState createState() => _ExerciseCardListState();
}

class _ExerciseCardListState extends State<ExerciseCardList> {
  List<ExerciseTopic> selectedCategories = [ExerciseTopic.mandatory];
  List<Exercise> exercises = [];
  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    loadTaskCardsData();
  }

  Future<void> loadTaskCardsData() async {
    try {
      final exams = await FirebaseService.getExams();
      exams.forEach((exam) {
        exercises.addAll(exam.exercises);
      });
    } catch (e) {
      print('Error loading task cards data: $e');
    }
  }

  List<Exercise> get filteredTasks {
    return exercises.where((ex) {
      return selectedCategories.contains(ex.exerciseTopic);
    }).toList();
  }

  void onCategorySelectionChanged(List<ExerciseTopic> newSelection) {
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
                                title: task.title,
                                description: task.description,
                                tags: getTags(task.exerciseTopic, task.id),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CategoryToggleBar(
              categories: [
                ExerciseTopic.mandatory,
                ExerciseTopic.analysis,
                ExerciseTopic.stochastic,
                ExerciseTopic.geometry,
              ],
              selected: selectedCategories,
              onSelectionChanged: onCategorySelectionChanged,
            ),
          ],
        ),
      ),
    );
  }

  getTags(ExerciseTopic? exerciseTopic, String exerciseId) {
    //TODO: request if exercise is Done
    List<String> tags = [];
    switch (exerciseTopic) {
      case ExerciseTopic.mandatory:
        tags.add('Mandatory');
        tags.add('Keine Hilfsmittel');
        break;
      case ExerciseTopic.analysis:
        tags.add('Analysis');
        tags.add('Mit Hilfsmitteln');
        break;
      case ExerciseTopic.stochastic:
        tags.add('Stochastic');
        tags.add('Mit Hilfsmitteln');
        break;
      case ExerciseTopic.geometry:
        tags.add('Geometry');
        tags.add('Mit Hilfsmitteln');
        break;
      default:
        break;
    }
    return tags;
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
          // Tags
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
                      color: tagColors[tag] ?? Colors.blueGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tag, style: lableTextStyle),
                  );
                }).toList(),
          ),
          const SizedBox(height: 10),
          Text(title, style: kHeaderStyle),
          const SizedBox(height: 6),

          // LaTeX description using flutter_tex
          TeXView(
            child: TeXViewDocument(
              "description",
              style: TeXViewStyle(
                fontStyle: TeXViewFontStyle(fontSize: 14),
                padding: TeXViewPadding.all(0),
                margin: TeXViewMargin.all(0),
                contentColor: colorScheme.onSurface,
              ),
            ),
            style: TeXViewStyle(
              backgroundColor: Colors.transparent,
              elevation: 0,
              padding: TeXViewPadding.all(0),
            ),
            loadingWidgetBuilder:
                (_) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            onRenderFinished:
                (height) => debugPrint('TeXView rendered with height: $height'),
          ),
        ],
      ),
    );
  }
}
