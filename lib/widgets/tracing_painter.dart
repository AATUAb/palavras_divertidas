import 'package:flutter/material.dart';

/// Widget que desenha uma letra tracejada na tela
class TracingPainter extends StatelessWidget {
  final String character;

  const TracingPainter(this.character, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TracingPainter(character),
      size: Size(200, 200),
    );
  }
}

/// Pintor da letra/número com estilo tracejado e centralizado
class _TracingPainter extends CustomPainter {
  final String character;

  _TracingPainter(this.character);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontSize: 150,
          color: Colors.grey.withOpacity(0.5),
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

/// Desenha o traçado do utilizador
class UserDrawingPainter extends CustomPainter {
  final List<Offset> points;

  UserDrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 8
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
