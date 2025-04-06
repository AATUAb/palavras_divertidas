import 'package:flutter/material.dart';

class TracingPainter extends StatelessWidget {
  final String character;
  final double fontSize;

  const TracingPainter(this.character, {super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TracingPainter(character, fontSize),
      size: Size.infinite,
    );
  }
}

class _TracingPainter extends CustomPainter {
  final String character;
  final double fontSize;

  _TracingPainter(this.character, this.fontSize);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.grey.withAlpha((255 * 0.5).toInt()),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class UserDrawingPainter extends CustomPainter {
  final List<Offset> points;
  final double strokeWidth;

  UserDrawingPainter(this.points, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
