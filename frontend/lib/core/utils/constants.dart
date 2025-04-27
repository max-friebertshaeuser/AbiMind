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

const smallTextStyle = TextStyle(fontSize: 11, color: Color(0xFF584178));
const lableTextStyle = TextStyle(color: Colors.white, fontSize: 12);
var middleTextStyle = TextStyle(fontSize: 15);

const whiteColor = Color(0xFFFFFFFF);
const flameColor = Color(0xFFFFAB91);

final Map<String, Color> tagColors = {
  'Finished': Colors.green.shade200,         // Soft mint green
  'Geometrie': Colors.blueGrey.shade400,     // Muted slate blue
  'Analysis': Colors.deepOrange.shade200,    // Soft orange
  'Keine Hilfsmittel': Colors.red.shade200,  // Gentle red
  'Alle Hilfsmittel': Colors.teal.shade200,  // Calm turquoise
  'Statistics': Colors.deepPurple.shade200,  // Muted violet
};


const texamleExeciese = {
  'id': 'example',
  'name': 'example',
  'description': 'example description',
  'type': 'mathe',
  'category': 'strength',
  'level': 'beginner',
  'duration': 30,
  'reps': 10,
  'sets': 3,
};

const statistic = {
  'currentYear': 2025,
  'solvedPercentageNumeric': 0.65,
  'solvedPercentage': 65,
  'examParts': {
    {'name': 'Analysis', 'done': 10, 'total': 10},
    {'name': 'Stochastik', 'done': 5, 'total': 10},
    {'name': 'Geometrie', 'done': 10, 'total': 10},
  },
};

const streak = {
  'streak': 5,
  'goal': 90.0,
  'tenDayLearnProgress': {
    {'day': '2023-10-01', 'minutes': 100},
    {'day': '2023-10-02', 'minutes': 120},
    {'day': '2023-10-03', 'minutes': 95},
    {'day': '2023-10-04', 'minutes': 105},
    {'day': '2023-10-05', 'minutes': 109},
    {'day': '2023-10-06', 'minutes': 95},
    {'day': '2023-10-07', 'minutes': 100},
    {'day': '2023-10-08', 'minutes': 120},
    {'day': '2023-10-09', 'minutes': 100},
    {'day': '2023-10-10', 'minutes': 100},
  },
};

final tenDayLearnProgress = (streak['tenDayLearnProgress'] as Set).toList();
final minutesList =
    tenDayLearnProgress.map((entry) => entry['minutes'] as int).toList();
final maxMinutes = minutesList.reduce((a, b) => a > b ? a : b);
final minMinutes = minutesList.reduce((a, b) => a < b ? a : b);





const String kSampleText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
    'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';