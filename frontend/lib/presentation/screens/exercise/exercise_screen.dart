import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_drawing_board/paint_extension.dart';

import '../../../core/utils/constants.dart';
import 'custom_drawing_board.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  /// 绘制控制器
  final DrawingController _drawingController = DrawingController();

  final TransformationController _transformationController = TransformationController();

  double _colorOpacity = 1;

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  bool exerciseExpanded = true;

  List<Exercise> exercises = [
    Exercise(
      heading: 'Exercise 1',
      description: 'A description of Exercise 1',
      questions: [
        Question(
          title: 'a)',
          description: 'Description of Exercise a), $kSampleText',
          solution: 'Solution of Exercise a)',
        ),
        Question(
          title: 'b)',
          description: 'Description of Exercise b), $kSampleText',
          solution: 'Solution of Exercise b)',
        ),
        Question(
          title: 'c)',
          description: 'Description of Exercise c), $kSampleText',
          solution: 'Solution of Exercise c)',
        ),
        Question(
          title: 'd)',
          description: 'Description of Exercise d), $kSampleText',
          solution: 'Solution of Exercise d)',
        ),
      ],
    ),
    Exercise(
      heading: 'Exercise 2',
      description: 'A description of Exercise 1',
      questions: [
        Question(
          title: 'a)',
          description: 'Description of Exercise a), $kSampleText',
          solution: 'Solution of Exercise a)',
        ),
        Question(
          title: 'b)',
          description: 'Description of Exercise b), $kSampleText',
          solution: 'Solution of Exercise b)',
        ),
        Question(
          title: 'c)',
          description: 'Description of Exercise c), $kSampleText',
          solution: 'Solution of Exercise c)',
        ),
        Question(
          title: 'd)',
          description: 'Description of Exercise d), $kSampleText',
          solution: 'Solution of Exercise d)',
        ),
      ],
    ),
  ];
  int exerciseIndex = 0;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Exercise currentExercise = exercises[exerciseIndex];


    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: PopupMenuButton<Color>(
          icon: const Icon(Icons.color_lens),
          onSelected: (ui.Color value) => _drawingController.setStyle(color: value.withValues(alpha: _colorOpacity)),
          itemBuilder: (_) {
            return <PopupMenuEntry<ui.Color>>[
              PopupMenuItem<Color>(
                child: StatefulBuilder(
                  builder: (BuildContext context, Function(void Function()) setState) {
                    return Slider(
                      value: _colorOpacity,
                      onChanged: (double v) {
                        setState(() => _colorOpacity = v);
                        _drawingController.setStyle(
                          color: _drawingController.drawConfig.value.color.withValues(alpha: _colorOpacity),
                        );
                      },
                    );
                  },
                ),
              ),
              ...Colors.accents.map((ui.Color color) {
                return PopupMenuItem<ui.Color>(value: color, child: Container(width: 100, height: 50, color: color));
              }),
            ];
          },
        ),
        title: const Text('Drawing Test'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: <Widget>[
          // IconButton(icon: const Icon(Icons.line_axis), onPressed: _addTestLine),
          // IconButton(icon: const Icon(Icons.javascript_outlined), onPressed: _getJson),
          // IconButton(icon: const Icon(Icons.check), onPressed: _getImageData),
          // IconButton(icon: const Icon(Icons.restore_page_rounded), onPressed: _restBoard),
        ],
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(systemNavigationBarColor: Colors.grey),
        child: SafeArea(
          child: Stack(
            children: [
              Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Flex(
                          direction: Axis.vertical,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                exercises[exerciseIndex].heading,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(currentExercise.description, style: TextStyle(fontSize: 16)),
                            ),
                            Expanded(
                              child:
                                  exerciseExpanded
                                      ? ListView.builder(
                                        itemCount: exercises.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(
                                              '${currentExercise.questions[index].title} ${currentExercise.questions[index].description}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          );
                                        },
                                      )
                                      : SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //Drawing Board
                  Expanded(
                    flex: exerciseExpanded ? 1 : 9,
                    child: CustomDrawingBoard(
                      transformationController: _transformationController,
                      drawingController: _drawingController,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: exerciseExpanded ? Alignment(0, 0) : Alignment(-0.8, 0),
                child: FractionalTranslation(
                  translation: exerciseExpanded ? Offset(0, 0) : Offset(-0.5, 0),
                  child: Padding(
                    padding: exerciseExpanded ? EdgeInsets.only(left: 0) : EdgeInsets.only(left: 12),
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.surface),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            exerciseExpanded = !exerciseExpanded;
                          });
                          print('exerciseExpanded: $exerciseExpanded');
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          shape: CircleBorder(),
                        ),
                        icon: Icon(exerciseExpanded ? Icons.chevron_left : Icons.chevron_right),
                        padding: const EdgeInsets.all(5),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      mini: true,
                      heroTag: "prev_page",
                      onPressed: () {
                        setState(() {
                          if(exerciseIndex > 0) {
                            exerciseIndex--;
                            _drawingController.clear();
                          }
                        });
                      },
                      child: Icon(Icons.chevron_left),
                    ),
                    SizedBox(width: 8), // space between buttons
                    FloatingActionButton(
                      mini: true,
                      heroTag: "next_page",
                      onPressed: () {
                        currentExercise.answer = _drawingController.getJsonList();
                        setState(() {
                          if(exerciseIndex < exercises.length-1) {
                            exerciseIndex++;
                            _drawingController.clear();
                          }
                        });
                      },
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Exercise {
  Exercise({required this.heading, required this.description, required this.questions});

  final String heading;
  final String description;
  final List<Question> questions;
  List<Map<String, dynamic>>? answer;


}

class Question {
  const Question({required this.title, required this.description, this.solution});

  final String title;
  final String description;
  final String? solution;
}



// {
//   images: {
// asldkfjalskfjaslk: {
// title: 2025.....jpg,
// content: "base64:eklgnalknölf"
// },
// falksjfaklsjfö: {
// title: 2025.....jpg,
// content: "base64:eklgnalknölf"
// },
// dafklfjölajf: {
// title: 2025.....jpg,
// content: "base64:eklgnalknölf"
// }
// ]
// }