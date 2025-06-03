import 'package:Abimind/core/utils/constants.dart';
import 'package:Abimind/data/models/exam.dart';
import 'package:Abimind/data/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

class CorrectionView extends StatelessWidget {
  const CorrectionView({super.key, required this.exam, required this.exercise, required this.correction});

  final Exam exam;
  final Exercise exercise;
  final Map<String, dynamic>? correction;

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
    if (correction == null || !correction!.containsKey(kCorrection)) {
      return const Center(child: Text('No correction available'));
    }
    exercise.questions =
        exercise.questions.map((q) {
          q.correction = correction![kCorrection][q.id];
          return q;
        }).toList();

    final corrections =
        exercise.questions
            .map((q) {
              return '${q.title}) ${q.correction}';
            })
            .map((q) => wrapInlineMath(q))
            .map((q) => TeXViewDocument(q))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise Title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(exercise.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        // Exercise Description with LaTeX rendering
        Padding(
          padding: EdgeInsetsGeometry.all(4.0),
          child: Column(
            children: [
              // ...exercise.getImages().map(
              //   (bytes) => Image.memory(bytes, fit: BoxFit.contain, height: 200, width: double.infinity),
              // ),

              TeXView(
                key: ValueKey('questions'),
                child: TeXViewColumn(
                  children: [
                    // TeXViewDocument(wrapInlineMath(exercise.description)),

                    if (exercise.questions.isNotEmpty) ...corrections,
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
