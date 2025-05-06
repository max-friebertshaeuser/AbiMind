import 'dart:convert';
import 'dart:ffi';
import 'progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:frontend/core/utils/constants.dart';
import 'streak_card.dart';

class StarScreen extends StatelessWidget {
  const StarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        title: Image.asset('assets/logo.png', height: 40),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: const SideBar(), // <- Add this
      body: Container(
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 1,
              child: Column(children: const [ProgressCard(), StreakCard()]),
            ),
            Expanded(child: ExerciseCardList()),
          ],
        ),
      ),
    );
  }
}

class ExerciseCardList extends StatefulWidget {
  @override
  _ExerciseCardListState createState() => _ExerciseCardListState();
}

class _ExerciseCardListState extends State<ExerciseCardList> {
  // Store selected categories
  List<String> selectedCategories = ['Geometrie', 'Analysis'];

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

  void onCategorySelectionChanged(List<String> newSelection) {
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
              categories: ['Geometrie', 'Analysis', 'Statistics'],
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

class CategoryProgress extends StatelessWidget {
  final String title;
  final int done;
  final int total;

  const CategoryProgress({
    super.key,
    required this.title,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double progress = done / total;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: smallTextStyle),
              const Spacer(),
              Text("$done/$total", style: smallTextStyle),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHigh,
              color: colorScheme.onPrimaryFixedVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class MainSurfaceCard extends StatelessWidget {
  const MainSurfaceCard({
    super.key,
    required this.title,
    required this.boxFlex,
    required this.child,
  });

  final String title;
  final int boxFlex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      flex: boxFlex,
      child: Column(
        children: [
          Text(title, style: kHeaderStyle),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryToggleBar extends StatefulWidget {
  final List<String> categories;
  final List<String> selected;
  final void Function(List<String>) onSelectionChanged;

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
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = [...widget.selected];
  }

  void toggleCategory(String category) {
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
                          category,
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



class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late Future<Map<String, dynamic>> sidebarData;

  @override
  void initState() {
    super.initState();
    sidebarData = loadSidebarData();
  }

  Future<Map<String, dynamic>> loadSidebarData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/sidebar.json',
    );
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: sidebarData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available.'));
        }

        final data = snapshot.data!;
        final corrected = data['corrected'] as List<dynamic>;
        final inProgress = data['in_progress'] as List<dynamic>;

        return Drawer(
          child: Container(
            color: const Color(0xFFF9F4FC),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              children: [
                Image.asset('assets/logo.png', height: 30),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profil"),
                  onTap: () {
                    print("Profile was clicked");
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Continue",
                      style: sideBarTextStyle
                  ),
                ),

                ...inProgress.map(
                  (item) => ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(item['name']),
                    onTap: () {
                      print("${item['name']} (in progress) was clicked");
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Correction",
                    style: sideBarTextStyle
                  ),
                ),
                ...corrected.map(
                  (item) => ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(item['name']),
                    onTap: () {
                      print("${item['name']} (corrected) was clicked");
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () {
                    print("Settings was clicked");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
