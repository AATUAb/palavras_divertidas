import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/user_model.dart';
import '../../widgets/game_super_widget.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_models.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_page.dart';

class WritingGame extends StatefulWidget {
  final UserModel user;
  const WritingGame({super.key, required this.user});

  @override
  State<WritingGame> createState() => _WritingGameState();
}

class _WritingGameState extends State<WritingGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  late final AudioPlayer _audioPlayer;

  bool hasChallengeStarted = false;
  int correctCount = 1;
  int _currentIndex = 0;
  late List<String> _availableLetters;

  String get currentLetter => _availableLetters[_currentIndex];
  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _availableLetters = ['A', 'B', 'C'];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    switch (lvl) {
      case 1:
        correctCount = 1;
        break;
      case 2:
        correctCount = 2;
        break;
      case 3:
        correctCount = 3;
        break;
    }
    setState(() {});
  }

  Future<void> _playInstruction() async {
    await _audioPlayer.stop();
    await _audioPlayer.release();
    await _audioPlayer.play(AssetSource('sounds/characters_sounds/${currentLetter.toUpperCase()}.ogg'));
  }

  void _nextLetter() {
    if (_currentIndex < _availableLetters.length - 1) {
      setState(() => _currentIndex++);
      _playInstruction();
    } else {
      _gamesSuperKey.currentState?.showEndOfGameDialog(onRestart: _restartGame);
    }
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      hasChallengeStarted = false;
    });
  }

  Future<void> _handleTracingFinished(String char) async {
    _gamesSuperKey.currentState?.registerCompletedRound();
    await _gamesSuperKey.currentState?.showSuccessFeedback();

    await _gamesSuperKey.currentState?.levelManager.registerRoundForLevel(
      context: context,
      correct: true,
      applySettings: _applyLevelSettings,
      onFinished: () async {
        if (mounted) _nextLetter();
      },
      showLevelFeedback: (newLevel, increased) async {
        await _gamesSuperKey.currentState?.showLevelChangeFeedback(
          newLevel: newLevel,
          increased: increased,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Jogo da Escrita',
      progressValue: 1.0,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => _currentIndex + 1,
      totalRounds: (_) => _availableLetters.length,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      introImagePath: 'assets/images/games/writing_game.webp',
      introAudioPath: 'sounds/games/writing_game.ogg',
      onIntroFinished: () async {
        await Future.delayed(const Duration(seconds: 2));
        await _applyLevelSettings();
        if (mounted) {
          setState(() => hasChallengeStarted = true);
          await _playInstruction();
        }
      },
      onRepeatInstruction: _playInstruction,
    );
  }

  Widget _buildTopText() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Text(
        hasChallengeStarted ? 'Escreve a letra $currentLetter' : 'Vamos escrever!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBoard(BuildContext context, _, __) {
    if (!hasChallengeStarted) {
      return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
        width: 400.w,
        height: 400.h,
        child: TracingCharsGame(
          key: ValueKey(currentLetter),
          showAnchor: true,
          traceShapeModel: [
            TraceCharsModel(chars: [
              TraceCharModel(
                char: currentLetter,
                traceShapeOptions: const TraceShapeOptions(
                  innerPaintColor: Colors.orange,
                ),
              ),
            ]),
          ],
          onTracingUpdated: (_) async {},
          onGameFinished: (_) async => _handleTracingFinished(currentLetter),
          onCurrentTracingScreenFinished: (_) async {},
        ),
      ),
    );
  }
}
