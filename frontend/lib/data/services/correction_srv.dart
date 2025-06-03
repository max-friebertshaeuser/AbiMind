import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/constants.dart' as constants;
import '../../core/utils/constants.dart';

Future<void> triggerCorrection(String examId, String exerciseId) async {

  if (FirebaseAuth.instance.currentUser == null) {
    print('No user logged in, using test user ID');
    return;
  }

  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'testUserId';

  final Map<String, String> bodyData = {
    "userID": userId,
    "examID": examId,
    "exerciseID": exerciseId,
  };



  try {
    final response = await http.post(
      Uri.parse(constants.correctionEndpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200) {
      print('POST success: ${response.body}');
    } else {
      print('POST failed: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error making POST request: $e');
  }
}

class CorrectionService {
  User? currentUser = FirebaseAuth.instance.currentUser;


  static Future<void> triggerCorrection(String examId, String exerciseId) async {
    await triggerCorrection(examId, exerciseId);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCorrection(String examId, String exerciseId) {
    return FirebaseFirestore.instance
        .collection(kUser)
        .doc(currentUser!.uid)
        .collection(kExam).doc(examId).collection(kExercises).doc(exerciseId).snapshots();
  }



}
