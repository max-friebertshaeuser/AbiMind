import 'package:flutter/material.dart';

class StarScreen extends StatelessWidget {
  const StarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AbiMind',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {}, // Optional drawer
        ),
      ),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  Text(
                    "Recent Exams",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // === Inner Split: Circular + Subject Progress | Exam Cards ===
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN: Circle + Subjects
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Text("2024", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 140,
                              width: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: 0.65,
                                    strokeWidth: 12,
                                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                                    backgroundColor: colorScheme.primaryContainer,
                                  ),
                                  const Text("65%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            buildSubjectBar("Geometrie", 4, 7, colorScheme),
                            buildSubjectBar("Analysis", 8, 9, colorScheme),
                            buildSubjectBar("Stochastik", 2, 8, colorScheme),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: List.generate(4, (_) => buildExamCard(colorScheme)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Text("17 🔥", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(width: 16),
                        Text("Du hast dein Lernziel 17 Tage lang erreicht"),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === RIGHT SIDE (Exercises) ===
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Exercises",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.primary),
                  ),
                  const SizedBox(height: 16),

                  // Scrollable list of exercises
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(4, (_) => buildExerciseCard(colorScheme)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Filter Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(label: const Text("Geometry"), selected: true, onSelected: (_) {}),
                      FilterChip(label: const Text("Analysis"), selected: true, onSelected: (_) {}),
                      FilterChip(label: const Text("Statistics"), selected: false, onSelected: (_) {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === SUBJECT PROGRESS BAR ===
  Widget buildSubjectBar(String title, int value, int total, ColorScheme color) {
    final percent = value / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title),
            Text("$value/$total"),
          ]),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: color.primaryContainer,
            valueColor: AlwaysStoppedAnimation(color.primary),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  // === EXAM CARD ===
  Widget buildExamCard(ColorScheme color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: 0.65,
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation(color.primary),
            backgroundColor: color.primaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("— 2024 —", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Stochastik 2/8"),
                Text("Geometrie 4/7"),
                Text("Analysis 7/9"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExerciseCard(ColorScheme color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Textaufgabe", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Untersuche eine Funktion, bestimme Extremstellen, Wendepunkte und Flächeninhalte..."),
        ],
      ),
    );
  }
}
