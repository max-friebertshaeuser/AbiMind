import 'package:Abimind/presentation/screens/start/components/side_bar.dart';
import 'package:flutter/material.dart';

import 'components/exercise_card_list.dart';
import 'components/progress_card.dart';
import 'components/streak_card.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
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
        color: colorScheme.surface,
        child: SafeArea(
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
      ),
    );
  }
}



