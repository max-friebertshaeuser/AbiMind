
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

void main() {
  runApp(const AbiMindApp());
}

class AbiMindApp extends StatelessWidget {
  const AbiMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant, // Use Material background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'AbiMind',
          style: TextStyle(color: colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left Panel
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Exams', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  const SizedBox(height: 20),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 10.0,
                      percent: 0.65,
                      center: const Text("65%", style: TextStyle(fontSize: 20.0)),
                      progressColor: colorScheme.primary,
                      backgroundColor: colorScheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Subject Progress Bars
                  SubjectProgress(title: "Geometrie", value: 4 / 7, colorScheme: colorScheme),
                  SubjectProgress(title: "Analysis", value: 8 / 9, colorScheme: colorScheme),
                  SubjectProgress(title: "Stochastik", value: 2 / 8, colorScheme: colorScheme),
                  const SizedBox(height: 20),
                  // Recent Exam Boxes
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("2024 - Exam", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text("Stochastik, Geometrie, Analysis"),
                            const SizedBox(height: 8),
                            LinearPercentIndicator(
                              lineHeight: 8.0,
                              percent: 0.65,
                              backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                              progressColor: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Panel
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exercises', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Textaufgabe", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text("Untersuche eine Funktion, bestimme Extremstellen, Wendepunkte..."),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Filter Buttons
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text("Geometry"),
                        selected: true,
                        onSelected: (_) {},
                        selectedColor: colorScheme.primaryContainer,
                      ),
                      FilterChip(
                        label: const Text("Analysis"),
                        selected: true,
                        onSelected: (_) {},
                        selectedColor: colorScheme.primaryContainer,
                      ),
                      FilterChip(
                        label: const Text("Statistics"),
                        selected: false,
                        onSelected: (_) {},
                        selectedColor: colorScheme.primaryContainer,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectProgress extends StatelessWidget {
  final String title;
  final double value;
  final ColorScheme colorScheme;

  const SubjectProgress({required this.title, required this.value, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 4),
        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: value,
          backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
          progressColor: colorScheme.primary,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
