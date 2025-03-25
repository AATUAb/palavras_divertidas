// Widget do jogo "Write_game", jogo 2

import 'package:flutter/material.dart';

///  Widget que desenha uma letra tracejada na tela para o utilizador seguir
class TracingPainter extends StatelessWidget {
  final String character; // Letra ou número a ser desenhado

  const TracingPainter(this.character, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TracingPainter(character), // Usa o pintor personalizado
      size: Size(200, 200),                // Tamanho fixo da área de pintura
    );
  }
}

/// Pintor que desenha a letra de fundo de forma tracejada (como guia)
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
          color: Colors.grey.withOpacity(0.5),  // Letra cinza semi-transparente
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline, // Sublinhar a letra
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(); // Calcula o tamanho do texto
    textPainter.paint(canvas, Offset(25, 25)); // Desenha no canvas
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false; // Não precisa redesenhar
}

/// Pintor que desenha os traços feitos pelo utilizador com o dedo
class UserDrawingPainter extends CustomPainter {
  final List<Offset> points; // Lista de pontos desenhados

  UserDrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Conecta os pontos com linhas, exceto onde houver separadores (Offset.infinite)
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true; // Redesenha sempre
}
