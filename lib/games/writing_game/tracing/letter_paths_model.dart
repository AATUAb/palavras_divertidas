//letter_paths_model.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Modelo que representa os dados de traçado (tracing) de uma letra.
/// Inclui caminhos (paths), imagens auxiliares, configurações de pintura,
/// e o estado atual do progresso do traçado.
class LetterPathsModel {
  /// Indica se o caractere atual é um espaço (sem traçado)
  final bool  isSpace;
  /// Caminho principal da forma da letra (SVG convertido em Path)
  Path? letterImage;
  /// Caminho do tracejado pontilhado de referência
  Path? dottedIndex;
  /// Caminho do índice (como números de etapas de traçado)
  Path? letterIndex;
  /// Largura do traço usado na pintura
  double strokeWidth;
  /// Imagem do tracejado pontilhado 
  ui.Image? dottedImage;
  /// Imagem da âncora, se usada para ponto de partida visual
  ui.Image? anchorImage;
  /// Indica se deve desabilitar traçados divididos (traço contínuo)
  final bool? disableDivededStrokes;
  /// Lista de todos os caminhos esperados para a letra (cada traço individual)
  late List<ui.Path> paths;
  /// Caminho atual que está sendo desenhado pelo usuário
  late ui.Path currentDrawingPath;
  /// Lista com os pontos de todos os traços realizados
  late List<List<Offset>> allStrokePoints;
  /// Posição de início do traçado (caso tenha uma âncora)
  Offset? anchorPos;
  /// Tamanho da visualização da letra
  Size viewSize;
  /// Indica se o traçado completo da letra foi finalizado
  bool letterTracingFinished;
  /// Indica se pelo menos um traço foi completado
  bool hasFinishedOneStroke;
  /// Índice do traço atual que está sendo desenhado
  int currentStroke;
  /// Progresso dentro do traço atual (em pontos)
  int currentStrokeProgress;
  /// Cor do contorno externo
  final Color outerPaintColor;
  /// Cor do contorno interno (traço desenhado)
  final Color innerPaintColor;
  /// Cor do tracejado pontilhado de referência
  final Color dottedColor;
  /// Cor do índice do traçado
  final Color indexColor;
  /// Estilo de pintura para o índice (fill ou stroke)
  final PaintingStyle? indexPathPaintStyle;
  /// Estilo de pintura para o tracejado pontilhado
  final PaintingStyle? dottedPathPaintStyle;
  /// Espessura do índice (caso seja diferente do traçado normal)
  final double? strokeIndex;
  /// Distância mínima para validação do ponto no traçado
  final double? distanceToCheck;
  /// Construtor padrão
  
  LetterPathsModel({
        this.isSpace=false,

    this.disableDivededStrokes,
    this.strokeIndex,
    this.distanceToCheck,
    this.indexPathPaintStyle,
    this.dottedPathPaintStyle,
    this.strokeWidth=55,
    this.indexColor = Colors.black,
    this.outerPaintColor = Colors.red,
    this.innerPaintColor = Colors.blue,
    this.dottedColor = Colors.amber,
    this.letterImage,
    this.dottedIndex,
    this.letterIndex,
    this.dottedImage,
    this.anchorImage,
    List<ui.Path>? paths,
    List<List<Offset>>? allStrokePoints,
    this.anchorPos,
    this.viewSize = const Size(200, 200),
    this.letterTracingFinished = false,
    this.hasFinishedOneStroke = false,
    this.currentStroke = 0,
    this.currentStrokeProgress = -1,
  })  : paths = paths ?? [],
        currentDrawingPath = ui.Path(),
        allStrokePoints = allStrokePoints ?? [];

  /// Cria uma nova instância da classe com alguns valores substituídos.
  /// Útil para manter imutabilidade em atualizações parciais.
  LetterPathsModel copyWith({
       bool?  isSpace,

    Path? letterImage,
    Path? dottedIndex,
    Path? letterIndex,
    ui.Image? traceImage,
    ui.Image? dottedImage,
    ui.Image? anchorImage,
    List<ui.Path>? paths,
    List<List<Offset>>? allStrokePoints,
    Offset? anchorPos,
    Size? viewSize,
    bool? letterTracingFinished,
    bool? hasFinishedOneStroke,
    int? currentStroke,
    int? currentStrokeProgress,
    bool? isLoaded,


    PaintingStyle? dottedPathPaintStyle,
    PaintingStyle? indexPathPaintStyle,

  }) {
    return LetterPathsModel(
            isSpace: isSpace ?? this.isSpace,

      letterImage: letterImage ?? this.letterImage,
      dottedIndex: dottedIndex ?? this.dottedIndex,
      letterIndex: letterIndex ?? this.letterIndex,
      dottedImage: dottedImage ?? this.dottedImage,
      anchorImage: anchorImage ?? this.anchorImage,
      paths: paths ?? this.paths,
      allStrokePoints: allStrokePoints ?? this.allStrokePoints,
      anchorPos: anchorPos ?? this.anchorPos,
      viewSize: viewSize ?? this.viewSize,
      letterTracingFinished:
          letterTracingFinished ?? this.letterTracingFinished,
      hasFinishedOneStroke: hasFinishedOneStroke ?? this.hasFinishedOneStroke,
      currentStroke: currentStroke ?? this.currentStroke,
      currentStrokeProgress:
          currentStrokeProgress ?? this.currentStrokeProgress,
          dottedPathPaintStyle:  dottedPathPaintStyle ?? this.dottedPathPaintStyle ,
          indexPathPaintStyle: indexPathPaintStyle ?? this.indexPathPaintStyle ,
    );
  }
}