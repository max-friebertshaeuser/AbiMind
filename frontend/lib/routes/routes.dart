import 'package:flutter/material.dart';
import 'package:Abimind/presentation/screens/home/home_screen.dart';
import 'package:Abimind/presentation/screens/exercise/exercise_screen.dart';
import 'package:Abimind/presentation/screens/paint/paint_screen.dart';
import 'package:Abimind/presentation/screens/start/start-screen.dart';
import '../presentation/screens/login/login-flow.dart';
import '../presentation/screens/paint/paint_screen.dart';
import '../presentation/screens/registration/registration-flow.dart';
import '../presentation/screens/welcome/welcome-screen.dart';

class AppRoutes {
  static const home = '/';
  static const exercise = '/exercise';
  static const paint = '/paint';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/registration';
  static const start = '/start';
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.home: (context) => const HomeScreen(),
  AppRoutes.exercise: (context) => const ExerciseScreen(),
  AppRoutes.paint: (context) => PaintScreen(),
  AppRoutes.welcome: (context) => const WelcomeScreen(),
  AppRoutes.login: (context) => const LoginFlow(),
  AppRoutes.register: (context) => const RegistrationFlow(),
  AppRoutes.start: (context) => const StarScreen(),
};
