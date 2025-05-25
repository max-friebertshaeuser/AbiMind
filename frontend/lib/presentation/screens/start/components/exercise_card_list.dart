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

class ExerciseWithExamDate {
  final Exercise exercise;
  final int year; // or DateTime date;

  ExerciseWithExamDate({required this.exercise, required this.year});
}

class _ExerciseCardListState extends State<ExerciseCardList> {
  List<ExerciseTopic> selectedCategories = [ExerciseTopic.mandatory];
  List<ExerciseWithExamDate> exercisesWithDate = [];

  @override
  void initState() {
    super.initState();
    loadTaskCardsData();
  }

  Future<void> loadTaskCardsData() async {
    try {
      final exams = await FirebaseService.getExams();
      for (final exam in exams) {
        for (final exercise in exam.exercises) {
          exercisesWithDate.add(
            ExerciseWithExamDate(
              exercise: exercise,
              year: exam.year, // or exam.date
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading task cards data: $e');
    }
  }

  List<ExerciseWithExamDate> get filteredTasks {
    return exercisesWithDate.where((ex) {
      return selectedCategories.contains(ex.exercise.exerciseTopic);
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
                                title: task.exercise.title,
                                description: task.exercise.description,
                                tags: getTags(
                                  task.exercise.exerciseTopic,
                                  task.exercise.id,
                                ),
                                year: task.year.toString(),
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
    //TODO: request if exercise is Done set Done
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

class CustomTaskCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> tags;
  final String year;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
    required this.year,
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
                  final color =
                      tagColors[tag] ??
                      Colors.blueGrey; // tagColors from constants.dart
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(tag, style: lableTextStyle),
                  );
                }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(year, style: kHeaderStyle),
              const SizedBox(width: 8),
              Text(title, style: kHeaderStyle),

            ],
          ),
          const SizedBox(height: 6),

          // Use a simple Text widget for the description instead of TeXView
          Text(
            description,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          ),
          /*         TeXView(
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
          ),*/
        ],
      ),
    );
  }
}
