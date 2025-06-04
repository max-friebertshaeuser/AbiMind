import 'package:Abimind/data/models/exercise.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/constants.dart';
import '../../../../data/models/progress.dart';
import '../../../../data/services/firebase_srv.dart';
import '../../../../routes/routes.dart';
import '../../exercise/exercise_screen.dart';
import 'exercise_selection_bar.dart';
import 'main_surface_card.dart';

class ExerciseCardList extends StatefulWidget {
  @override
  _ExerciseCardListState createState() => _ExerciseCardListState();
}

class ExerciseWithExamDate {
  final Exercise exercise;
  final int year;
  final String examId;

  ExerciseWithExamDate({
    required this.exercise,
    required this.year,
    required this.examId,
  });
}

class _ExerciseCardListState extends State<ExerciseCardList>
    with WidgetsBindingObserver {
  List<ExerciseTopic> selectedCategories = [ExerciseTopic.mandatory];
  List<ExerciseWithExamDate> exercisesWithDate = [];
  Progress progressData = Progress(examProgress: {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTaskCardsData(); // Loads exercises and progress on first launch
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshProgressOnly();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      refreshProgressOnly(); // Reload progress when returning to this screen
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> refreshProgressOnly() async {
    try {
      var userId = FirebaseAuth.instance.currentUser?.uid ?? 'testUserId';
      final progress = await FirebaseService.getProgress();
      setState(() {
        progressData = progress;
      });
    } catch (e) {
      print('Error refreshing progress: $e');
    }
  }

  Future<void> loadTaskCardsData() async {
    try {
      final exams = await FirebaseService.getExams();
      var userId = FirebaseAuth.instance.currentUser?.uid ?? 'testUserId';
      final progress = await FirebaseService.getProgress();
      final tempExercises = <ExerciseWithExamDate>[];
      for (final exam in exams) {
        for (final exercise in exam.exercises) {
          tempExercises.add(
            ExerciseWithExamDate(
              exercise: exercise,
              year: exam.year,
              examId: exam.id,
            ),
          );
        }
      }
      setState(() {
        exercisesWithDate = tempExercises;
        progressData = progress;
      });
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          final isDone = (progressData.examProgress[task.examId]?[task.exercise.id] ?? 0.0) >= 0.8;

                          return CustomTaskCard(
                            title: task.exercise.title,
                            description: task.exercise.shortDescription,
                            tags: getTags(
                              task.exercise.exerciseTopic,
                              task.exercise.id,
                              isDone,
                            ),
                            year: task.year.toString(),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.exercise,
                                arguments: ExerciseScreenArguments(
                                  examId: task.examId,
                                  exerciseId: task.exercise.id,
                                ),
                              );
                            },
                          );
                        },
                      )

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
      ),
    );
  }

  getTags(ExerciseTopic? exerciseTopic, String exerciseId, bool isDone) {
    List<String> tags = [];
    if (isDone) {
      tags.add('Finished');
    }
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
  final VoidCallback? onTap;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
    required this.year,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border.all(
            color: colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Tags
            Row(
              children: [
                Text(year, style: kHeaderStyle),
                const SizedBox(width: 8),
                Text(title, style: kHeaderStyle),
                Spacer(),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.end,
                  children:
                  tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tag, style: lableTextStyle),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
