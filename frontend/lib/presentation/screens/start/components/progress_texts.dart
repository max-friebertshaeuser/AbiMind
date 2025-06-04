import 'package:Abimind/data/models/progress.dart';
import 'package:flutter/cupertino.dart';

import '../../../../data/models/exam.dart';
import '../../../../data/models/exercise.dart';

class ProgressTexts extends StatelessWidget {
  final Exam stat;
  final Progress progressData;
  final Color textColor;

  const ProgressTexts({
    required this.stat,
    required this.progressData,
    required this.textColor,
  });

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

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: textColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_calculateCategoryDone(progressData.examProgress, stat, ExerciseTopic.stochastic)}/${stat.stochasticExercises.length} Stochastik",
          style: style,
        ),
        Text(
          "${_calculateCategoryDone(progressData.examProgress, stat, ExerciseTopic.analysis)}/${stat.analysisExercises.length} Analysis",
          style: style,
        ),
        Text(
          "${_calculateCategoryDone(progressData.examProgress, stat, ExerciseTopic.geometry)}/${stat.geometryExercises.length} Geometrie",
          style: style,
        ),
        Text(
          "${_calculateCategoryDone(progressData.examProgress, stat, ExerciseTopic.mandatory)}/${stat.mandatoryExercises.length} Mandatory",
          style: style,
        ),
      ],
    );
  }
}
