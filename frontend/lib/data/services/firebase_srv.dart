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

  static Future<List<StreakDay>> getStreakRaw(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('user').doc(userId);

    // --- DEBUG: confirm user doc exists ---
    final userSnap = await userRef.get();
    if (!userSnap.exists) {
      print('🔥 getStreakRaw: user $userId does not exist!');
      return [];
    }

    // --- fetch the subcollection ---
    final logCollection = userRef.collection('streakLog');
    final logSnap = await logCollection.get();
    print('📄 getStreakRaw: found ${logSnap.docs.length} docs in streakLog for user $userId');

    final formatter = DateFormat('yyyy-MM-dd');
    final List<StreakDay> logs = [];

    for (final doc in logSnap.docs) {
      final data = doc.data();
      print('   • doc.id=${doc.id} data=$data');

      // try to parse the `date` field
      final rawTs = data['date'];
      if (rawTs is! Timestamp) {
        print('     ‼️ skipping ${doc.id}: `date` is not a Timestamp');
        continue;
      }
      final date = rawTs.toDate();

      // minutes & goal (fall back to zero if missing)
      final minutes = (data['minutes'] as num?)?.toInt() ?? 0;
      final goal    = (data['goal']    as num?)?.toInt() ?? 0;

      logs.add(StreakDay(date: date, minutes: minutes, goal: goal));
    }

    // sort by date ascending
    logs.sort((a, b) => a.date.compareTo(b.date));
    print('✅ getStreakRaw: returning ${logs.length} StreakDay entries');
    return logs;
  }

  static Future<List<StreakDay>> getStreakPadded(String userId) async {
    final raw = await getStreakRaw(userId);
    final formatter = DateFormat('yyyy-MM-dd');
    final byDate = { for (var d in raw) formatter.format(d.date): d };

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: 14));

    final defaultGoal = raw.isNotEmpty ? raw.last.goal : 0;
    final List<StreakDay> padded = [];
    for (int i = 0; i < 15; i++) {
      final day = start.add(Duration(days: i));
      final key = formatter.format(day);
      padded.add(
        byDate[key] ??
            StreakDay(date: day, minutes: 0, goal: defaultGoal),
      );
    }
    return padded;
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
