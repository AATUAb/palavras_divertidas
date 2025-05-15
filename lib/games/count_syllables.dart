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
  late Duration levelTime;
  late int currentTry;
  late int foundCorrect;

  List<WordModel> _allWords = [];
  List<WordModel> _levelWords = [];
  List<String> _usedWords = [];
  late WordModel targetWord;
  bool showSyllables = false;

  bool isRoundActive = true;
  List<GameItem> gamesItems = [];
  Timer? roundTimer, progressTimer;
  late DateTime _startTime;
  double progressValue = 1.0;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  @override
  void initState() {
    super.initState();
    _wordPlayer = AudioPlayer();
  }

  Future<void> _loadWords() async {
    final box = await Hive.openBox<WordModel>('words');
    _allWords = box.values.toList();
  }

  @override
  void dispose() {
    _wordPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }

  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    late String levelDifficulty;
    switch (lvl) {
      case 1:
        levelTime = const Duration(seconds: 15);
        levelDifficulty = 'baixa';
        break;
      case 2:
        levelTime = const Duration(seconds: 20);
        levelDifficulty = 'media';
        break;
      default:
        levelTime = const Duration(seconds: 25);
        levelDifficulty = 'dificil';
    }

    _levelWords =
        _allWords.where((w) {
          final diff = (w.difficulty ?? '').trim().toLowerCase();
          return diff == levelDifficulty &&
              (w.audioPath ?? '').trim().isNotEmpty &&
              (w.imagePath ?? '').trim().isNotEmpty;
        }).toList();

    if (_levelWords.isEmpty) {
      debugPrint(
        '⚠️ Sem palavras disponíveis para o nível "$levelDifficulty".',
      );
    }
  }

  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  late GameItem referenceItem;
  Future<void> _reproduzirInstrucao() async {
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
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
    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();
    if (retry != null) debugPrint('🔁 Retry queue: $retry');

    final availableWords =
        _levelWords
            .where(
              (w) =>
                  !_usedWords.contains(w.text) &&
                  w.audioPath.trim().isNotEmpty &&
                  w.imagePath.trim().isNotEmpty,
            )
            .toList();

    if (availableWords.isEmpty && retry == null) {
      _gamesSuperKey.currentState?.showEndOfGameDialog(onRestart: _restartGame);
      return;
    }

    final targetText =
        retry ?? availableWords[_random.nextInt(availableWords.length)].text;
    targetWord = availableWords.firstWhere(
      (w) => w.text == targetText,
      orElse: () => availableWords[_random.nextInt(availableWords.length)],
    );
    _gamesSuperKey.currentState?.removeFromRetryQueue(targetWord.text);

    _cancelTimers();
    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      currentTry = 0;
      foundCorrect = 0;
      progressValue = 1.0;
    });

    final correct = targetWord.syllableCount;
    final options =
        correct == 1
              ? ['1', '2', '3']
              : [
                correct - 1,
                correct,
                correct + 1,
              ].map((e) => e.toString()).toList()
          ..shuffle();

    gamesItems = List.generate(options.length, (i) {
      return GameItem(
        id: '$i',
        type: GameItemType.number,
        content: options[i],
        dx: 0,
        dy: 0,
        backgroundColor: Colors.transparent,
        isCorrect: options[i] == correct.toString(),
      );
    });

    referenceItem = GameItem(
      id: 'preview',
      type: GameItemType.text,
      content: targetWord.audioFileName ?? targetWord.text,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    _startTime = DateTime.now();
    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return t.cancel();
      final elapsed = DateTime.now().difference(_startTime);
      final frac = elapsed.inMilliseconds / levelTime.inMilliseconds;
      setState(() {
        progressValue = 1.0 - frac;
        if (progressValue <= 0) t.cancel();
      });
    });

    roundTimer = Timer(levelTime, () {
      if (!mounted) return;
      setState(() => isRoundActive = false);
      _cancelTimers();
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

    await s.checkAnswerSingle(
      selectedItem: item,
      target: targetWord.syllableCount.toString(),
      retryId: targetWord.text,
      currentTry: currentTry,
      applySettings: _applyLevelSettings,
      generateNewChallenge: _generateNewChallenge,
      cancelTimers: _cancelTimers,
      showExtraFeedback: () async {
        setState(() {
          isRoundActive = false;
          showSyllables = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() => showSyllables = false);
      },
    );

    setState(() => currentTry++);
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
    final font = getFontFamily(
      isFirstCycle ? FontStrategy.slabo : FontStrategy.none,
    );
    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child:
          hasChallengeStarted
              ? Text(
                'Quantas sílabas tem a palavra ${targetWord.text}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: font,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
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

 /* Widget _buildBoard(BuildContext context, _, __) {
    if (!hasChallengeStarted || _levelWords.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 85.h),

          // Palavra + imagem
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WordHighlightBox(word: targetWord.text, user: widget.user),
                  SizedBox(width: 50.w),

               // Tiago, para usar emulador
                /*  // ** Inline: carrega a imagem com errorBuilder **
                  if (targetWord.imagePath.trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        targetWord.imagePath,
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                SizedBox(width: 120.w, height: 120.w),
                      ),
                    )
                  else
                    // ignora por agora (não crasha)
                    SizedBox(width: 120.w, height: 120.w),*/
                ],
              ),
              if (showSyllables)
                Positioned(
                  top: 0,
                  child: WordHighlightBox(
                    word: targetWord.syllables.join(' - '),
                    user: widget.user,
                  ),
                ),
            ],
          ),

          const Spacer(),*/

          Widget _buildBoard(BuildContext context, _, __) {
  if (!hasChallengeStarted || _levelWords.isEmpty) {
    return const SizedBox();
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Column(
      children: [
        SizedBox(height: 85.h),

        // Palavra + imagem
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WordHighlightBox(word: targetWord.text, user: widget.user),
                SizedBox(width: 50.w),

                // ** Aqui entra o cartão **
                if (targetWord.imagePath.trim().isNotEmpty)
                  ImageCardBox(
                    imagePath: targetWord.imagePath,
                  )
              ],
            ),
            if (showSyllables)
              Positioned(
                top: 0,
                child: WordHighlightBox(
                  word: targetWord.syllables.join(' - '),
                  user: widget.user,
                ),
              ),
          ],
        ),

        const Spacer(),

          // Botões de resposta
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                gamesItems.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: GestureDetector(
                      onTap: () => _handleTap(item),
                      child:
                          item.isTapped
                              ? (item.isCorrect
                                  ? _gamesSuperKey.currentState!.correctIcon
                                  : _gamesSuperKey.currentState!.wrongIcon)
                              : FlexibleAnswerButton(
                                label: item.content,
                                onTap: () => _handleTap(item),
                                user: widget.user,
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
}