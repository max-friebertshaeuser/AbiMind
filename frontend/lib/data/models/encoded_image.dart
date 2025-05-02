import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class EncodedImage {
  final String id;
  final String title;
  final String content; // Base64 encoded string

  EncodedImage({
    required this.id,
    required this.title,
    required this.content,
  });

  // Constructor for JSON deserialization
  factory EncodedImage.fromJson(Map<String, dynamic> json) {
    return EncodedImage(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  // Getter to convert base64 to Flutter Image widget
  Image get imageWidget {
    final Uint8List bytes = base64Decode(content);
    return Image.memory(bytes);
  }
}
