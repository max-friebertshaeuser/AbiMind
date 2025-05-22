import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/models/exercise.dart';
import 'package:frontend/presentation/screens/start/start-screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/utils/constants.dart';
import 'exercise_selection_bar.dart';

class ExerciseCardList extends StatefulWidget {
  @override
  _ExerciseCardListState createState() => _ExerciseCardListState();
}

class _ExerciseCardListState extends State<ExerciseCardList> {
  // Store selected categories
  List<ExerciseTopic> selectedCategories = [ExerciseTopic.mandatory];

  // All tasks (you can also move this outside if you prefer)
  final List<Map<String, dynamic>> taskCardsData = [];

  @override
  void initState() {
    super.initState();
    loadTaskCardsData();
  }

  Future<void> loadTaskCardsData() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/exerciseData.json',
      );
      List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        taskCardsData.addAll(jsonData.cast<Map<String, dynamic>>());
      });
    } catch (e) {
      print('Error loading task cards data: $e');
    }
  }

  // Filter logic based on selected categories
  List<Map<String, dynamic>> get filteredTasks {
    return taskCardsData.where((task) {
      return task['tags'].any((tag) => selectedCategories.contains(tag));
    }).toList();
  }

  void onCategorySelectionChanged(List<ExerciseTopic> newSelection) {
    setState(() {
      selectedCategories = newSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: MainSurfaceCard(
        title: 'Exercises',
        boxFlex: 1,
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                        filteredTasks.map((task) {
                          return CustomTaskCard(
                            title: task['title'],
                            description: task['description'],
                            tags: List<String>.from(task['tags']),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CategoryToggleBar(
              categories: [ExerciseTopic.mandatory, ExerciseTopic.analysis, ExerciseTopic.stochastic,ExerciseTopic.geometry],
              selected: selectedCategories,
              onSelectionChanged: onCategorySelectionChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseCards extends StatelessWidget {
  final int year;
  final double percent;
  final Map<String, List<int>> topics;

  const ExerciseCards({
    Key? key,
    required this.year,
    required this.percent,
    required this.topics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colorScheme.primaryFixed,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onPrimaryFixedVariant, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "— $year —",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1,
              color: colorScheme.onPrimaryFixedVariant,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Circle
                CircularPercentIndicator(
                  radius: 30.0,
                  lineWidth: 6.0,
                  percent: percent,
                  center: Text(
                    "${(percent * 100).round()}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: colorScheme.onPrimaryFixedVariant,
                    ),
                  ),
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  progressColor: colorScheme.onPrimaryFixedVariant,
                  circularStrokeCap: CircularStrokeCap.round,
                ),

                const SizedBox(width: 50),
                // Topics List
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                  topics.entries.map((entry) {
                    final String topic = entry.key;
                    final int done = entry.value[0];
                    final int total = entry.value[1];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("$done/$total ", style: smallTextStyle),
                          Text(
                            topic,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onPrimaryFixedVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class CustomTaskCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> tags;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        border: Border.all(color: colorScheme.onPrimaryFixedVariant, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children:
            tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagColors[tag],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag, style: lableTextStyle),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(title, style: kHeaderStyle),
          const SizedBox(height: 6),
          Text(description, style: middleTextStyle),
        ],
      ),
    );
  }
}