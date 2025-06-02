import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class EncodedImage {
  final String? id;
  final String title;
  final String content; // Base64 encoded string

  EncodedImage({
    this.id,
    required this.title,
    required this.content,
  });

  // Constructor for JSON deserialization
  factory EncodedImage.fromJson(Map<String, dynamic> json) {
    return EncodedImage(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  // Getter to convert base64 to Flutter Image widget
  Uint8List get imageBytes {
    final Uint8List bytes = base64Decode(content);
    return bytes;
  }

  @override
  String toString() {
    return 'EncodedImage{id: $id, title: $title, content: $content}';
  }
}
