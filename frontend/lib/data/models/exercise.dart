import 'dart:convert';
import 'package:flutter/material.dart';


import 'package:Abimind/data/models/question.dart';
import 'package:flutter/services.dart';

import '../../core/utils/constants.dart' as constant;
import 'encoded_image.dart';

enum ExerciseTopic { geometry, mandatory, analysis, stochastic, unknown }

extension ExerciseTopicName on ExerciseTopic {
  String get displayName {
    switch (this) {
      case ExerciseTopic.geometry:
        return 'Geometry';
      case ExerciseTopic.mandatory:
        return 'Mandatory';
      case ExerciseTopic.analysis:
        return 'Analysis';
      case ExerciseTopic.stochastic:
        return 'Stochastic';
      case ExerciseTopic.unknown:
        return 'Unknown';
    }
  }
}

class Exercise {
  final String id;
  final String title;
  final String description;
  final ExerciseTopic? exerciseTopic;
  final int index;
  final String shortDescription;
  List<Question>? questions;
  List<EncodedImage> images;
  List<EncodedImage>? solutionImages;
  List<Map<String, dynamic>> answer;
  ByteData? answerImage;

  Exercise({
    this.shortDescription = constant.shortDescription,
    this.exerciseTopic = ExerciseTopic.unknown,
    this.id = '',
    this.title = '',
    this.description = '',
    this.index = 100,
    this.questions = const [],
    this.images = const [],
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
      index: int.parse(json['index']?.toString() ?? '100'),
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

  String getEncodedImage(){
    if (answerImage != null) {
      final bytes = answerImage!.buffer.asUint8List();
      return base64Encode(bytes);
    }
    return '';
  }

  List<Uint8List> getImages() {
    if( images.isNotEmpty) {
      return images.map((img) => img.imageBytes).toList();
    } else {
      return [];
    }
  }


  @override
  String toString() {
    return 'Exercise{id: $id, title: $title, description: $description, questions: $questions, images: $images}';
  }
}
