import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:Abimind/core/utils/constants.dart';
import 'package:Abimind/data/services/firebase_srv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/encoded_image.dart';
import '../../../data/models/exam.dart';
import '../../../data/models/exercise.dart';
import '../../../data/services/correction_srv.dart' as correction_srv;
import '../../../providers/providers.dart';
import 'correction_view.dart';
import 'custom_drawing_board.dart';
import 'exercise_view.dart';

final isCorrectionReadyProvider = StateProvider<bool>((ref) => false);
final correctionDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class ExerciseScreenArguments {
  final String examId;
  final int exerciseIndex;
  final String? exerciseId;

  @override
  String toString() {
    return 'ExerciseScreenArguments{examId: $examId, exerciseIndex: $exerciseIndex}';
  }

ExerciseScreenArguments({this.exerciseId, required this.examId, this.exerciseIndex = 0});
}

enum LoadingState { loading, finished, error }

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() =>
      _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  /// 绘制控制器
  final DrawingController _drawingController = DrawingController();
  final TransformationController _transformationController = TransformationController();
  late ExerciseScreenArguments args;
  bool hasImageSolution = false;
  Exam? exam;
  int exerciseIndex = 0;
  bool exerciseExpanded = true;
  double _colorOpacity = 1;
  LoadingState loadingState = LoadingState.loading;
  bool showCorrection = false;
  bool hasShownSnackbar = false;



  Future<void> _loadAnswer(List<Map<String, dynamic>> data) async {
    final contents = data.map((json) => _mapJsonToPaintContent(json)).toList();
    _drawingController.clear();
    _drawingController.addContents(
      contents,
    ); // :contentReference[oaicite:13]{index=13}
  }

  Widget lockedSolutionMessage(
    ColorScheme colorScheme,
    Exercise currentExercise,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '📸 Foto wurde zur Lösung hinzugefügt',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            '✏️ Um wieder zeichnen zu können, entfernen Sie zuerst das Foto.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (currentExercise.solutionImages != null &&
              currentExercise.solutionImages!.isNotEmpty)
            ...currentExercise.solutionImages!.map(
              (img) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Image.memory(
                  base64Decode(img.content),
                  fit: BoxFit.contain,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            ),
          ElevatedButton.icon(
            icon: const Icon(Icons.remove_circle_outline),
            label: const Text('Foto entfernen'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                currentExercise.solutionImages?.clear();
                hasImageSolution = false;
                _loadAnswer(currentExercise.answer);
              });
            },
          ),
        ],
      ),
    );
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
    args = ModalRoute
        .of(context)!
        .settings
        .arguments as ExerciseScreenArguments;
    print('args: $args');
    exam = await FirebaseService.getExam(args.examId).then((value) {
      if (value == null) {
        print('Exam not found');
        setState(() {
          loadingState = LoadingState.error;
        });
        return null;
      }
      if (value.exercises.isEmpty) {
        print('No exercises found');
        setState(() {
          loadingState = LoadingState.error;
        });
        return null;
      }
      return value;
    });
    print('exam: ${exam?.exercises[exerciseIndex].answer}');
    if (exam != null) {
      // If exerciseId is provided, find the corresponding exercise
      if (args.exerciseId != null) {
        for (int i = 0; i < exam!.exercises.length; i++) {
          if (exam!.exercises[i].id == args.exerciseId) {
            exerciseIndex = i;
            break;
          }
        }
      } else {
        // Otherwise use the provided index
        exerciseIndex = args.exerciseIndex;
      }

      _loadAnswer(exam!.exercises[exerciseIndex].answer);

      setState(() {
        loadingState = LoadingState.finished;
      });
    }

    super.didChangeDependencies();
  }

  beforeExerciseSwitch(Exercise currentExercise) async {
    currentExercise.answer = _drawingController.getJsonList();
    currentExercise.answerImage = await _drawingController.getImageData();
    ref.read(isCorrectionReadyProvider.notifier).state = false;
    ref.read(correctionDataProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;



    switch (loadingState) {
      case LoadingState.loading:
        return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()));
      case LoadingState.error:
        return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(child: Text('Error loading exam')));
      case LoadingState.finished:
        Exercise currentExercise = exam!.exercises[exerciseIndex];
        _loadAnswer(currentExercise.answer);


        final correction = ref.watch(
          correctionStreamProvider(
            CorrectionParams(examId: exam!.id, exerciseId: currentExercise.id),
          ),
        );

        correction.whenData((doc) {
          final data = doc.data();
          print('aaaaahh new Correction data: ${data?['correction']}');
          if (data?['correction'] != null && !ref.read(isCorrectionReadyProvider)) {
            print('Correction data received: ${data!['correction']}');
            Future.microtask(() {
              ref.read(isCorrectionReadyProvider.notifier).state = true;
              ref.read(correctionDataProvider.notifier).state = data;
            });
          }
        });


        final isReady = ref.watch(isCorrectionReadyProvider);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            leading: PopupMenuButton<Color>(
              icon: const Icon(Icons.color_lens),
              onSelected: (ui.Color value) =>
                  _drawingController.setStyle(color: value.withValues(alpha: _colorOpacity)),
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
                    return PopupMenuItem<ui.Color>(
                        value: color, child: Container(width: 100, height: 50, color: color));
                  }),
                ];
              },
            ),
            title: const Text('Drawing Test'),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            actions: <Widget>[
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: showCorrection,

                  onChanged: isReady ? (value) {
                    setState(() {
                      showCorrection = value;
                    });
                  } : null,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (pickedFile != null) {
                    final bytes = await pickedFile.readAsBytes();

                    final encodedImage = EncodedImage(
                      title: 'Solution Image',
                      content: base64Encode(bytes),
                    );

                    setState(() {
                      currentExercise.solutionImages ??= [];
                      currentExercise.solutionImages!.add(encodedImage);
                      hasImageSolution = true;
                    });
                  } else {
                    print('No image selected.');
                  }
                },
              ),

              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () async {
                  currentExercise.answer = _drawingController.getJsonList();
                  currentExercise.answerImage = await _drawingController.getImageData();
                  await exam?.save();
                  print('Saved answer');
                  await correction_srv.triggerCorrection(
                    exam!.id,
                    currentExercise.id,
                  );
                  print("Correction gets triggered");
                },
              ),
              // IconButton(icon: const Icon(Icons.line_axis), onPressed: _addTestLine),
              // IconButton(icon: const Icon(Icons.javascript_outlined), onPressed: _getJson),
              // IconButton(icon: const Icon(Icons.check), onPressed: _getImageData),
              // IconButton(icon: const Icon(Icons.restore_page_rounded), onPressed: _restBoard),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  currentExercise.answer = _drawingController.getJsonList();
                  currentExercise.answerImage =
                      await _drawingController.getImageData();
                  // Ensure solutionImages is not lost if already present
                  if (currentExercise.solutionImages == null) {
                    currentExercise.solutionImages = [];
                  }
                  await exam?.save();
                  print('Saved answer');
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
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: !exerciseExpanded ?
                                Container() :
                                showCorrection
                                    ? CorrectionView(
                                        exam: exam!,
                                        exercise: currentExercise,
                                        correction: ref.watch(correctionDataProvider),
                                      )
                                    : ExerciseView(
                                      exam: exam!,
                                      currentExercise: currentExercise,
                                    ),
                          ),
                        ),
                      ),

                      //Drawing Board
                      Expanded(
                        flex: exerciseExpanded ? 1 : 9,
                        child: hasImageSolution
                            ? lockedSolutionMessage(
                          colorScheme,
                          currentExercise,
                        )
                            : CustomDrawingBoard(
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
                      translation:
                          exerciseExpanded ? Offset(0, 0) : Offset(-0.5, 0),
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
                          onPressed: () async {
                            beforeExerciseSwitch(currentExercise);

                            setState(() {
                              showCorrection = false;
                              currentExercise.answer = _drawingController.getJsonList();
                              if (exerciseIndex > 0) {
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
                          onPressed: () async {
                            beforeExerciseSwitch(currentExercise);

                            setState(() {
                              showCorrection = false;
                              if (exerciseIndex < exam!.exercises.length - 1) {
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
}


// Questions List
// Builder(builder: (context) {
//   if (currentExercise.questions == null || currentExercise.questions!.isEmpty) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         'No questions available for this exercise.',
//         style: TextStyle(color: Colors.grey[600]),
//       ),
//     );
//   }
//   return Expanded(
//     child: ListView.builder(
//       itemCount: currentExercise.questions!.length,
//       itemBuilder: (context, index) {
//         final question = currentExercise.questions![index];
//         print('Question: ${question.title}, Description: ${question.description}');
//         final questionTitle = question.title.isNotEmpty ? wrapInlineMath(question.title) : 'Question ${index + 1}';
//         final questionDescription = question.description.isNotEmpty
//             ? wrapInlineMath(question.description)
//             : 'No description available for this question.';
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//           child: TeXView(child: TeXViewColumn(
//             children: [
//               TeXViewDocument(
//                 '$questionTitle) $questionDescription',
//                 style: TeXViewStyle(
//                   fontStyle: TeXViewFontStyle(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//           ),
//         );
//       },
//     ),
//   );
// }),
