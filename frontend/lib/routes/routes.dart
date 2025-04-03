import 'package:flutter/material.dart';
import 'package:frontend/presentation/screens/home/home_screen.dart';
import 'package:frontend/presentation/screens/exercise/exercise_screen.dart';
import 'package:frontend/presentation/screens/paint/paint_screen.dart';
import '../presentation/screens/paint/paint_screen.dart';

class AppRoutes {
  static const home = '/';
  static const exercise = '/exercise';
  static const paint = '/paint';
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.home: (context) => const HomeScreen(),
  AppRoutes.exercise: (context) => const ExerciseScreen(),
  AppRoutes.paint: (context) => PaintScreen(),
};
