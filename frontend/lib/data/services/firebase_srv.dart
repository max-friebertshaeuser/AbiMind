import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/core/utils/constants.dart';
import 'package:frontend/data/models/exercise.dart';
import 'package:frontend/data/models/question.dart';

import '../models/exam.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<Exam>> getExams() async {
    try {
      final querySnapshot = await _db.collection(kAbitur).get();

      final List<Exam> exams = [];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;

          final exam = Exam.fromJson(data);

          exams.add(exam);
        } catch (e) {
          print('Error parsing exam ${doc.id}: $e');
          continue;
        }
      }

      exams.sort((a, b) => b.year!.compareTo(a.year!));
      return exams;

    } catch (e) {
      print('Error fetching exams: $e');
      return [];
    }
  }

  static Future<Exam?> getExam(String examId) async {
    try {
      final snapshot = await _db.collection(kExam).doc(examId).get();
      if (!snapshot.exists) {
        print('Exam with ID $examId does not exist.');
        return null;
      }

      final data = snapshot.data();
      final exercises = await fetchExercises(examId);

      return Exam(
        id: snapshot.id,
        year: int.parse(data?['year']),
        subject: data?['subject'],
        exercises: exercises,
      );
    } catch (e) {
      print('Error fetching exam: $e');
    }
    return null;
  }

  static Future<List<Question>> fetchQuestions(
    String examId,
    String exerciseId,
  ) async {
    try {
      final snapshot =
          await _db
              .collection(kAbitur)
              .doc(examId)
              .collection(kExercises)
              .doc(exerciseId)
              .collection(kQuestion)
              .get();
      return snapshot.docs
          .map((q) => Question.fromJson({...q.data(), 'id': q.id}))
          .toList();
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  static Future<List<Exercise>> fetchExercises(String examId) async {
    try {
      final snapshot =
          await _db.collection(kExam).doc(examId).collection(kExercises).get();
      final exercises =
          snapshot.docs
              .map((el) => Exercise.fromJson({...el.data(), 'id': el.id}))
              .toList();

      await Future.wait(
        exercises.map(
          (exercise) async =>
              exercise.questions = await fetchQuestions(examId, exercise.id),
        ),
      );

      return exercises;
    } catch (e) {
      print('Failed to fetch exercises: $e');
      return [];
    }
  }

  static Future<void> saveAnswers(Exam exam) async {
    for (var exercise in exam.exercises) {
      dynamic examRef =
          await _db
              .collection(kUser)
              .doc(_auth.currentUser?.uid)
              .collection(kExam)
              .doc(exam.id)
              .get();
      if (!examRef.exists) {
        print('Exam with ID ${exam.id} does not exist.');
      }
      if (exercise.answer.isNotEmpty) {
        await _db
            .collection(kUser)
            .doc(_auth.currentUser?.uid)
            .collection(kExam)
            .doc(exam.id)
            .collection(kExercises)
            .doc(exercise.id)
            .set({kAnswer: exercise.answer});
      }
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAnswers(String examId) async {
    try {
      final snapshot =
          await _db
              .collection('user')
              .doc(_auth.currentUser?.uid)
              .collection(kExam)
              .doc(examId)
              .collection(kExercises)
              .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching answers: $e');
      return [];
    }
  }
}
