// Estrutura do jogo "Contar Sílabas"
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/user_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';
import '../widgets/game_component.dart';

class CountSyllablesGame extends StatefulWidget {
  final UserModel user;
  const CountSyllablesGame({super.key, required this.user});

  @override
  State<CountSyllablesGame> createState() => _CountSyllablesGame();
}

class _CountSyllablesGame extends State<CountSyllablesGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  final _random = Random();
  late final AudioPlayer _wordPlayer;
  bool hasChallengeStarted = false;
  late int currentLevel;
  late Duration levelTime;
  late int currentTry;
  late int foundCorrect;

  List<WordModel> _words = [];
  List<String> _usedWords = [];
  List<GameItem> gamesItems = [];
  late WordModel targetWord;

  bool isRoundActive = true;
  bool isRoundFinished = false;
  Timer? roundTimer, progressTimer;
  double progress = 0.0;
  double progressValue = 1.0;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  String? _fontForGameItem({bool isTargetWord = false}) {
    if (isFirstCycle) {
      return isTargetWord ? 'Cursive' : null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _wordPlayer = AudioPlayer();
  }

  Future<void> _loadWords() async {
    final box = await Hive.openBox<WordModel>('words');
    _words = box.values.toList();
  }

  @override
  void dispose() {
    _wordPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;

    switch (lvl) {
      case 1:
        levelTime = const Duration(seconds: 15);
        break;
      case 2:
        levelTime = const Duration(seconds: 20);
        break;
      case 3:
        levelTime = const Duration(seconds: 25);
        break;
    }

    final levelDifficulty = switch (lvl) {
      1 => 'baixa',
      2 => 'media',
      3 => 'elevada',
      _ => 'baixa',
    };

    final filteredWords = _words
        .where((w) => w.difficulty.trim().toLowerCase() == levelDifficulty)
        .toList();

    setState(() {
      currentLevel = lvl;
      _words = filteredWords;
    });
  }

  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  Future<void> _reproduzirInstrucao() async {
    final file = 'sounds/words_characters/${targetWord.audioFileName ?? targetWord.text}.ogg';
    try {
      await _wordPlayer.stop();
      await _wordPlayer.release();
      await _wordPlayer.play(AssetSource(file));
    } catch (e) {
      debugPrint('❌ Erro ao reproduzir som: $file — $e');
    }
  }

  void _restartGame() async {
    _gamesSuperKey.currentState?.levelManager.level = 1;
    setState(() {
      _usedWords.clear();
      hasChallengeStarted = true;
      progressValue = 1.0;
    });
    await _applyLevelSettings();
    _generateNewChallenge();
  }

  Future<void> _generateNewChallenge() async {
    _gamesSuperKey.currentState?.registerCompletedRound();
    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();

    final availableWords = _words.where((w) =>
        !_usedWords.contains(w.text) &&
        w.audioPath.trim().isNotEmpty &&
        w.imagePath.trim().isNotEmpty).toList();

    if (availableWords.isEmpty && retry == null) {
      _gamesSuperKey.currentState?.showEndOfGameDialog(
        onRestart: _restartGame,
      );
      return;
    }

    targetWord = retry != null
        ? availableWords.firstWhere(
            (w) => w.text == retry,
            orElse: () => availableWords[_random.nextInt(availableWords.length)],
          )
        : availableWords[_random.nextInt(availableWords.length)];

    if (!_usedWords.contains(targetWord.text)) {
      _usedWords.add(targetWord.text);
    }

    _gamesSuperKey.currentState?.removeFromRetryQueue(targetWord.text);
    _cancelTimers();

    final correct = targetWord.syllableCount;
    final options = correct == 1
        ? ['1', '2', '3']
        : [correct - 1, correct, correct + 1]
            .map((e) => e.toString())
            .toList()
          ..shuffle();

    final generatedItems = List<GameItem>.generate(options.length, (i) {
      return GameItem(
        id: '$i',
        type: GameItemType.number,
        content: options[i],
        dx: 0,
        dy: 0,
        fontFamily: _fontForGameItem(),
        backgroundColor: Colors.teal,
        isCorrect: options[i] == correct.toString(),
      );
    });

    setState(() {
      isRoundActive = true;
      gamesItems = generatedItems;
      currentTry = 0;
      foundCorrect = 0;
      progressValue = 1.0;
    });

    final referenceItem = GameItem(
      id: 'preview',
      type: GameItemType.text,
      content: targetWord.audioFileName ?? targetWord.text,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        progressValue -= 0.01;
        if (progressValue <= 0) t.cancel();
      });
    });

    roundTimer = Timer(levelTime, () {
      if (!mounted) return;
      setState(() => isRoundActive = false);
      _gamesSuperKey.currentState?.registerFailedRound(targetWord.text);
      _gamesSuperKey.currentState?.showTimeout(
        applySettings: _applyLevelSettings,
        generateNewChallenge: _generateNewChallenge,
      );
    });
  }

  void _handleTap(GameItem item) async {
    if (!isRoundActive || item.isTapped) return;
    final s = _gamesSuperKey.currentState;
    if (s == null) return;

    setState(() {
      currentTry++;
      item.isTapped = true;
    });

    await s.checkAnswer(
      selectedItem: item,
      target: targetWord.syllableCount.toString(),
      correctCount: 1,
      currentTry: currentTry,
      foundCorrect: item.isCorrect ? 1 : 0,
      applySettings: _applyLevelSettings,
      generateNewChallenge: _generateNewChallenge,
      updateFoundCorrect: (_) {},
      cancelTimers: _cancelTimers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Contar sílabas',
      progressValue: progressValue,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _reproduzirInstrucao,
      introImagePath: 'assets/images/games/count_syllables.webp',
      introAudioPath: 'sounds/games/count_syllables.ogg',
      onIntroFinished: () async {
        await _loadWords();
        await _applyLevelSettings();
        if (mounted) {
          setState(() => hasChallengeStarted = true);
          _generateNewChallenge();
        }
      },
    );
  }

  Widget _buildTopText() {
    final font = getFontFamily(isFirstCycle ? FontStrategy.slabo : FontStrategy.none);
    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child: hasChallengeStarted
          ? _buildChallengeText()
          : Text(
              'Vamos contar as sílabas das palavras.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: font,
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
    );
  }

  Widget _buildChallengeText() {
    final font = getFontFamily(isFirstCycle ? FontStrategy.slabo : FontStrategy.none);
    return Text(
      'Quantas sílabas tem a palavra ${targetWord.text}?',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: font,
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

 Widget _buildBoard(BuildContext context, _, __) {
  if (!hasChallengeStarted || _words.isEmpty) {
    return const SizedBox();
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Column(
      children: [
        SizedBox(height: 85.h),

        // Palavra + imagem
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WordHighlightBox(word: targetWord.text),
            SizedBox(width: 50.w),     //espaçamento entre a palavra e a imagem
            ImageCardBox(imagePath: targetWord.imagePath),
          ],
        ),

        const Spacer(),

        // Botões em linha, um por um com feedback
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: gamesItems.map((item) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: GestureDetector(
                onTap: () => _handleTap(item),
                child: item.isTapped
                    ? (item.isCorrect
                        ? _gamesSuperKey.currentState!.correctIcon
                        : _gamesSuperKey.currentState!.wrongIcon)
                    : FlexibleAnswerButton(
                        label: item.content,
                        onTap: () => _handleTap(item),
                      ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 30.h),
      ],
    ),
  );
}
  Future<void> _playWordSound(String word) async {
    final path = 'sounds/words_characters/\${word.toLowerCase()}.ogg';
    await _wordPlayer.stop();
    await _wordPlayer.release();
    await _wordPlayer.play(AssetSource(path));
  }
}
