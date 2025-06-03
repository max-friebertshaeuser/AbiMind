import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

import '../../../data/models/exam.dart';
import '../../../data/models/exercise.dart';

class ExerciseView extends StatelessWidget {
  final Exam exam;
  final Exercise currentExercise;

  const ExerciseView({Key? key, required this.exam, required this.currentExercise}) : super(key: key);

  String wrapInlineMath(String text) {
    if (text.isEmpty) return '';
    // Replace single-dollar patterns with \(...\). Be careful not to
    // match escaped dollars. This is a simple regex; adjust if needed.
    var res =
        '<p> ${text.replaceAllMapped(RegExp(r'\$(.+?)\$'), (match) {
          if (match.group(1)!.contains(r'\begin')) {
            return r'$$' + match.group(1)! + r'$$'; // Return the original match
          } else {
            return r'\(' + match.group(1)! + r'\)';
          }
        })} </p>';
    // res.replaceAllMapped(
    //     RegExp(r'\\begin\{([^\}]+)\}([\s\S]*?)\\end\{\1\}'), (match) => r'$$' + match.group(1)! + r'$$');
    res = res.replaceAll(r'\\ ', r''); // Remove unnecessary backslashes
    return res;
  }

  @override
  Widget build(BuildContext context) {

    final questions =
        currentExercise.questions!
            .map((q) => '${q.title}) ${q.description}')
            .map((q) => wrapInlineMath(q))
            .map((q) => TeXViewDocument(q))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise Title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(currentExercise.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),

        // Exercise Description with LaTeX rendering
        Padding(
          padding: EdgeInsetsGeometry.all(4.0),
          child: Column(
            children: [
              ...currentExercise.getImages().map(
                (bytes) => Image.memory(bytes, fit: BoxFit.contain, height: 200, width: double.infinity),
              ),

              TeXView(
                key: ValueKey('questions'),
                child: TeXViewColumn(
                  children: [
                    TeXViewDocument(wrapInlineMath(currentExercise.description)),

                    if (currentExercise.questions != null && currentExercise.questions!.isNotEmpty) ...questions,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
