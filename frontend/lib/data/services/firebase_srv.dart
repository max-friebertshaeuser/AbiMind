import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/core/utils/constants.dart';
import 'package:frontend/data/models/exercise.dart';
import 'package:frontend/data/models/question.dart';
import 'package:intl/intl.dart';

import '../models/exam.dart';
import '../models/streak.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<Exam>> getExams() async {
    try {
      final querySnapshot = await _db.collection(kExam).get();

      final exams = await Future.wait(
        querySnapshot.docs.map((doc) => Exam.fromSnapshot(doc)),
      );

      return exams;
    } catch (e) {
      print('Error fetching exams: $e');
      return [];
    }
  }

  static Future<Streak> getStreak(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('user').doc(userId);

    final userSnap = await userRef.get();
    if (!userSnap.exists) {

      return Streak(days: {}, goal: 0);
    }
    final data = userSnap.data()!;
    final int goal = (data['goal'] as num?)?.toInt() ?? 0;

    final logSnap = await userRef.collection('streakLog').get();

    final Map<DateTime, int> days = {};
    for (final doc in logSnap.docs) {
      DateTime day;
      try {
        day = DateTime.parse(doc.id);
      } catch (_) {
        final ts = doc.data()['date'];
        if (ts is Timestamp) {
          day = ts.toDate();
        } else {
          continue;
        }
      }
      final int mins = (doc.data()['minutes'] as num?)?.toInt() ?? 0;
      days[day] = mins;
    }
    return Streak(
      days: days,
      goal: goal,
    );
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

  static Future<List<Question>> fetchQuestions(DocumentReference exerciseRef) async {
    try {
      final snapshot = await exerciseRef.collection(kQuestion).get();
      if (snapshot.docs.isEmpty) {
        print('No questions found for exercise ${exerciseRef.id}');
        return [];
      }
      final questions = snapshot.docs.map((q) => Question.fromJson({...q.data(), 'id': q.id})).toList();
      return questions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  static Future<List<Exercise>> fetchExercises(String examId) async {
    try {
      final exercisesRef = _db
          .collection(kExam)
          .doc(examId)
          .collection(kExercises);
      final snapshot = await exercisesRef.get();
      List<Exercise> exercises =
          snapshot.docs
              .map((el) => Exercise.fromJson({...el.data(), 'id': el.id}))
              .toList();
      final answers = await fetchAnswers(examId);
      exercises =
          exercises.map((e) {
            e.answer = answers[e.id] ?? [];
            return e;
          }).toList();
      await Future.wait(
        exercises.map(
          (exercise) async =>
              exercise.questions = await fetchQuestions(
                exercisesRef.doc(exercise.id),
              ),
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
      dynamic examRef = await _db.collection(kUser).doc(_auth.currentUser?.uid).collection(kExam).doc(exam.id).get();
      if (exercise.answer.isNotEmpty) {
        await _db.collection(kUser).doc(_auth.currentUser?.uid).collection(kExam).doc(exam.id).collection(kExercises).doc(exercise.id).set({
          kAnswer: exercise.answer,
          kAnswerImage: exercise.getEncodedImage()
        });
      }
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> fetchAnswers(String examId) async {
    try {
      final snapshot = await _db
          .collection('user')
          .doc(_auth.currentUser?.uid)
          .collection(kExam)
          .doc(examId)
          .collection(kExercises)
          .get();

      Map<String, List<Map<String, dynamic>>> answers = {
        for (var doc in snapshot.docs)
          doc.id: (doc.data()['answer'] as List).cast<Map<String, dynamic>>(),
      };
      return answers;
    } catch (e) {
      print('Error fetching answers: $e');
      return {};
    }
  }
}
