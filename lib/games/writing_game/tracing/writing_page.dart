// tracing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/phonetics_painter.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_models.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_manager.dart';
import 'package:mundodaspalavras/games/writing_game/enums/shape_enums.dart';


class TracingCharsGame extends StatefulWidget {
  const TracingCharsGame({
    super.key,
    required this.traceShapeModel,
    this.loadingIndictor = const CircularProgressIndicator(),
    this.showAnchor = true,
    this.onTracingUpdated,
    this.onGameFinished,
    this.onCurrentTracingScreenFinished,
  });

  final List<TraceCharsModel> traceShapeModel;
  final Widget loadingIndictor;
  final bool showAnchor;
  final Future<void> Function(int index)? onTracingUpdated;
  final Future<void> Function(int index)? onGameFinished;
  final Future<void> Function(int index)? onCurrentTracingScreenFinished;

  @override
  State<TracingCharsGame> createState() => _TracingCharsGameState();
}

class _TracingCharsGameState extends State<TracingCharsGame> {
  late TracingCubit tracingCubit;

  @override
  void initState() {
    super.initState();
    tracingCubit = TracingCubit(
      stateOfTracing: StateOfTracing.chars,
      traceShapeModel: widget.traceShapeModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TracingGameScaffold(
      tracingCubit: tracingCubit,
      showAnchor: widget.showAnchor,
      loadingIndicator: widget.loadingIndictor,
      onTracingUpdated: widget.onTracingUpdated,
      onGameFinished: widget.onGameFinished,
      onCurrentTracingScreenFinished: widget.onCurrentTracingScreenFinished,
      isWordGame: false,
    );
  }
}

class TracingWordGame extends StatefulWidget {
  const TracingWordGame({
    super.key,
    required this.words,
    this.loadingIndictor = const CircularProgressIndicator(),
    this.showAnchor = true,
    this.onTracingUpdated,
    this.onGameFinished,
    this.onCurrentTracingScreenFinished,
  });

  final List<TraceWordModel> words;
  final Future<void> Function(int index)? onTracingUpdated;
  final Future<void> Function(int index)? onGameFinished;
  final Future<void> Function(int index)? onCurrentTracingScreenFinished;
  final Widget loadingIndictor;
  final bool showAnchor;

  @override
  State<TracingWordGame> createState() => _TracingWordGameState();
}

class _TracingWordGameState extends State<TracingWordGame> {
  late TracingCubit tracingCubit;

  @override
  void initState() {
    super.initState();
    tracingCubit = TracingCubit(
      stateOfTracing: StateOfTracing.traceWords,
      traceWordModels: widget.words,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TracingGameScaffold(
      tracingCubit: tracingCubit,
      showAnchor: widget.showAnchor,
      loadingIndicator: widget.loadingIndictor,
      onTracingUpdated: widget.onTracingUpdated,
      onGameFinished: widget.onGameFinished,
      onCurrentTracingScreenFinished: widget.onCurrentTracingScreenFinished,
      isWordGame: true,
    );
  }
}

class TracingGameScaffold extends StatelessWidget {
  const TracingGameScaffold({
    super.key,
    required this.tracingCubit,
    required this.showAnchor,
    required this.loadingIndicator,
    required this.onTracingUpdated,
    required this.onGameFinished,
    required this.onCurrentTracingScreenFinished,
    required this.isWordGame,
  });

  final TracingCubit tracingCubit;
  final bool showAnchor;
  final Widget loadingIndicator;
  final Future<void> Function(int index)? onTracingUpdated;
  final Future<void> Function(int index)? onGameFinished;
  final Future<void> Function(int index)? onCurrentTracingScreenFinished;
  final bool isWordGame;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => tracingCubit,
      child: BlocConsumer<TracingCubit, TracingState>(
        listener: (context, state) async {
          if (state.drawingStates == DrawingStates.tracing) {
            if (onTracingUpdated != null) await onTracingUpdated!(state.activeIndex);
          } else if (state.drawingStates == DrawingStates.finishedCurrentScreen) {
            if (onCurrentTracingScreenFinished != null) {
              await onCurrentTracingScreenFinished!(state.index + 1);
            }
            if (context.mounted) tracingCubit.updateIndex();
          } else if (state.drawingStates == DrawingStates.gameFinished) {
            if (onGameFinished != null) await onGameFinished!(state.index);
          }
        },
        builder: (context, state) {
          if ((isWordGame && state.traceWordModels!.isEmpty) ||
              (!isWordGame && state.traceShapeModel!.isEmpty)) {
            return const SizedBox();
          }

          if (state.drawingStates == DrawingStates.loading ||
              state.drawingStates == DrawingStates.initial) {
            return loadingIndicator;
          }

          return Center(
            child: FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(state.letterPathsModels.length, (index) {
                  final model = state.letterPathsModels[index];
                  return Container(
                    height: model.viewSize.width,
                    width: model.viewSize.height,
                    margin: model.isSpace ? const EdgeInsets.only(right: 150) : EdgeInsets.zero,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: GestureDetector(
                        onPanStart: (details) {
                          if (index == state.activeIndex) {
                            tracingCubit.handlePanStart(details.localPosition);
                          }
                        },
                        onPanUpdate: (details) {
                          if (index == state.activeIndex) {
                            tracingCubit.handlePanUpdate(details.localPosition);
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomPaint(
                              size: tracingCubit.viewSize,
                              painter: PhoneticsPainter(
                                strokeIndex: model.strokeIndex,
                                indexPath: model.letterIndex,
                                dottedPath: model.dottedIndex,
                                letterColor: model.outerPaintColor,
                                letterImage: model.letterImage!,
                                paths: model.paths,
                                currentDrawingPath: model.currentDrawingPath,
                                pathPoints: model.allStrokePoints.expand((e) => e).toList(),
                                strokeColor: model.innerPaintColor,
                                viewSize: model.viewSize,
                                strokePoints: model.allStrokePoints[model.currentStroke],
                                strokeWidth: model.strokeWidth,
                                dottedColor: model.dottedColor,
                                indexColor: model.indexColor,
                                indexPathPaintStyle: model.indexPathPaintStyle,
                                dottedPathPaintStyle: model.dottedPathPaintStyle,
                              ),
                            ),
                            if (index == state.activeIndex && showAnchor)
                              Positioned(
                                top: model.anchorPos!.dy,
                                left: model.anchorPos!.dx,
                                child: Image.asset(
                                  'assets/images/position_2_finger.png',
                                  height: 50,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}
