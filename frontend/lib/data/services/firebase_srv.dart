import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/core/utils/constants.dart';
import 'package:frontend/data/models/encoded_image.dart';
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

      print ('Exam data: $data');
      // final analysisExercises = await fetchExercises(examId, kAnalysis);
      // final geometryExercises = await fetchExercises(examId, kGeometry);
      // final stochasticExercises = await fetchExercises(examId, kStochastic);
      // final mandatoryExercises = await fetchExercises(examId, kMandatory);

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

  static Future<List<Question>> fetchQuestions(String examId, String exerciseId) async {
    try {
      final snapshot =
      await _db.collection(kAbitur).doc(examId).collection(kExercises).doc(exerciseId).collection(kQuestion).get();
      final questions = snapshot.docs.map((q) => Question.fromJson({...q.data(), 'id': q.id})).toList();

      // await Future.wait(
      //   questions.map((q) async {
      //     q.images = await fetchEncodedImages(
      //       _db
      //           .collection(kAbitur)
      //           .doc(examId)
      //           .collection(topic)
      //           .doc(exerciseId)
      //           .collection(kQuestion)
      //           .doc(q.id)
      //           .collection(kImages),
      //     );
      //
      //     q.solutionImages = await fetchEncodedImages(
      //       _db
      //           .collection(kAbitur)
      //           .doc(examId)
      //           .collection(topic)
      //           .doc(exerciseId)
      //           .collection(kQuestion)
      //           .doc(q.id)
      //           .collection(kSolutionImages),
      //
      //     );
      //   }),
      // );

      return questions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  static Future<List<Exercise>> fetchExercises(String examId) async {
    try {
      final snapshot = await _db.collection(kExam).doc(examId).collection(kExercises).get();
      final exercises = snapshot.docs.map((el) => Exercise.fromJson({...el.data(), 'id': el.id})).toList();

      await Future.wait(
        exercises.map((exercise) async => exercise.questions = await fetchQuestions(examId, exercise.id)),
        // exercise.images = await fetchEncodedImages(
        //   _db.collection(kAbitur).doc(examId).collection(topic).doc(exercise.id).collection('images'),
        // );

        // exercise.solutionImages = await fetchEncodedImages(
        //   _db.collection(kAbitur)
        //       .doc(examId)
        //       .collection(topic)
        //       .doc(exercise.id)
        //       .collection(kSolutionImages),
        // );

      );

      return exercises;
    } catch (e) {
      print('Failed to fetch exercises: $e');
      return [];
    }
  }

  // static Future<List<EncodedImage>> fetchEncodedImages(CollectionReference collection) async {
  //   try {
  //     final snapshot = await collection.get();
  //
  //     return snapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       return EncodedImage(id: doc.id, title: data['title'] ?? '', content: data['content'] ?? '');
  //     }).toList();
  //   } catch (e) {
  //     print('Error fetching images from ${collection.path}: $e');
  //     return [];
  //   }
  // }


  static Future<void> saveAnswers(Exam exam) async {
    final topics = {
      kAnalysis: exam.analysisExercises,
      kGeometry: exam.geometryExercises,
      kStochastic: exam.stochasticExercises,
      kMandatory: exam.mandatoryExercises,
    };

    await Future.wait(
        topics.entries.expand((entry) =>
            (entry.value ?? []).map((e) async {
              await _db.collection('user').doc(_auth.currentUser?.uid).collection(kExam).doc(exam.id).collection(
                  entry.key).doc(
                  e.id).set({
                kAnswer: e.answer,

              });
              print('Answer saved for ${entry.key} exercise ${e.id}');
            }
            )
        )
    );
  }
}