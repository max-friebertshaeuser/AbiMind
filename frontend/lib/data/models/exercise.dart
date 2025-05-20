import 'package:flutter/services.dart';
import 'package:frontend/data/models/encoded_image.dart';
import 'package:frontend/data/models/question.dart';

enum ExerciseTopic { geometry, mandatory, analysis, stochastic, unknown }

class Exercise {
  final String id;
  final String title;
  final String description;
  final ExerciseTopic? exerciseTopic;
  List<Question>? questions;
  List<EncodedImage>? images;
  List<EncodedImage>? solutionImages;
  List<Map<String, dynamic>> answer;
  ByteData? answerImage;

  Exercise({
    this.exerciseTopic = ExerciseTopic.unknown,
    this.id = '',
    this.title = '',
    this.description = '',
    this.questions = const [],
    this.images,
    this.solutionImages,
    this.answer = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // 1) parse the topic (make sure YOUR Firestore field is called "topic")
    final topicStr = (json['topic'] as String?) ?? 'unknown';
    final topic = ExerciseTopic.values.firstWhere(
          (t) => t.toString().split('.').last == topicStr,
      orElse: () => ExerciseTopic.unknown,
    );

    // 2) helper to normalize list fields
    List<T> _asList<T>(dynamic field, T Function(Map<String, dynamic>) ctor) {
      if (field is List) {
        return field
            .map((e) => ctor(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      if (field is Map) {
        // Firestore sometimes returns arrays of maps as Map<String,dynamic>
        return field.values
            .map((e) => ctor(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return <T>[];
    }

    return Exercise(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      exerciseTopic: topic,
      questions:
      _asList(json['questions'], (m) => Question.fromJson(m)),
      images:
      _asList(json['images'], (m) => EncodedImage.fromJson(m)),
      solutionImages:
      _asList(json['solutionImages'], (m) => EncodedImage.fromJson(m)),
      answer: (json['answer'] as List<dynamic>?)
          ?.map((x) => Map<String, dynamic>.from(x as Map))
          .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'Exercise{id: $id, title: $title, description: $description, questions: $questions, images: $images}';
  }
}
