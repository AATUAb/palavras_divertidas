//phonetics_painter.dart

import 'package:flutter/material.dart';

class PhoneticsPainter extends CustomPainter {
  final Path letterImage;
  final List<Path> paths; // List of paths for strokes
  final Path currentDrawingPath;
  final List<Offset> pathPoints;
  final Color strokeColor;
  final Size viewSize;
  final List<Offset> strokePoints;
  final double? strokeWidth;
  final Color letterColor;
  final Shader? letterShader;
  final Path? dottedPath;
  final Path? indexPath;
  final Color dottedColor;
  final Color indexColor;

  final double? strokeIndex;
  final PaintingStyle? indexPathPaintStyle;
  final PaintingStyle? dottedPathPaintStyle;

  PhoneticsPainter({
    this.strokeIndex,
    this.indexPathPaintStyle,
    this.dottedPathPaintStyle,
    this.dottedPath,
    this.indexPath,
    required this.dottedColor,
    required this.indexColor,
    required this.strokeWidth,
    required this.strokePoints,
    required this.letterImage,
    required this.paths,
    required this.currentDrawingPath,
    required this.pathPoints,
    required this.strokeColor,
    required this.viewSize,
    required this.letterColor,
    this.letterShader,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the letter path
    final letterPaint = Paint()
      ..color = letterColor
      ..style = PaintingStyle.fill;

    // Apply the shader if provided
    if (letterShader != null) {
      letterPaint.shader = letterShader;
    }

    // Draw the letter path with color
    canvas.drawPath(letterImage, letterPaint);
 
    if (dottedPath != null) {
      final debugPaint = Paint()
        ..color = dottedColor
        ..style = dottedPathPaintStyle ?? PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(dottedPath!, debugPaint);
    }

    if (indexPath != null) {
      final debugPaint = Paint()
        ..color = indexColor
        ..style = indexPathPaintStyle ?? PaintingStyle.stroke
        ..strokeWidth = strokeIndex ?? 2.0;
      canvas.drawPath(indexPath!, debugPaint);
    }
    // Clip the canvas to the letter path to prevent drawing outside
    canvas.save();
    canvas.clipPath(letterImage);

    // Paint for the strokes
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth ?? 55;

    // Draw all paths
    for (var path in paths) {
      canvas.drawPath(path, strokePaint);
    }

    // Draw the current drawing path (if needed)
    canvas.drawPath(currentDrawingPath, strokePaint);

    // Restore the canvas state after clipping
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
