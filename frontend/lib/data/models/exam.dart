import 'package:frontend/data/services/firebase_srv.dart';

import './exercise.dart';

class Exam {
  final String? id;
  final int? year;
  final String? subject;

  final List<Exercise>? analysisExercises;
  final List<Exercise>? geometryExercises;
  final List<Exercise>? stochasticExercises;
  final List<Exercise>? mandatoryExercises;

  final List<Exercise> exercises;

  Exam({
    this.id,
    this.year,
    this.subject,
    this.analysisExercises,
    this.geometryExercises,
    this.stochasticExercises,
    this.mandatoryExercises,
    this.exercises = const [],
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String,
      year: int.parse(json['year']),
      subject: json['subject'] as String,
      analysisExercises: (json['analysisExercises'] as List<dynamic>?)?.map((e) => Exercise.fromJson(e)).toList(),
      geometryExercises: (json['geometryExercises'] as List<dynamic>?)?.map((e) => Exercise.fromJson(e)).toList(),
      stochasticExercises: (json['stochasticExercises'] as List<dynamic>?)?.map((e) => Exercise.fromJson(e)).toList(),
      mandatoryExercises: (json['mandatoryExercises'] as List<dynamic>?)?.map((e) => Exercise.fromJson(e)).toList(),
      exercises: (json['exercises'] as List<dynamic>?)?.map((e) => Exercise.fromJson(e)).toList() ?? [],
    );
  }

  save() {
    FirebaseService.saveAnswers(this);
  }

  @override
  String toString() {
    return 'Exam{id: $id, year: $year, subject: $subject, analysisExercises: $analysisExercises, geometryExercises: $geometryExercises, stochasticExercises: $stochasticExercises, mandatoryExercises: $mandatoryExercises}, exercises: $exercises}';
  }
}
