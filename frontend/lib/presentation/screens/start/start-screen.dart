import 'dart:convert';
import 'dart:ffi';
import 'package:frontend/presentation/screens/start/components/side_bar.dart';

import 'components/exercise_card_list.dart';
import 'components/progress_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:frontend/core/utils/constants.dart';
import 'components/streak_card.dart';

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

