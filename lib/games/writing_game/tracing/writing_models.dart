import 'package:flutter/material.dart';
import 'package:mundodaspalavras/themes/colors.dart';

/// Enumeração que define os tipos de fontes disponíveis
enum FontType {
  machine, // Fonte de máquina (impressa)
  cursive, // Fonte cursiva (manual)
}

/// Modelo principal que armazena todas as configurações de uma letra ou espaço
class TraceModel {
  final bool isSpace; // Indica se o caractere é um espaço em branco
  final String letterPath; // Caminho SVG da letra
  final String pointsJsonFile; // Caminho do arquivo JSON com os pontos
  final String dottedPath; // Caminho SVG do traçado pontilhado
  final String indexPath; // Caminho SVG dos índices (numeração dos traços)
  final bool? disableDividedStrokes; // Desabilita separação de traços
  final Color outerPaintColor; // Cor da borda externa
  final Color innerPaintColor; // Cor do preenchimento interno
  final Color dottedColor; // Cor do traçado pontilhado
  final Color indexColor; // Cor dos índices de traçado
  final double strokeWidth; // Espessura do traçado
  final PaintingStyle? indexPathPaintStyle; // Estilo do traçado dos índices
  final PaintingStyle? dottedPathPaintStyle; // Estilo do traçado pontilhado
  final Size? positionIndexPath; // Posição do path de índice
  final Size? positionDottedPath; // Posição do path pontilhado
  final double? scaleIndexPath; // Escala do path de índice
  final double? scaledottedPath; // Escala do path pontilhado
  final double? distanceToCheck; // Distância para validar o toque
  final Size letterViewSize; // Tamanho da visualização da letra
  final double? strokeIndex; // Espessura do índice (numeração)

  TraceModel({
    this.isSpace = false,
    this.letterViewSize = const Size(200, 200),
    this.disableDividedStrokes,
    this.strokeIndex,
    this.distanceToCheck,
    this.scaledottedPath,
    this.scaleIndexPath,
    this.positionIndexPath,
    this.positionDottedPath,
    this.indexPathPaintStyle,
    this.dottedPathPaintStyle,
    this.strokeWidth = 55,
    this.indexColor = Colors.black,
    this.outerPaintColor = Colors.red,
    this.innerPaintColor = Colors.blue,
    this.dottedColor = Colors.amber,
    required this.dottedPath,
    required this.indexPath,
    required this.letterPath,
    required this.pointsJsonFile,
  });

  /// Retorna uma nova instância com valores atualizados, mantendo os existentes por padrão
  TraceModel copyWith({
    bool? isSpace,
    String? letterPath,
    String? pointsJsonFile,
    String? dottedPath,
    String? indexPath,
    bool? disableDividedStrokes,
    Color? outerPaintColor,
    Color? innerPaintColor,
    Color? dottedColor,
    Color? indexColor,
    double? strokeWidth,
    PaintingStyle? indexPathPaintStyle,
    PaintingStyle? dottedPathPaintStyle,
    Size? positionIndexPath,
    Size? positionDottedPath,
    double? scaleIndexPath,
    double? scaledottedPath,
    double? distanceToCheck,
    Size? letterViewSize,
    double? strokeIndex,
  }) {
    return TraceModel(
      isSpace: isSpace ?? this.isSpace,
      letterPath: letterPath ?? this.letterPath,
      pointsJsonFile: pointsJsonFile ?? this.pointsJsonFile,
      dottedPath: dottedPath ?? this.dottedPath,
      indexPath: indexPath ?? this.indexPath,
      disableDividedStrokes: disableDividedStrokes ?? this.disableDividedStrokes,
      outerPaintColor: outerPaintColor ?? this.outerPaintColor,
      innerPaintColor: innerPaintColor ?? this.innerPaintColor,
      dottedColor: dottedColor ?? this.dottedColor,
      indexColor: indexColor ?? this.indexColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      indexPathPaintStyle: indexPathPaintStyle ?? this.indexPathPaintStyle,
      dottedPathPaintStyle: dottedPathPaintStyle ?? this.dottedPathPaintStyle,
      positionIndexPath: positionIndexPath ?? this.positionIndexPath,
      positionDottedPath: positionDottedPath ?? this.positionDottedPath,
      scaleIndexPath: scaleIndexPath ?? this.scaleIndexPath,
      scaledottedPath: scaledottedPath ?? this.scaledottedPath,
      distanceToCheck: distanceToCheck ?? this.distanceToCheck,
      letterViewSize: letterViewSize ?? this.letterViewSize,
      strokeIndex: strokeIndex ?? this.strokeIndex,
    );
  }
}

/// Modelo que representa uma palavra completa que será traçada
class TraceWordModel {
  final String word; // Texto da palavra
  final TraceShapeOptions traceShapeOptions; // Opções de estilo do traçado

  TraceWordModel({
    required this.word,
    this.traceShapeOptions = const TraceShapeOptions(),
  });
}

/// Modelo que representa um grupo de caracteres para traçado (ex: letras ou números)
class TraceCharsModel {
  final List<TraceCharModel> chars; // Lista de caracteres com estilos individuais

  TraceCharsModel({required this.chars});
}

/// Modelo individual de traçado para um caractere dentro de TraceCharsModel
class TraceCharModel {
  final String char; // Letra ou número a ser traçado
  final TraceShapeOptions traceShapeOptions; // Estilo visual do traçado

  TraceCharModel({
    required this.char,
    this.traceShapeOptions = const TraceShapeOptions(),
  });
}

/// Opções de estilo visual do traçado (cores da linha, contorno, etc.)
class TraceShapeOptions {
  final Color outerPaintColor; // Cor da linha externa
  final Color innerPaintColor; // Cor da linha interna
  final Color dottedColor; // Cor da linha pontilhada
  final Color indexColor; // Cor da numeração dos traços

  const TraceShapeOptions({
    this.dottedColor = AppColors.grey,
    this.indexColor = Colors.black,
    this.innerPaintColor = AppColors.lightBlue,
    this.outerPaintColor = AppColors.darkBlue,
  });
}
