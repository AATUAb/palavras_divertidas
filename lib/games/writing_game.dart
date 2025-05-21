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

  // tire o 'const' daqui:
  WritingGame({super.key, required this.user}) {
    debugPrint('📦 WritingGame widget constructed with user=${user.name}');
  }

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
  String targetCharacter = '';
  bool get isFirstCycle {
    debugPrint('⚙️ isFirstCycle getter called → ${widget.user.schoolLevel == '1º Ciclo'}');
    return widget.user.schoolLevel == '1º Ciclo';
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 initState called');
    _audioPlayer = AudioPlayer();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    debugPrint('🔄 _loadCharacters start');
    final box = await Hive.openBox<CharacterModel>('characters');
    _characters = box.values.toList();
    debugPrint('📥 Loaded ${_characters.length} characters from Hive');
    await _applyLevelSettings();
    _generateNextLetter();
  }

  @override
  void dispose() {
    debugPrint('🧹 dispose called');
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _applyLevelSettings() async {
    debugPrint('⚙️ _applyLevelSettings start');
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    debugPrint('   current level from LevelManager: $lvl');
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
    debugPrint('   correctCount set to $correctCount');
    setState(() {});
  }

  Future<void> _playInstruction() async {
    debugPrint('🔊 _playInstruction start for letter="$currentLetter"');
    try {
      await _audioPlayer.stop();
      await _audioPlayer.release();
      final assetPath = 'sounds/characters/${currentLetter.toUpperCase()}.ogg';
      debugPrint('   🎵 Tocar asset: $assetPath');
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (err) {
      debugPrint('   ⚠️ Erro ao tocar áudio de $currentLetter: $err');
    }
  }

  void _generateNextLetter() {
    debugPrint('🔁 _generateNextLetter start (used so far: $_usedCharacters)');
    final allChars = _characters.map((e) => e.character.toUpperCase()).toList();
    final availableChars = allChars.where((c) => !_usedCharacters.contains(c)).toList();

    if (availableChars.isEmpty) {
      debugPrint('   🎉 Nenhum caracter disponível: fim do jogo');
      _gamesSuperKey.currentState
          ?.showEndOfGameDialog(onRestart: _restartGame);
      return;
    }

    final next = availableChars[_random.nextInt(availableChars.length)];
    _usedCharacters.add(next);
    debugPrint('   Próxima letra: $next');

    setState(() {
      currentLetter = next;
      targetCharacter = next;
    });

    _playInstruction();
  }

  void _restartGame() async {
    debugPrint('🔄 _restartGame called');
    _gamesSuperKey.currentState?.levelManager.level = 1;
    setState(() {
      _usedCharacters.clear();
      hasChallengeStarted = true;
      progressValue = 1.0;
    });
    debugPrint('   Estado reiniciado: usedCharacters cleared, hasChallengeStarted=true');
    await _applyLevelSettings();
    _generateNextLetter();
  }

  Future<void> _handleTracingFinished(String char) async {
    debugPrint('✅ _handleTracingFinished start for char="$char"');
    _gamesSuperKey.currentState?.registerCompletedRound(targetCharacter);
    final levelChanged = await _gamesSuperKey.currentState?.levelManager
        .registerRoundForLevel(correct: true);
    debugPrint('   levelChanged? $levelChanged');
    await _applyLevelSettings();

    if (!mounted) {
      debugPrint('   Widget unmounted antes de continuar');
      return;
    }

    if (levelChanged == true) {
      debugPrint('   Nível mudou, mostrando feedback');
      await _gamesSuperKey.currentState?.showLevelChangeFeedback(
        newLevel: _gamesSuperKey.currentState!.levelManager.level,
        increased: _gamesSuperKey.currentState!.levelManager.levelIncreased,
      );
    }
    _generateNextLetter();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🖼️ build() called: hasChallengeStarted=$hasChallengeStarted, currentLetter=$currentLetter');
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
          setState(() {
            hasChallengeStarted = true;
            debugPrint('✅ hasChallengeStarted agora = $hasChallengeStarted');
          });
          _playInstruction();
        }
      },
      onRepeatInstruction: _playInstruction,
    );
  }

  Widget _buildTopText() {
    debugPrint('📝 _buildTopText called (hasChallengeStarted=$hasChallengeStarted)');
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Text(
        hasChallengeStarted
            ? 'Escreve a letra $currentLetter'
            : 'Vamos praticar a escrita!',
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
    debugPrint('🔲 _buildBoard called (hasChallengeStarted=$hasChallengeStarted, currentLetter=$currentLetter)');
    if (!hasChallengeStarted || currentLetter.isEmpty) {
      debugPrint('   Retornando SizedBox.shrink()');
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
          onTracingUpdated: (_) async {
            debugPrint('✏️ onTracingUpdated callback');
          },
          onGameFinished: (_) async {
            debugPrint('🏁 onGameFinished callback');
            await _handleTracingFinished(currentLetter);
          },
          onCurrentTracingScreenFinished: (_) async {
            debugPrint('➡️ onCurrentTracingScreenFinished callback');
          },
        ),
      ),
    );
  }
}
