import 'dart:convert';

import 'package:Abimind/data/models/exam.dart';
import 'package:Abimind/presentation/screens/start/components/streak_settings_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/firebase_srv.dart';

import '../../../../core/utils/constants.dart';
import '../../../../routes/routes.dart';
import '../../exercise/exercise_screen.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  List<String> topInProgressEx = [];
  List<String> topCorrectedEx = [];
  List<Exam> progressExercises = [];
  List<Exam> correctedExercises = [];
  bool _isLoading = true; // Add this flag

  @override
  void initState() {
    super.initState();
    loadSidebarData();
  }

  Future<void> loadSidebarData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get top exercises IDs
      final newTopCorrectedEx = await FirebaseService.getTopExercises(
        kLastCorrected,
      );
      final newTopInProgressEx = await FirebaseService.getTopExercises(
        kLastSaved,
      );

      // Load exercise data using those IDs
      final newProgressExercises = await FirebaseService.loadExamById(
        newTopInProgressEx,
      );
      final newCorrectedExercises = await FirebaseService.loadExamById(
        newTopCorrectedEx,
      );

      // Update state after all data is loaded
      setState(() {
        topCorrectedEx = newTopCorrectedEx;
        topInProgressEx = newTopInProgressEx;
        progressExercises = newProgressExercises;
        correctedExercises = newCorrectedExercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Also set to false on error
      });
      print('Error refreshing progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF9F4FC),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 16,
                  ),
                  children: [
                    Image.asset('assets/logo.png', height: 30),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.local_fire_department),
                      title: const Text("Streak Challenge"),
                      onTap: () {
                        print("Profile was clicked");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StreakSettingScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text("Continue", style: sideBarTextStyle),
                    ),
                    if (progressExercises.isEmpty)
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(
                          "No exams in progress",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    ...progressExercises.map(
                      (exam) => ListTile(
                        leading: const Icon(Icons.description),
                        title: Text("ABI ${exam.year}"),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.exercise,
                            arguments: ExerciseScreenArguments(examId: exam.id),
                          );
                        },
                      ),
                    ),

                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text("Correction", style: sideBarTextStyle),
                    ),

                    // No corrected exams message
                    if (correctedExercises.isEmpty)
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(
                          "No corrected exams",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    ...correctedExercises.map(
                      (exam) => ListTile(
                        leading: const Icon(Icons.description),
                        title: Text("${exam.subject} ${exam.year}"),
                        onTap: () {
                          print(
                            "${exam.subject} ${exam.year} (corrected) was clicked",
                          );
                          // Add navigation logic here
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
