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

const middleTextStyle = TextStyle(fontSize: 15, color: Color(0xFF584178));

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
