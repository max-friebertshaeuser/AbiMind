import 'dart:convert';                      // ← for JsonEncoder
import 'package:cloud_firestore/cloud_firestore.dart';
import './exercise.dart';
import '../services/firebase_srv.dart';

class Exam {
  final String id;
  final int year;
  final String subject;

  final List<Exercise> analysisExercises;
  final List<Exercise> geometryExercises;
  final List<Exercise> stochasticExercises;
  final List<Exercise> mandatoryExercises;

  final List<Exercise> exercises;

  Exam({
    required this.id,
    required this.year,
    required this.subject,
    this.analysisExercises = const [],
    this.geometryExercises = const [],
    this.stochasticExercises = const [],
    this.mandatoryExercises = const [],
    this.exercises = const [],
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String,
      year: int.parse(json['year'] as String),
      subject: json['subject'] as String,
    );
  }

  /// loads the one "exercises" subcollection, dumps raw JSON, then splits by topic
  static Future<Exam> fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    if (data == null) throw StateError('No data for Exam ${doc.id}');
    data['id'] = doc.id;
    final base = Exam.fromJson(data);

    final exSnap = await doc.reference.collection('exercises').get();

    final all = <Exercise>[];
    for (final ed in exSnap.docs) {
      final raw = Map<String, dynamic>.from(ed.data())..['id'] = ed.id;
      all.add(Exercise.fromJson(raw));
    }

    final analysis   = all.where((e) => e.exerciseTopic == ExerciseTopic.analysis).toList();
    final geometry   = all.where((e) => e.exerciseTopic == ExerciseTopic.geometry).toList();
    final stochastic = all.where((e) => e.exerciseTopic == ExerciseTopic.stochastic).toList();
    final mandatory  = all.where((e) => e.exerciseTopic == ExerciseTopic.mandatory).toList();

    return Exam(
      id: base.id,
      year: base.year,
      subject: base.subject,
      analysisExercises:  analysis,
      geometryExercises:  geometry,
      stochasticExercises:stochastic,
      mandatoryExercises: mandatory,
      exercises: all,
    );
  }

  Future<void> save() async {
    await FirebaseService.saveAnswers(this);

  }

  @override
  String toString() =>
      'Exam($id, $year, $subject): total=${exercises.length} '
          '[analysis=${analysisExercises.length} '
          'geometry=${geometryExercises.length} '
          'stochastic=${stochasticExercises.length} '
          'mandatory=${mandatoryExercises.length}]';
}
