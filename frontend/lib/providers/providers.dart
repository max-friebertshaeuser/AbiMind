import 'package:Abimind/data/services/correction_srv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider that returns your service instance. It’s just dependency injection cosplay.
final firebasePostWatcherProvider = Provider<CorrectionService>((ref) {
  return CorrectionService();
});

/// This is the actual stream provider you’ll use in your widgets.
/// It listens for changes to a specific post doc.
final correctionStreamProvider = StreamProvider.family
    .autoDispose<DocumentSnapshot<Map<String, dynamic>>, CorrectionParams>(
      (ref, params) {
    final service = ref.read(firebasePostWatcherProvider);
    return service.watchCorrection(params.examId, params.exerciseId);
  },
);

class CorrectionParams {
  final String examId;
  final String exerciseId;

  CorrectionParams({
    required this.examId,
    required this.exerciseId,
  });

  // Optional: override equality so Riverpod can cache properly
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CorrectionParams &&
              runtimeType == other.runtimeType &&
              examId == other.examId &&
              exerciseId == other.exerciseId;

  @override
  int get hashCode => examId.hashCode ^ exerciseId.hashCode;
}