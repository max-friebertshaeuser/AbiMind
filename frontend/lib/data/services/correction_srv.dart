import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/constants.dart' as constants;

Future<void> triggerCorrection(String examId, String exerciseId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'testUserId';

  final Map<String, String> bodyData = {
    "userID": userId,
    "examID": examId,
    "exerciseID": exerciseId,
  };

  if (FirebaseAuth.instance.currentUser == null) {
    print('No user logged in, using test user ID');
  }

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
