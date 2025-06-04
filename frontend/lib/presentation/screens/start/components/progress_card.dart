import 'package:Abimind/data/models/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/utils/constants.dart';
import '../../../../data/models/exam.dart';
import '../../../../data/models/exercise.dart';
import '../../../../data/services/firebase_srv.dart';
import '../../../../routes/routes.dart';
import '../../exercise/exercise_screen.dart';
import 'category_progress.dart';
import 'exam_card.dart';
import 'main_surface_card.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({Key? key}) : super(key: key);

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard>
    with WidgetsBindingObserver {
  List<Exam> statisticsData = [];
  late Exam selectedExam;
  bool isLoading = true;
  Progress progressData = Progress(examProgress: {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadStatistics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      refreshProgressOnly();
    }
  }

  Future<void> refreshProgressOnly() async {
    try {
      var userId = FirebaseAuth.instance.currentUser?.uid ?? 'testUserId';
      final newProgress = await FirebaseService.getProgress();
      setState(() {
        progressData = newProgress;
      });
    } catch (e) {
      print('Error refreshing progress: $e');
    }
  }

  Future<void> loadStatistics() async {
    try {
      var userId = FirebaseAuth.instance.currentUser?.uid ?? 'testUserId';
      progressData = await FirebaseService.getProgress();
      final exams = await FirebaseService.getExams();
      setState(() {
        statisticsData = exams;
        if (exams.isNotEmpty) {
          selectedExam = exams.firstWhere(
            (exam) => exam.year == DateTime.now().year,
            orElse: () => exams.first,
          );
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void selectStatistic(Exam stat) {
    setState(() => selectedExam = stat);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return MainSurfaceCard(
        title: 'Current Exercise',
        boxFlex: 2,
        child: Center(
            child: CircularProgressIndicator()
        ),
      );
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(selectedExam.year.toString(), style: kHeaderStyle),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CircularPercentIndicator(
                            backgroundColor: colorScheme.inversePrimary,
                            progressColor: colorScheme.primary,
                            radius: 70.0,
                            lineWidth: 8.0,
                            percent:
                            _loadProgressPercentage(
                              progressData.examProgress[selectedExam.id] ??
                                  {},
                              selectedExam,
                            ) /
                                100.0,
                            // Convert from percentage to decimal
                            center: Text(
                              "${_loadProgressPercentage(
                                  progressData.examProgress[selectedExam.id] ?? {}, selectedExam)} %",
                              style: percentageStyle,
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                        ),
                        Divider(thickness: 2, color: colorScheme.primary),
                        Column(
                          children: [
                            CategoryProgress(
                              title: 'Stochastik',
                              done: _calculateCategoryDone(
                                progressData.examProgress,
                                selectedExam,
                                ExerciseTopic.stochastic,
                              ),
                              total:
                              selectedExam.exercises
                                  .where(
                                    (e) =>
                                e.exerciseTopic ==
                                    ExerciseTopic.stochastic,
                              )
                                  .length,
                            ),
                            CategoryProgress(
                              title: 'Analysis',
                              done: _calculateCategoryDone(
                                progressData.examProgress,
                                selectedExam,
                                ExerciseTopic.analysis,
                              ),
                              total:
                              selectedExam.exercises
                                  .where(
                                    (e) =>
                                e.exerciseTopic ==
                                    ExerciseTopic.analysis,
                              )
                                  .length,
                            ),
                            CategoryProgress(
                              title: 'Geometrie',
                              done: _calculateCategoryDone(
                                progressData.examProgress,
                                selectedExam,
                                ExerciseTopic.geometry,
                              ),
                              total:
                              selectedExam.exercises
                                  .where(
                                    (e) =>
                                e.exerciseTopic ==
                                    ExerciseTopic.geometry,
                              )
                                  .length,
                            ),
                            CategoryProgress(
                              title: 'Mandatory',
                              done: _calculateCategoryDone(
                                progressData.examProgress,
                                selectedExam,
                                ExerciseTopic.mandatory,
                              ),
                              total:
                              selectedExam.exercises
                                  .where(
                                    (e) =>
                                e.exerciseTopic ==
                                    ExerciseTopic.mandatory,
                              )
                                  .length,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // vertical divider
                Container(
                  // margin: const EdgeInsets.symmetric(
                  //   horizontal: 10.0,
                  // ),
                  child: VerticalDivider(thickness: 2, width: 10, color: colorScheme.primary,),
                ),

                // right side: scrollable mini cards
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ListView.builder(
                      itemCount: statisticsData.length,
                      itemBuilder: (context, index) {
                        final stat = statisticsData[index];
                        return ExamCard(
                          stat: stat,
                          isSelected: stat.year == selectedExam.year,
                          progressData: progressData,
                          onTap: () => selectStatistic(stat),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.small(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.exercise,
                  arguments: ExerciseScreenArguments(examId: selectedExam.id),
                );
              },
              backgroundColor: colorScheme.primary,
              elevation: 2,
              heroTag: null,
              child: Icon(Icons.edit, size: 18, color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }


}

int _loadProgressPercentage(Map<String, double> map, Exam stat) {
  if (map.isEmpty) return 0;
  final total = stat.exercises.length;
  if (total == 0) return 0;
  final done = map.values
      .where((p) => p >= 0.8)
      .length;
  final percentage = ((done / total) * 100).round();
  return percentage;
}

int _calculateCategoryDone(
  Map<String, dynamic> progressData,
  Exam selectedExam,
  ExerciseTopic category,
) {
  final exercises = selectedExam.exercises.where(
    (e) => e.exerciseTopic == category,
  );
  final Map<String, double> exercisesProgress =
      progressData[selectedExam.id] ?? {};
  int doneCount = 0;
  for (var exercise in exercises) {
    final progress = exercisesProgress[exercise.id] ?? 0.0;
    if (progress >= 0.8) {
      doneCount++;
    }
  }
  return doneCount;
}


// Widget aahhhhh(){
//   return SingleChildScrollView(
//     child: Column(
//       children:
//       statisticsData.map((stat) {
//         final isSelected = stat.year == selectedExam.year;
//         return GestureDetector(
//           onTap: () => selectStatistic(stat),
//           child: Container(
//             width: double.infinity,
//             margin: const EdgeInsets.symmetric(
//               vertical: 8.0,
//               horizontal: 12.0,
//             ),
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: colorScheme.onPrimaryFixedVariant,
//                 width: 2,
//               ),
//               color:
//               isSelected
//                   ? colorScheme.primaryContainer
//                   .withOpacity(0.5)
//                   : colorScheme.primaryContainer,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 6,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "— ${stat.year} —",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color:
//                     isSelected
//                         ? colorScheme.onPrimaryContainer
//                         : colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularPercentIndicator(
//                       backgroundColor: colorScheme.surfaceContainerHigh,
//                       progressColor: colorScheme.onPrimaryFixedVariant,
//                       radius: 30.0,
//                       lineWidth: 8.0,
//                       percent: _loadProgressPercentage(progressData.examProgress[stat.id] ?? {}, stat) / 100.0,  // Convert from percentage to decimal
//                       center: Text(
//                         "${_loadProgressPercentage(progressData.examProgress[stat.id] ?? {}, stat)} %",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: isSelected
//                               ? colorScheme.onPrimaryContainer
//                               : colorScheme.onSurface,
//                         ),
//                       ),
//                       circularStrokeCap: CircularStrokeCap.round,
//                     ),
//                     const SizedBox(width: 20),
//                     Column(
//                       crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "${_calculateCategoryDone(progressData.examProgress, stat, ExerciseTopic.stochastic)}/${stat.stochasticExercises.length} Stochastik",
//                           style: TextStyle(
//                             color:
//                             isSelected
//                                 ? colorScheme
//                                 .onPrimaryContainer
//                                 : colorScheme.onSurface,
//                           ),
//                         ),
//                         Text(
//                           "${_calculateCategoryDone(progressData.examProgress, stat, ExerciseTopic.analysis)}/${stat.analysisExercises.length} Analysis",
//                           style: TextStyle(
//                             color:
//                             isSelected
//                                 ? colorScheme
//                                 .onPrimaryContainer
//                                 : colorScheme.onSurface,
//                           ),
//                         ),
//                         Text(
//                           "${_calculateCategoryDone(progressData.examProgress, stat, ExerciseTopic.geometry)}/${stat.geometryExercises.length} Geometrie",
//                           style: TextStyle(
//                             color:
//                             isSelected
//                                 ? colorScheme
//                                 .onPrimaryContainer
//                                 : colorScheme.onSurface,
//                           ),
//                         ),
//                         Text(
//                           "${_calculateCategoryDone(progressData.examProgress, stat, ExerciseTopic.mandatory)}/${stat.mandatoryExercises.length} Mandatory",
//                           style: TextStyle(
//                             color:
//                             isSelected
//                                 ? colorScheme
//                                 .onPrimaryContainer
//                                 : colorScheme.onSurface,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     ),
//   );
// }
