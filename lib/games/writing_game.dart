import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:audioplayers/audioplayers.dart';
import '../../models/user_model.dart';
import '../../widgets/game_super_widget.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/tracing_models.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/tracing_page.dart';


class WritingGame extends StatefulWidget {
  final UserModel user;
  const WritingGame({super.key, required this.user});

  @override
  State<WritingGame> createState() => _WritingGameState();
}

class _WritingGameState extends State<WritingGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  bool showIntroImage = true;
  bool showTracing = false;

  @override
  void initState() {
    super.initState();

    // Exibe imagem por 2s, depois mostra o tracing da letra A
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => showIntroImage = false);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => showTracing = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Jogo da Escrita',
      progressValue: 1.0,
      level: (_) => 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: widget.user.schoolLevel == '1º Ciclo',
      topTextContent: _buildTopText,
      builder: _buildGameBoard,
      //onRepeatInstruction: _playInstructionAudio,
      introImagePath: null,
      introAudioPath: null,
      onIntroFinished: null,
    );
  }

  /*Future<void> _playInstructionAudio() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/write_game_instruction.mp3'));
  }*/

  Widget _buildTopText() {
    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Text(
        'Prepara-te para escrever!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildGameBoard(BuildContext context, _, __) {
    if (showIntroImage) {
      return Center(
        child: Image.asset(
          'assets/images/write_game.webp',
          width: 250.w,
          height: 180.h,
          fit: BoxFit.contain,
        ),
      );
    }

    if (showTracing) {
      return Center( // ← envolvemos em Center para evitar problemas de layout
        child: SizedBox(
          width: 400.w,
          height: 400.h,
          child: TracingCharsGame(
            showAnchor: true,
            traceShapeModel: [
              TraceCharsModel(
                chars: [
                  TraceCharModel(
                    char: 'A',
                    traceShapeOptions: const TraceShapeOptions(
                      innerPaintColor: Colors.orange,
                      indexColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
            onTracingUpdated: (_) async {},
            onGameFinished: (_) async {},
            onCurrentTracingScreenFinished: (_) async {},
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
