import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/data/models/encoded_image.dart';
import 'package:frontend/data/models/exercise.dart';
import 'package:frontend/data/models/question.dart';

import '../models/exam.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Exam>> getExams() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      final querySnapshot = await db.collection('Abitur').get();

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

  Future<Exam?> getExam(String examId) async {
    try {
      final snapshot = await _db.collection('Abitur').doc(examId).get();
      final data = snapshot.data();

      final analysisExercises = await fetchExercises(examId, 'analysis');
      final geometryExercises = await fetchExercises(examId, 'geometry');
      final stochasticExercises = await fetchExercises(examId, 'stochastics');
      final mandatoryExercises = await fetchExercises(examId, 'mandatory');

      return Exam(
        id: snapshot.id,
        year: data!['year'],
        subject: data['subject'],
        analysisExercises: analysisExercises,
        geometryExercises: geometryExercises,
        stochasticExercises: stochasticExercises,
        mandatoryExercises: mandatoryExercises,
      );
    } catch (e) {
      print('Error fetching exam: $e');
    }
    return null;
  }

  Future<List<Question>> fetchQuestions(String examId, String topic, String exerciseId) async {
    try {
      final snapshot =
          await _db.collection('Abitur').doc(examId).collection(topic).doc(exerciseId).collection('questions').get();
      final questions = snapshot.docs.map((q) => Question.fromJson({...q.data(), 'id': q.id})).toList();

      await Future.wait(
        questions.map((q) async {
          q.images = await fetchEncodedImages(
            _db.collection('Abitur').doc(examId).collection(topic).doc(exerciseId).collection('questions').doc(q.id).collection('images'),
          );

          q.solutionImages = await fetchEncodedImages(
            _db.collection('Abitur').doc(examId).collection(topic).doc(exerciseId).collection('questions').doc(q.id).collection('solution_images'),

          );
        }),
      );

      return questions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  Future<List<Exercise>> fetchExercises(String examId, String topic) async {
    try {
      final snapshot = await _db.collection('Abitur').doc(examId).collection(topic).get();
      final exercises = snapshot.docs.map((el) => Exercise.fromJson({...el.data(), 'id': el.id})).toList();

      await Future.wait(
        exercises.map((exercise) async {
          exercise.questions = await fetchQuestions(examId, topic, exercise.id);
          exercise.images = await fetchEncodedImages(
            _db.collection('Abitur').doc(examId).collection(topic).doc(exercise.id).collection('images'),
          );

          exercise.solutionImages = await fetchEncodedImages(
            _db.collection('Abitur')
                .doc(examId)
                .collection(topic)
                .doc(exercise.id)
                .collection('solution_images'),
          );
        }),
      );

      return exercises;
    } catch (e) {
      print('Failed to fetch $topic exercises: $e');
      return [];
    }
  }

  Future<List<EncodedImage>> fetchEncodedImages(CollectionReference collection) async {
    try {
      final snapshot = await collection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EncodedImage(id: doc.id, title: data['title'] ?? '', content: data['content'] ?? '');
      }).toList();
    } catch (e) {
      print('Error fetching images from ${collection.path}: $e');
      return [];
    }
  }

  // Future<EncodedImage> getImage(String imageId) {
  //   final val = _db.collection('Abitur').doc('OHLESyc19sRHmLTVOUji').collection('analysis').doc('lNPQGMEMrjUfdS7vsuxg').collection(collectionPath).get().then((doc) {
  //     if (doc.exists) {
  //       return EncodedImage.fromJson(doc.data()!);
  //     } else {
  //       throw Exception('Image not found');
  //     }
  //   });
  //
  //   return val;
  // }
}
