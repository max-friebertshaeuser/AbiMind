import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/src/paint_contents/straight_line.dart';



const Map<String, dynamic> _testLine1 = <String, dynamic>{
  'type': 'StraightLine',
  'startPoint': <String, dynamic>{
    'dx': 68.94337550070736,
    'dy': 62.05980083656557
  },
  'endPoint': <String, dynamic>{
    'dx': 277.1373386828114,
    'dy': 277.32029957032194
  },
  'paint': <String, dynamic>{
    'blendMode': 3,
    'color': 4294198070,
    'filterQuality': 3,
    'invertColors': false,
    'isAntiAlias': false,
    'strokeCap': 1,
    'strokeJoin': 1,
    'strokeWidth': 4.0,
    'style': 1
  }
};


class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late DrawingController _drawingController;
  double _colorOpacity = 1;

  @override
  void initState() {
    super.initState();
    _drawingController = DrawingController();

    _drawingController.setStyle(color: Colors.black);

  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  void drawLine(){
    _drawingController.addContent(StraightLine.fromJson(_testLine1));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<Color>(
          icon: const Icon(Icons.color_lens),
          onSelected: (Color value) => _drawingController.setStyle(
              color: value.withValues(alpha: _colorOpacity)),
          itemBuilder: (_) {
            return <PopupMenuEntry<Color>>[
              PopupMenuItem<Color>(
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      Function(void Function()) setState) {
                    return Slider(
                      value: _colorOpacity,
                      onChanged: (double v) {
                        setState(() => _colorOpacity = v);
                        _drawingController.setStyle(
                          color: _drawingController.drawConfig.value.color
                              .withValues(alpha: _colorOpacity),
                        );
                      },
                    );
                  },
                ),
              ),
              ...Colors.accents.map((Color color) {
                return PopupMenuItem<Color>(
                    value: color,
                    child: Container(width: 100, height: 50, color: color));
              }),
            ];
          },
        ),
        title: const Text('Drawing Test'),
      ),
      body: Column(
        children: [
          // Task display at the top
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey[200],
            child: const Text(
              'Solve: (x + 3)(x - 2)',
              style: TextStyle(fontSize: 20),
            ),
          ),

          const SizedBox(height: 10),

          // Toolbar for drawing
          // DrawingToolbar(controller: _drawingController),

          // Drawing area (fills remaining screen)
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 50),
              color: Colors.white,
              child: DrawingBoard(
                controller: _drawingController,
                background: Container(color: Colors.lightBlue),
                showDefaultTools: true,
                showDefaultActions: true,
                defaultToolsBuilder: (Type t, _drawingController) {
                  return DrawingBoard.defaultTools(t, _drawingController )
                    ..insert(
                      1,
                      DefToolItem(
                        icon: Icons.abc,
                        isActive: true,
                        onTap: () => drawLine()
                      ),
                    );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



