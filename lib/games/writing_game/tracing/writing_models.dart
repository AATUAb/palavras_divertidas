//writing_models.dart

import 'package:flutter/material.dart';
import 'package:mundodaspalavras/themes/colors.dart';

/// Modelo principal para armazenar caminhos e configurações de uma letra/palavra
class TraceModel {
  final bool isSpace;
  final String letterPath;
  final String pointsJsonFile;
  final String dottedPath;
  final String indexPath;
  final bool? disableDividedStrokes;
  final Color outerPaintColor;
  final Color innerPaintColor;
  final Color dottedColor;
  final Color indexColor;
  final double strokeWidth;
  final PaintingStyle? indexPathPaintStyle;
  final PaintingStyle? dottedPathPaintStyle;
  final Size? positionIndexPath;
  final Size? positionDottedPath;
  final double? scaleIndexPath;
  final double? scaledottedPath;
  final double? distanceToCheck;
  final Size letterViewSize;
  final double? strokeIndex;

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

/// Modelo que representa uma palavra inteira para tracing
class TraceWordModel {
  final String word;
  final TraceShapeOptions traceShapeOptions;

  TraceWordModel({
    required this.word,
    this.traceShapeOptions = const TraceShapeOptions(),
  });
}

/// Modelo que representa um conjunto de caracteres para tracing (ex: número ou grupo de letras)
class TraceCharsModel {
  final List<TraceCharModel> chars;

  TraceCharsModel({required this.chars});
}

/// Modelo individual para cada caracter dentro de um TraceCharsModel
class TraceCharModel {
  final String char;
  final TraceShapeOptions traceShapeOptions;

  TraceCharModel({
    required this.char,
    this.traceShapeOptions = const TraceShapeOptions(),
  });
}

/// Opções de estilo e cor para cada tipo de traçado
class TraceShapeOptions {
  final Color outerPaintColor;
  final Color innerPaintColor;
  final Color dottedColor;
  final Color indexColor;

  const TraceShapeOptions({
    this.dottedColor = AppColors.grey,
    this.indexColor = Colors.black,
    this.innerPaintColor = AppColors.lightBlue,
    this.outerPaintColor = AppColors.darkBlue,
  });
}
