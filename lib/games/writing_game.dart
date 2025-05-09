import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/user_model.dart';
import '../../models/character_model.dart';
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
  final _random = Random();
  late final AudioPlayer _audioPlayer;

  bool hasChallengeStarted = false;
  int correctCount = 1;
  List<CharacterModel> _characters = [];
  List<String> _usedCharacters = [];
  double progressValue = 1.0;

  String currentLetter = '';
  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters = box.values.toList();
    await _applyLevelSettings();
    _generateNextLetter();
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
    await _audioPlayer.play(
      AssetSource('sounds/words_characters/${currentLetter.toUpperCase()}.ogg'),
    );
  }

  void _generateNextLetter() {
    final allChars = _characters.map((e) => e.character.toUpperCase()).toList();
    final availableChars = allChars.where((c) => !_usedCharacters.contains(c)).toList();

    if (availableChars.isEmpty) {
      _gamesSuperKey.currentState?.showEndOfGameDialog(onRestart: _restartGame);
      return;
    }

    final next = availableChars[_random.nextInt(availableChars.length)];
    _usedCharacters.add(next);

    setState(() {
      currentLetter = next;
    });

    _playInstruction();
  }

void _restartGame() async {
  // Reinicia o nível manualmente
  _gamesSuperKey.currentState?.levelManager.level = 1;

  // Reinicia o progresso interno
  setState(() {
    _usedCharacters.clear();
    hasChallengeStarted = true;
    progressValue = 1.0;
  });

  // Reaplica definições e inicia primeiro desafio
  await _applyLevelSettings();
  _generateNextLetter();
}

  Future<void> _handleTracingFinished(String char) async {
    _gamesSuperKey.currentState?.registerCompletedRound();
    final levelChanged = await _gamesSuperKey.currentState?.levelManager
        .registerRoundForLevel(correct: true);

    await _applyLevelSettings();

    if (!mounted) return;

    if (levelChanged == true) {
      await _gamesSuperKey.currentState?.showLevelChangeFeedback(
        newLevel: _gamesSuperKey.currentState!.levelManager.level,
        increased: _gamesSuperKey.currentState!.levelManager.levelIncreased,
      );
    }
    _generateNextLetter();
  }

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Jogo da Escrita',
      progressValue: 1.0,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => _usedCharacters.length + 1,
      totalRounds: (_) => _characters.length,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      introImagePath: 'assets/images/games/writing_game.webp',
      introAudioPath: 'sounds/games/writing_game.ogg',
      onIntroFinished: () async {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() => hasChallengeStarted = true);
          _playInstruction();
        }
      },
      onRepeatInstruction: _playInstruction,
    );
  }

  Widget _buildTopText() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Text(
        hasChallengeStarted ? 'Escreve a letra $currentLetter' : 'Vamos praticar a escrita!',
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
    if (!hasChallengeStarted || currentLetter.isEmpty) {
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
