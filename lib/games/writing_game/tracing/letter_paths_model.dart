//letter_paths_model.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LetterPathsModel {
  final bool  isSpace;
  Path? letterImage;
  Path? dottedIndex;
  Path? letterIndex;
double strokeWidth;
  ui.Image? dottedImage;
  ui.Image? anchorImage;
final bool? disableDivededStrokes;
  late List<ui.Path> paths;
  late ui.Path currentDrawingPath;
  late List<List<Offset>> allStrokePoints;

  Offset? anchorPos;
  Size viewSize;
  bool letterTracingFinished;
  bool hasFinishedOneStroke;
  int currentStroke;
  int currentStrokeProgress;

  final Color outerPaintColor;
  final Color innerPaintColor;
  final Color dottedColor;
  final Color indexColor;
final PaintingStyle? indexPathPaintStyle;
final PaintingStyle? dottedPathPaintStyle;
final double? strokeIndex;

final double? distanceToCheck;
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