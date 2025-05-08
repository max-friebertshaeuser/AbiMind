import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:frontend/data/services/firebase_srv.dart';

import '../../../data/models/exam.dart';
import '../../../data/models/exercise.dart';
import 'custom_drawing_board.dart';

class ExerciseScreenArguments {
  final String examId;
  final int exerciseIndex;

  ExerciseScreenArguments({required this.examId, this.exerciseIndex = 0});
}

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});
  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  /// 绘制控制器
  final DrawingController _drawingController = DrawingController();
  final TransformationController _transformationController = TransformationController();
  late ExerciseScreenArguments args;
  Exam exam = Exam(exercises: [Exercise(title: 'fallback')]);
  int exerciseIndex = 0;
  bool exerciseExpanded = true;
  double _colorOpacity = 1;

  Future<void> _loadAnswer(List<Map<String, dynamic>> data) async {
    final contents = data.map((json) => _mapJsonToPaintContent(json)).toList();
    _drawingController.clear();
    _drawingController.addContents(contents); // :contentReference[oaicite:13]{index=13}
  }

  PaintContent _mapJsonToPaintContent(Map<String, dynamic> data) {
    final type = data['type'] as String;
    switch (type) {
      case 'StraightLine':
        return StraightLine.fromJson(data);
      case 'SimpleLine':
        return SimpleLine.fromJson(data);
      case 'SmoothLine':
        return SmoothLine.fromJson(data);
      case 'Rectangle':
        return Rectangle.fromJson(data);
      case 'Circle':
        return Circle.fromJson(data);
      case 'Eraser':
        return Eraser.fromJson(data);
      default:
        {
          print(data);
          throw Exception('Unsupported content type: $type');
        }
    }
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as ExerciseScreenArguments;
    print('args: $args');
    exam = await FirebaseService.getExam(args.examId) ?? Exam(exercises: [Exercise(title: 'fallback')]);
    if (exam == null || exam.exercises.isEmpty) exam = Exam(exercises: [Exercise(title: 'fallback')]);
    exerciseIndex = args.exerciseIndex;
    if (exam.exercises[exerciseIndex].answer.isNotEmpty) _loadAnswer(exam.exercises[exerciseIndex].answer);
  }

  // Exam exam = Exam(

  //   id: 'OHLESyc19sRHmLTVOUji',
  //   year: 2025,
  //   subject: 'math',
  //   analysisExercises: [
  //     Exercise(
  //       id: 'exercise_1',
  //       title: 'Exercise 1',
  //       description: 'A description of Exercise 1',
  //       questions: [
  //         Question(
  //           id: 'exercise_1_a',
  //           title: 'a)',
  //           description: 'Description of Exercise a), $kSampleText',
  //           solution: 'Solution of Exercise a)',
  //         ),
  //         Question(
  //           id: 'exercise_1_b',
  //           title: 'b)',
  //           description: 'Description of Exercise b), $kSampleText',
  //           solution: 'Solution of Exercise b)',
  //         ),
  //         Question(
  //           id: 'exercise_1_c',
  //           title: 'c)',
  //           description: 'Description of Exercise c), $kSampleText',
  //           solution: 'Solution of Exercise c)',
  //         ),
  //         Question(
  //           id: 'exercise_1_d',
  //           title: 'd)',
  //           description: 'Description of Exercise d), $kSampleText',
  //           solution: 'Solution of Exercise d)',
  //         ),
  //       ],
  //     ),
  //     Exercise(
  //       id: 'exercise_2',
  //       title: 'Exercise 2',
  //       description: 'A description of Exercise 1',
  //       questions: [
  //         Question(
  //           id: 'exercise_2_a',
  //           title: 'a)',
  //           description: 'Description of Exercise a), $kSampleText',
  //           solution: 'Solution of Exercise a)',
  //         ),
  //         Question(
  //           id: 'exercise_2_b',
  //           title: 'b)',
  //           description: 'Description of Exercise b), $kSampleText',
  //           solution: 'Solution of Exercise b)',
  //         ),
  //         Question(
  //           id: 'exercise_2_c',
  //           title: 'c)',
  //           description: 'Description of Exercise c), $kSampleText',
  //           solution: 'Solution of Exercise c)',
  //         ),
  //         Question(
  //           id: 'exercise_2_d',
  //           title: 'd)',
  //           description: 'Description of Exercise d), $kSampleText',
  //           solution: 'Solution of Exercise d)',
  //         ),
  //       ],
  //     ),
  //   ],
  //   geometryExercises: [],
  //   stochasticExercises: [],
  //   mandatoryExercises: [],
  // );

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    if(exam == null || exam.exercises.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    print('exam: $exam');
    Exercise currentExercise = exam.exercises[exerciseIndex];
    _loadAnswer(currentExercise.answer);

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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              currentExercise.answer = _drawingController.getJsonList();
              currentExercise.answerImage = await _drawingController.getImageData();
              await FirebaseService.saveAnswers(exam);
              print('Save answer: ${currentExercise.answer}');
            },
          ),
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
                                exam.exercises[exerciseIndex].title,
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
                                        itemCount: exam.exercises.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(
                                              currentExercise.questions!.isEmpty ? 'No Questions':'${currentExercise.questions?[index].title} ${currentExercise.questions?[index].description}',
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
                          currentExercise.answer = _drawingController.getJsonList();
                          if(exerciseIndex > 0) {
                            exerciseIndex--;
                            // _loadAnswer(currentExercise.answer);
                          }
                        });
                      },
                      child: Icon(Icons.chevron_left),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      heroTag: "next_page",
                      onPressed: () {
                        currentExercise.answer = _drawingController.getJsonList();
                        setState(() {
                          if (exerciseIndex < exam.exercises.length - 1) {
                            exerciseIndex++;
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