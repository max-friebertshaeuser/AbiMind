import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/models/exercise.dart';

import '../../../../core/utils/constants.dart';

class CategoryToggleBar extends StatefulWidget {
  final List<ExerciseTopic> categories;
  final List<ExerciseTopic> selected;
  final void Function(List<ExerciseTopic>) onSelectionChanged;

  const CategoryToggleBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  State<CategoryToggleBar> createState() => _CategoryToggleBarState();
}

class _CategoryToggleBarState extends State<CategoryToggleBar> {
  late List<ExerciseTopic> selected;

  @override
  void initState() {
    super.initState();
    selected = [...widget.selected];
  }

  void toggleCategory(ExerciseTopic category) {
    setState(() {
      if (selected.contains(category)) {
        selected.remove(category);
      } else {
        selected.add(category);
      }
      widget.onSelectionChanged(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.onPrimaryFixedVariant, width: 2),
        borderRadius: BorderRadius.circular(40),
        color: colorScheme.primaryContainer,
      ),
      child: Row(
        children:
        widget.categories.map((category) {
          final isSelected = selected.contains(category);
          return Expanded(
            child: GestureDetector(
              onTap: () => toggleCategory(category),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                  isSelected
                      ? colorScheme.onPrimaryFixedVariant
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      size: 18,
                      color:
                      isSelected
                          ? whiteColor
                          : colorScheme.onPrimaryFixedVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        color:
                        isSelected
                            ? whiteColor
                            : colorScheme.onPrimaryFixedVariant,
                        fontWeight:
                        isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}