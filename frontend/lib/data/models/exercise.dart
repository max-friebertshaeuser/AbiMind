import 'package:frontend/data/models/encoded_image.dart';
import 'package:frontend/data/models/question.dart';

class Exercise {
  final String id;
  final String title;
  final String description;
  List<Question>? questions;
  List<EncodedImage>? images;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.images,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => EncodedImage.fromJson(img))
          .toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'Exercise{id: $id, title: $title, description: $description, questions: $questions, images: $images}';
  }
}
