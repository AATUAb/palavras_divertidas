//phonetics_painter.dart

import 'package:flutter/material.dart';

/// Pintor personalizado (CustomPainter) responsável por desenhar:
/// - A forma da letra
/// - O tracejado pontilhado (guia)
/// - Os índices de traçado
/// - Os traços feitos pelo usuário
class PhoneticsPainter extends CustomPainter {
  final Path letterImage;               // Caminho da forma da letra
  final List<Path> paths;              // Lista de caminhos traçados concluídos
  final Path currentDrawingPath;       // Caminho que está sendo desenhado no momento
  final List<Offset> pathPoints;       // Pontos do caminho atual
  final Color strokeColor;             // Cor dos traços desenhados
  final Size viewSize;                 // Tamanho da área de visualização
  final List<Offset> strokePoints;     // Todos os pontos já desenhados
  final double? strokeWidth;           // Espessura do traço
  final Color letterColor;             // Cor da letra de fundo
  final Shader? letterShader;          // Shader (gradiente ou outro efeito visual)
  final Path? dottedPath;              // Caminho pontilhado (guia de traçado)
  final Path? indexPath;               // Caminho dos índices de traçado
  final Color dottedColor;             // Cor do guia pontilhado
  final Color indexColor;              // Cor dos índices

  final double? strokeIndex;                     // Espessura dos índices
  final PaintingStyle? indexPathPaintStyle;      // Estilo de pintura dos índices
  final PaintingStyle? dottedPathPaintStyle;     // Estilo do traço pontilhado

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
        // Pincel para desenhar a letra base (forma de fundo)
    final letterPaint = Paint()
      ..color = letterColor
      ..style = PaintingStyle.fill;

    // Se houver um shader, aplica (ex: gradiente)
    if (letterShader != null) {
      letterPaint.shader = letterShader;
    }

    // Desenha a letra de fundo
    canvas.drawPath(letterImage, letterPaint);
 
    // Desenha o caminho pontilhado (se existir)
    if (dottedPath != null) {
      final debugPaint = Paint()
        ..color = dottedColor
        ..style = dottedPathPaintStyle ?? PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(dottedPath!, debugPaint);
    }
    // Desenha os índices de traçado (números ou marcações)
    if (indexPath != null) {
      final debugPaint = Paint()
        ..color = indexColor
        ..style = indexPathPaintStyle ?? PaintingStyle.stroke
        ..strokeWidth = strokeIndex ?? 2.0;
      canvas.drawPath(indexPath!, debugPaint);
    }
    // Clipa o canvas ao contorno da letra (impede que o traço ultrapasse o limite)
    canvas.save();
    canvas.clipPath(letterImage);

    // Pincel para traços
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth ?? 55;

    // Desenha todos os caminhos já feitos
    for (var path in paths) {
      canvas.drawPath(path, strokePaint);
    }

    // Desenha o caminho que está sendo feito no momento
    canvas.drawPath(currentDrawingPath, strokePaint);

    // Restaura o canvas (tira o clip)
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}