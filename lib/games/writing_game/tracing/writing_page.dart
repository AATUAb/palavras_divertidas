import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/phonetics_painter.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_models.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_manager.dart';
import 'package:mundodaspalavras/games/writing_game/enums/shape_enums.dart';

/// Widget principal para o jogo de traçado de caracteres (letras isoladas)
class TracingCharsGame extends StatefulWidget {
  const TracingCharsGame({
    super.key,
    required this.traceShapeModel,
    required this.stateOfTracing,
    required this.trackingEngine,
    this.fontType = FontType.machine,
    this.loadingIndictor = const CircularProgressIndicator(),
    this.showAnchor = true,
    this.onTracingUpdated,
    this.onGameFinished,
    this.onCurrentTracingScreenFinished,
  });

  final List<TraceCharsModel> traceShapeModel; // Lista de modelos de caracteres a serem traçados
  final StateOfTracing stateOfTracing; // Define se o traçado é de letras ou palavras
  final dynamic trackingEngine; // Mecanismo para validar o traçado
  final FontType fontType; // Tipo da fonte (ex: cursiva, máquina)
  final Widget loadingIndictor; // Indicador de carregamento
  final bool showAnchor; // Mostra ou oculta a imagem de dedo (âncora)
  final Future<void> Function(int index)? onTracingUpdated; // Callback ao atualizar o traçado
  final Future<void> Function(int index)? onGameFinished; // Callback ao finalizar o jogo
  final Future<void> Function(int index)? onCurrentTracingScreenFinished; // Callback ao finalizar uma tela

  @override
  State<TracingCharsGame> createState() => _TracingCharsGameState();
}

class _TracingCharsGameState extends State<TracingCharsGame> {
  late TracingCubit tracingCubit;

  @override
  void initState() {
    super.initState();
    tracingCubit = TracingCubit(
      fontType: widget.fontType,
      stateOfTracing: widget.stateOfTracing,
      traceShapeModel: widget.traceShapeModel,
      trackingEngine: widget.trackingEngine,
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

/// Widget para o jogo de traçado de palavras completas
class TracingWordGame extends StatefulWidget {
  const TracingWordGame({
    super.key,
    required this.words,
    this.fontType = FontType.machine,
    this.loadingIndictor = const CircularProgressIndicator(),
    this.showAnchor = true,
    this.onTracingUpdated,
    this.onGameFinished,
    this.onCurrentTracingScreenFinished,
  });

  final List<TraceWordModel> words; // Lista de palavras a serem traçadas
  final FontType fontType;
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
      fontType: widget.fontType,
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

/// Widget reutilizável que define a interface visual e comportamentos
/// tanto para letras quanto para palavras no jogo de traçado
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
          // Atualiza ao começar a traçar
          if (state.drawingStates == DrawingStates.tracing) {
            if (onTracingUpdated != null) await onTracingUpdated!(state.activeIndex);

          // Finalizou a tela atual de traçado
          } else if (state.drawingStates == DrawingStates.finishedCurrentScreen) {
            if (onCurrentTracingScreenFinished != null) {
              await onCurrentTracingScreenFinished!(state.index + 1);
            }
            if (context.mounted) tracingCubit.updateIndex();

          // Finalizou todo o jogo de traçado
          } else if (state.drawingStates == DrawingStates.gameFinished) {
            final wasSuccessful = state.letterPathsModels.first.letterTracingFinished ? 1 : 0;
            if (onGameFinished != null) await onGameFinished!(wasSuccessful);
          }
        },
        builder: (context, state) {
          // Verifica se há dados de traçado
          if ((isWordGame && state.traceWordModels!.isEmpty) ||
              (!isWordGame && state.traceShapeModel!.isEmpty)) {
            return const SizedBox();
          }

          // Exibe indicador de carregamento se necessário
          if (state.drawingStates == DrawingStates.loading ||
              state.drawingStates == DrawingStates.initial) {
            return loadingIndicator;
          }

          // Exibe a interface de traçado
          return Center(
            child: FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(state.letterPathsModels.length, (index) {
                  final model = state.letterPathsModels[index];
                  return Container(
                    height: model.viewSize.height,
                    width: model.viewSize.width,
                    margin: model.isSpace ? const EdgeInsets.only(right: 150) : EdgeInsets.zero,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: GestureDetector(
                        // Inicia o traçado ao pressionar o dedo
                        onPanStart: (details) {
                          if (index == state.activeIndex) {
                            tracingCubit.handlePanStart(details.localPosition);
                          }
                        },
                        // Atualiza o traçado conforme o dedo se move
                        onPanUpdate: (details) {
                          if (index == state.activeIndex) {
                            tracingCubit.handlePanUpdate(details.localPosition);
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Pintura da letra com todos os caminhos
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
                            // Exibe âncora visual para indicar onde começar o traçado
                            if (index == state.activeIndex && showAnchor)
                              Positioned(
                                top: model.anchorPos!.dy,
                                left: model.anchorPos!.dx,
                                child: Image.asset(
                                  'assets/images/position_2_finger.webp',
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
