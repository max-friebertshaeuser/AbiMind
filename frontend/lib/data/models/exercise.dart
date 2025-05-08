import 'package:flutter/services.dart';
import 'package:frontend/data/models/encoded_image.dart';
import 'package:frontend/data/models/question.dart';

class Exercise {
  final String id;
  final String title;
  final String description;
  List<Question>? questions;
  List<EncodedImage>? images;
  List<EncodedImage>? solutionImages;
  List<Map<String, dynamic>> answer;
  ByteData? answerImage;

  Exercise({
    this.id = '',
    this.title = '',
    this.description = '',
    this.questions,
    this.images,
    this.solutionImages,
    this.answer = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>?)?.map((q) => Question.fromJson(q)).toList() ?? [],
      images: (json['images'] as List<dynamic>?)?.map((img) => EncodedImage.fromJson(img)).toList() ?? [],
      solutionImages:
          (json['solutionImages'] as List<dynamic>?)?.map((img) => EncodedImage.fromJson(img)).toList() ?? [],
      answer: (json['answer'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'Exercise{id: $id, title: $title, description: $description, questions: $questions, images: $images}';
  }
}
