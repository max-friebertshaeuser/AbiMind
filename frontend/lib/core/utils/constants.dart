import 'package:flutter/material.dart';


const kAchievdHeaderStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  fontFamily: 'Montserrat',
);
const kHeaderStyle = TextStyle(fontSize: 24, fontFamily: 'Montserrat');
const percentageStyle = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: Color(0xFF584178),
);
const sideBarTextStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold
);
const smallTextStyle = TextStyle(fontSize: 11, color: Color(0xFF584178));
const lableTextStyle = TextStyle(color: Colors.white, fontSize: 12);
var middleTextStyle = TextStyle(fontSize: 15);

const whiteColor = Color(0xFFFFFFFF);
const flameColor = Color(0xFFFFAB91);

final Map<String, Color> tagColors = {
  // Special status
  'Finished': Color(0xFF80CBC4), // Soft teal

  // Topics (cooler, darker blue-gray tone for white font contrast)
  'Geometry': Color(0xFF607D8B),   // Blue Grey 400
  'Analysis': Color(0xFF607D8B),
  'Stochastic': Color(0xFF607D8B),
  'Mandatory': Color(0xFF607D8B),

// Hilfsmittel tags (soft pastel red and green, good contrast with white text)
  'Keine Hilfsmittel': Color(0xFFE57373), // Soft red (Red 300)
  'Mit Hilfsmitteln': Color(0xFFA5D6A7),  // Soft green (Green 200)


  // Mandatory tag (pastel yellow too bright → switch to amber for contrast)
};

const correctionEndpoint = 'http://10.0.2.2:8000/correction/';


const String shortDescription = 'Dieser Text existiert nur, um irgendetwas zu füllen, was du vermutlich vermeiden willst, ernsthaft zu bearbeiten. Dreißig Wörter, keine Substanz, aber hey – sieht gut aus';


const String kAnalysis = 'analysis';
const String kGeometry = 'geometry';
const String kStochastic = 'stochastic';
const String kMandatory = 'mandatory';
const String kExam = 'exams';
const String kAbitur = 'Abitur'; //todo remove
const String kExercises = 'exercises';
const String kQuestion = 'questions';
const String kUser = 'user';
const String kImages = 'images';
const String kSolutionImages = 'solution_images';
const String kAnswer = 'answer';
const String kAnswerImage = 'answer_image';
const String kScore = 'score';
const String kGoal = 'goal';
const String kStreakLog = 'streakLog';
const String kDate = 'date';
const String kMinutes = 'minutes';
const String kYear = 'year';
const String kSubject = 'subject';
const String kId = 'id';
const String kLastSaved = 'lastSaved';
const String kLastCorrected = 'lastCorrected';