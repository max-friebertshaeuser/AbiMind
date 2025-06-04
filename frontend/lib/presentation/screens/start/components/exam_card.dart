import 'package:Abimind/data/models/exam.dart';
import 'package:Abimind/data/models/progress.dart';
import 'package:Abimind/presentation/screens/start/components/progress_texts.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ExamCard extends StatelessWidget {
  final Exam stat;
  final bool isSelected;
  final Progress progressData;
  final VoidCallback onTap;

  const ExamCard({
    super.key,
    required this.stat,
    required this.isSelected,
    required this.progressData,
    required this.onTap,
  });

  int _loadProgressPercentage(Map<String, double> map, Exam stat) {
    if (map.isEmpty) return 0;
    final total = stat.exercises.length;
    if (total == 0) return 0;
    final done = map.values.where((p) => p >= 0.8).length;
    final percentage = ((done / total) * 100).round();
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _loadProgressPercentage(progressData.examProgress[stat.id] ?? {}, stat);
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onPrimaryFixedVariant, width: 2),
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isSelected
                  ? [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4, offset: Offset(4, 4)),
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4, offset: Offset(-1, -1))]
                  : [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("— ${stat.year} —", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularPercentIndicator(
                  backgroundColor: colorScheme.inversePrimary,
                  progressColor: colorScheme.primary,
                  radius: 30.0,
                  lineWidth: 4.0,
                  percent: progress / 100.0,
                  center: Text(
                    "$progress %",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 20),
                ProgressTexts(stat: stat, progressData: progressData, textColor: textColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
