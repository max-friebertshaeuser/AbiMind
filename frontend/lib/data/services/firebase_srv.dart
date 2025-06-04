import 'package:Abimind/core/utils/constants.dart';
import 'package:Abimind/data/models/exercise.dart';
import 'package:Abimind/data/models/question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/exam.dart';
import '../models/progress.dart';
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
      exams.sort((a, b) => a.year.compareTo(b.year));
      return exams;
    } catch (e) {
      print('Error fetching exams: $e');
      return [];
    }
  }

  static Future<Progress> getProgress({bool forceRefresh = false}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance.collection(kUser).doc(userId);
    final userSnap = await userRef.get();
    if (!userSnap.exists) return Progress(examProgress: {});

    final examSnap = await userRef.collection(kExam).get();
    final examDocs = examSnap.docs;

    final futures =
        examDocs.map((examDoc) async {
          final exerSnap = await examDoc.reference.collection(kExercises).get();
          final Map<String, double> progressMap = {
            for (final exDoc in exerSnap.docs)
              exDoc.id: (exDoc.data()[kScore] as num? ?? 0).toDouble(),
          };
          return MapEntry(examDoc.id, progressMap);
        }).toList();

    final entries = await Future.wait(futures);

    final Map<String, Map<String, double>> examProgress = {
      for (final e in entries) e.key: e.value,
    };
    return Progress(examProgress: examProgress);
  }

  static Future<Streak> getStreak(String userId) async {
    final userRef = FirebaseFirestore.instance.collection(kUser).doc(userId);

    final userSnap = await userRef.get();
    if (!userSnap.exists) {
      return Streak(days: {}, goal: 0);
    }
    final data = userSnap.data()!;
    final int goal = (data[kGoal] as num?)?.toInt() ?? 0;

    final logSnap = await userRef.collection(kStreakLog).get();

    final Map<DateTime, int> days = {};
    for (final doc in logSnap.docs) {
      DateTime day;
      try {
        day = DateTime.parse(doc.id);
      } catch (_) {
        final ts = doc.data()[kDate];
        if (ts is Timestamp) {
          day = ts.toDate();
        } else {
          continue;
        }
      }
      final int mins = (doc.data()[kMinutes] as num?)?.toInt() ?? 0;
      days[day] = mins;
    }
    return Streak(days: days, goal: goal);
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
        year: int.parse(data?[kYear]),
        subject: data?[kSubject],
        exercises: exercises,
      );
    } catch (e) {
      print('Error fetching exam: $e');
    }
    return null;
  }

  static Future<List<Question>> fetchQuestions(
    DocumentReference exerciseRef,
  ) async {
    try {
      final snapshot = await exerciseRef.collection(kQuestion).get();
      if (snapshot.docs.isEmpty) {
        print('No questions found for exercise ${exerciseRef.id}');
        return [];
      }
      final questions =
          snapshot.docs
              .map((q) => Question.fromJson({...q.data(), kId: q.id}))
              .toList();
      questions.sort((a, b) => a.title.compareTo(b.title));
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
              .map((el) => Exercise.fromJson({...el.data(), kId: el.id}))
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
      exercises.sort((a, b) => a.index.compareTo(b.index));
      return exercises;
    } catch (e) {
      print('Failed to fetch exercises: $e');
      return [];
    }
  }

  static Future<void> saveAnswers(Exam exam) async {
    final examRef =await _db.collection(kUser).doc(_auth.currentUser?.uid).collection(kExam).doc(exam.id).get();
    if(examRef.data() == null) {
      print('Exam ${exam.id} does not exist, creating new document.');
      await _db
          .collection(kUser)
          .doc(_auth.currentUser?.uid)
          .collection(kExam)
          .doc(exam.id)
          .set({});
    }
    for (var exercise in exam.exercises) {
      dynamic examRef =
          await _db
              .collection(kUser)
              .doc(_auth.currentUser?.uid)
              .collection(kExam)
              .doc(exam.id)
              .get();
      if (exercise.answer.isNotEmpty ||
          (exercise.getEncodedImage() != null &&
              exercise.getEncodedImage()!.isNotEmpty)) {
        await _db
            .collection(kUser)
            .doc(_auth.currentUser?.uid)
            .collection(kExam)
            .doc(exam.id)
            .collection(kExercises)
            .doc(exercise.id)
            .set({
              kAnswer: exercise.answer,
              kAnswerImage: exercise.getEncodedImage(),
              kLastSaved: FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> fetchAnswers(
    String examId,
  ) async {
    try {
      final snapshot =
          await _db
              .collection(kUser)
              .doc(_auth.currentUser?.uid)
              .collection(kExam)
              .doc(examId)
              .collection(kExercises)
              .get();

      Map<String, List<Map<String, dynamic>>> answers = {
        for (var doc in snapshot.docs)
          doc.id: (doc.data()[kAnswer] as List).cast<Map<String, dynamic>>(),
      };
      return answers;
    } catch (e) {
      print('Error fetching answers: $e');
      return {};
    }
  }

  static void saveNewGoal(int minutes) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('No user is currently logged in.');
      return;
    }
    final userRef = FirebaseFirestore.instance.collection(kUser).doc(userId);
    userRef
        .set({kGoal: minutes}, SetOptions(merge: true))
        .then((_) {
          print('New goal saved successfully.');
        })
        .catchError((error) {
          print('Failed to save new goal: $error');
        });
  }

  static Future<int> getCurrentGoal() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('No user is currently logged in.');
      return 0;
    }
    final userRef = FirebaseFirestore.instance.collection(kUser).doc(userId);
    final userSnap = await userRef.get();
    if (!userSnap.exists) {
      print('User document does not exist.');
      return 0;
    }
    final data = userSnap.data();
    final int goal = (data?[kGoal] as num?)?.toInt() ?? 0;
    return goal;
  }

static Future<List<String>> getTopExercises(String orderBy) async {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'testUserId';
  try {
    final examSnapshot = await _db
        .collection(kUser)
        .doc(userId)
        .collection(kExam)
        .get();

    List<Map<String, dynamic>> examsWithTimestamp = [];

    for (var examDoc in examSnapshot.docs) {
      final exercisesQuery = await _db
          .collection(kUser)
          .doc(userId)
          .collection(kExam)
          .doc(examDoc.id)
          .collection(kExercises)
          .orderBy(orderBy, descending: true)
          .limit(1)
          .get();

      if (exercisesQuery.docs.isNotEmpty) {
        final latestExercise = exercisesQuery.docs.first;
        final timestamp = latestExercise.data()[orderBy];
        if (timestamp != null) {
          examsWithTimestamp.add({
            'examId': examDoc.id,
            'timestamp': timestamp,
          });
        }
      }
    }
    examsWithTimestamp.sort((a, b) =>
        (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    final topExams = examsWithTimestamp.take(3).map((e) => e['examId'] as String).toList();
    print('Found ${topExams.length} exams with $orderBy timestamps');
    return topExams;
  } catch (error) {
    print('Error fetching top exercises: $error');
    return [];
  }
}

static Future<List<Exam>> loadExamById(List<String> topInProgressEx) async {
  List<Exam> exams = [];
  for (String id in topInProgressEx) {
    try {
      final doc = await _db.collection(kExam).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        final exercises = await fetchExercises(doc.id);
        final exam = Exam(
          id: doc.id,
          year: int.parse(data[kYear].toString()),
          subject: data[kSubject],
          exercises: exercises,
        );
        exams.add(exam);
      }
    } catch (e) {
      print('Error loading exam $id: $e');
    }
  }
  return exams;
}
}
