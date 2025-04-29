import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_drawing_board/paint_extension.dart';
//
// const Map<String, dynamic> _testLine1 = <String, dynamic>{
//   'type': 'StraightLine',
//   'startPoint': <String, dynamic>{'dx': 68.94337550070736, 'dy': 62.05980083656557},
//   'endPoint': <String, dynamic>{'dx': 277.1373386828114, 'dy': 277.32029957032194},
//   'paint': <String, dynamic>{
//     'blendMode': 3,
//     'color': 4294198070,
//     'filterQuality': 3,
//     'invertColors': false,
//     'isAntiAlias': false,
//     'strokeCap': 1,
//     'strokeJoin': 1,
//     'strokeWidth': 4.0,
//     'style': 1,
//   },
// };
//
// const Map<String, dynamic> _testLine2 = <String, dynamic>{
//   'type': 'StraightLine',
//   'startPoint': <String, dynamic>{'dx': 106.35164817830423, 'dy': 255.9575653134524},
//   'endPoint': <String, dynamic>{'dx': 292.76034659254094, 'dy': 92.125586665872},
//   'paint': <String, dynamic>{
//     'blendMode': 3,
//     'color': 4294198070,
//     'filterQuality': 3,
//     'invertColors': false,
//     'isAntiAlias': false,
//     'strokeCap': 1,
//     'strokeJoin': 1,
//     'strokeWidth': 4.0,
//     'style': 1,
//   },
// };

/// Custom drawn triangles
class Triangle extends PaintContent {
  Triangle();

  Triangle.data({required this.startPoint, required this.A, required this.B, required this.C, required Paint paint})
      : super.paint(paint);

  factory Triangle.fromJson(Map<String, dynamic> data) {
    return Triangle.data(
      startPoint: jsonToOffset(data['startPoint'] as Map<String, dynamic>),
      A: jsonToOffset(data['A'] as Map<String, dynamic>),
      B: jsonToOffset(data['B'] as Map<String, dynamic>),
      C: jsonToOffset(data['C'] as Map<String, dynamic>),
      paint: jsonToPaint(data['paint'] as Map<String, dynamic>),
    );
  }

  Offset startPoint = Offset.zero;

  Offset A = Offset.zero;
  Offset B = Offset.zero;
  Offset C = Offset.zero;

  @override
  String get contentType => 'Triangle';

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) {
    A = Offset(startPoint.dx + (nowPoint.dx - startPoint.dx) / 2, startPoint.dy);
    B = Offset(startPoint.dx, nowPoint.dy);
    C = nowPoint;
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    final Path path =
    Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  Triangle copy() => Triangle();

  @override
  Map<String, dynamic> toContentJson() {
    return <String, dynamic>{
      'startPoint': startPoint.toJson(),
      'A': A.toJson(),
      'B': B.toJson(),
      'C': C.toJson(),
      'paint': paint.toJson(),
    };
  }
}

class CustomDrawingBoard extends StatefulWidget {
  const CustomDrawingBoard({
    super.key,
    required TransformationController transformationController,
    required DrawingController drawingController,
    required this.colorScheme,
  }) : _transformationController = transformationController,
        _drawingController = drawingController;

  final TransformationController _transformationController;
  final DrawingController _drawingController;
  final ColorScheme colorScheme;

  @override
  State<CustomDrawingBoard> createState() => _CustomDrawingBoardState();
}

class _CustomDrawingBoardState extends State<CustomDrawingBoard> {
  bool lockMovement = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return DrawingBoard(
          // boardPanEnabled: false,
          // boardScaleEnabled: false,
          transformationController: widget._transformationController,
          controller: widget._drawingController,
          background: Container(width: constraints.maxWidth, height: constraints.maxHeight, color: widget.colorScheme.surface),
          showDefaultActions: true,
          showDefaultTools: true,
          boardScaleEnabled: false,
          maxScale: 10,
          minScale: 1,
          defaultToolsBuilder: (Type t, _) {
            return DrawingBoard.defaultTools(t, widget._drawingController)
              ..insert(
                1,
                DefToolItem(
                  icon: Icons.change_history_rounded,
                  isActive: t == Triangle,
                  onTap: () => widget._drawingController.setPaintContent(Triangle()),
                ),
              )
                ..insert(2,
                DefToolItem(icon: lockMovement ? Icons.lock : Icons.lock_open, isActive: false,
                onTap: () => setState(() {
                  lockMovement = !lockMovement;
                }),)

                );
            // ..insert(
            //   2,
            //   DefToolItem(
            //     icon: Icons.image_rounded,
            //     isActive: t == ImageContent,
            //     onTap: () async {
            //       showDialog(
            //         context: context,
            //         barrierDismissible: false,
            //         builder: (BuildContext c) {
            //           return const Center(child: CircularProgressIndicator());
            //         },
            //       );
            //
            //       try {
            //         _drawingController.setPaintContent(ImageContent(await _getImage(_imageUrl), imageUrl: _imageUrl));
            //       } catch (e) {
            //         //
            //       } finally {
            //         if (context.mounted) {
            //           Navigator.pop(context);
            //         }
            //       }
            //     },
            //   ),
            // );
          },
        );
      },
    );
  }
}
