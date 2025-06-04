import 'package:flutter/material.dart';

class CategoryProgress extends StatelessWidget {
  final String title;
  final int done;
  final int total;

  const CategoryProgress({super.key, required this.title, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double progress = total > 0 ? done / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: colorScheme.primary)),
              const Spacer(),
              Text("$done/$total", style: TextStyle(fontSize: 12, color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(10),
            value: progress,
            minHeight: 4,
            backgroundColor: colorScheme.inversePrimary,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
