import 'package:frontend/data/models/encoded_image.dart';

class Question {
  final String id;
  final String title;
  final String description;
  final String solution;
  List<EncodedImage> images;
  List<EncodedImage> solutionImages;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.solution,
    required this.images,
    required this.solutionImages,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      solution: json['solution'] as String,
      images: (json['images'] as List<dynamic>?)
          ?.map((item) => EncodedImage.fromJson(item))
          .toList() ?? [],
      solutionImages: (json['solutionImages'] as List<dynamic>?)
          ?.map((item) => EncodedImage.fromJson(item))
          .toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'Question{id: $id, title: $title, description: $description, solution: $solution, images: $images, solutionImages: $solutionImages}';
  }
}
