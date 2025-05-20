// lib/games/listen_look.dart

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
import '../widgets/level_manager.dart';

class ListenLookGame extends StatefulWidget {
  final UserModel user;
  const ListenLookGame({Key? key, required this.user}) : super(key: key);

  @override
  State<ListenLookGame> createState() => _ListenLookGameState();
}

class _ListenLookGameState extends State<ListenLookGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  late final AudioPlayer _player;
  bool hasChallengeStarted = false;

  Duration levelTime = const Duration(seconds: 15);
  List<WordModel> _allWords = [];
  List<WordModel> _levelWords = [];
  List<String> _usedWords = [];
  late WordModel targetWord;
  List<GameItem> gamesItems = [];
  bool isRoundActive = true;
  Timer? _roundTimer, _progressTimer;
  late DateTime _startTime;
  double progressValue = 1.0;
  bool _isDisposed = false;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  // Fecha o player e cancela os timers
  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  // Carrega as palavras do Hive
  Future<void> _loadWords() async {
    final box = await Hive.openBox<WordModel>('words');
    _allWords = box.values.toList();
  }

  // Aplica as configurações de nível
  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    switch (lvl) {
      case 1:
        levelTime = const Duration(seconds: 15);
        break;
      case 2:
        levelTime = const Duration(seconds: 20);
        break;
      default:
        levelTime = const Duration(seconds: 25);
    }
    final label = ['baixa', 'media', 'dificil'][lvl - 1];

    // filtra e adiciona retry queue
    final filtered =
        _allWords
            .where(
              (w) =>
                  w.difficulty.toLowerCase().trim() == label &&
                  !_usedWords.contains(w.text) &&
                  w.audioPath.isNotEmpty &&
                  w.imagePath.isNotEmpty,
            )
            .toList();

    final retryIds = _gamesSuperKey.currentState?.retryQueueContents() ?? [];
    final retryWords =
        _allWords.where((w) => retryIds.contains(w.text)).toList();

    _levelWords = {...filtered, ...retryWords}.toList();
  }

  void _cancelTimers() {
    _roundTimer?.cancel();
    _progressTimer?.cancel();
  }

  // Reproduz a instrução de áudio para o jogador
  late GameItem referenceItem;
  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  }

  // Gera um novo desafio
  Future<void> _generateNewChallenge() async {
    if (!mounted || _isDisposed) return;

    // pick retry ou novo
    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();
    targetWord =
        retry != null
            ? _gamesSuperKey.currentState!.safeRetry<WordModel>(
              list: _levelWords,
              retryId: retry,
              matcher: (w) => w.text == retry,
              fallback:
                  () => _gamesSuperKey.currentState!.safeSelectItem(
                    availableItems:
                        _levelWords
                            .where((w) => !_usedWords.contains(w.text))
                            .toList(),
                  ),
            )
            : _gamesSuperKey.currentState!.safeSelectItem(
              availableItems: _levelWords,
            );

    if (!_usedWords.contains(targetWord.text)) {
      _usedWords.add(targetWord.text);
    }

    // distrações
    final distractors =
        (_levelWords.where((w) => w.text != targetWord.text).toList()
              ..shuffle())
            .take(2)
            .toList();

    gamesItems =
        [targetWord, ...distractors]
            .map(
              (w) => GameItem(
                id: w.text,
                type: GameItemType.image,
                content: w.imagePath,
                dx: 0,
                dy: 0,
                backgroundColor: Colors.transparent,
                isCorrect: w.text == targetWord.text,
              ),
            )
            .toList()
          ..shuffle();

    // dispara o áudio logo depois do build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || _isDisposed) return;
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    _cancelTimers();
    isRoundActive = true;
    setState(() => progressValue = 1.0);
    _startTime = DateTime.now();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _isDisposed) return t.cancel();
      final elapsed = DateTime.now().difference(_startTime);
      setState(() {
        progressValue =
            1.0 -
            (elapsed.inMilliseconds / levelTime.inMilliseconds).clamp(0.0, 1.0);
      });
    });
    _roundTimer = Timer(levelTime, () {
      if (!mounted || _isDisposed) return;
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

    setState(() => item.isTapped = true);

    await s.checkAnswerSingle(
      selectedItem: item,
      target: targetWord.text,
      retryId: targetWord.text,
      currentTry: 1,
      applySettings: _applyLevelSettings,
      generateNewChallenge: _generateNewChallenge,
      cancelTimers: _cancelTimers,
      showExtraFeedback: () async {},
    );
  }

  Widget _buildTopText() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      child: Text(
        hasChallengeStarted
            ? 'Qual das imagens corresponde ao que ouviu?'
            : 'Vamos ouvir a palavra e identificar a imagem correta.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBoard(BuildContext ctx, LevelManager lm, UserModel user) {
    if (!hasChallengeStarted || gamesItems.isEmpty) {
      return const SizedBox();
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.w,
          runSpacing: 12.h,
          children:
              gamesItems.map((item) {
                return GestureDetector(
                  onTap: () => _handleTap(item),
                  child:
                      item.isTapped
                          ? (item.isCorrect
                              ? _gamesSuperKey.currentState!.correctIcon
                              : _gamesSuperKey.currentState!.wrongIcon)
                          : ImageCardBox(imagePath: item.content!),
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Ouvir e procurar',
      progressValue: progressValue,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _playInstruction,

      // **intro** idêntica aos outros jogos agora
      introImagePath: 'assets/images/games/listen_look.webp',
      introAudioPath: 'assets/sounds/games/listen_look.ogg',
      onIntroFinished: () async {
        await _loadWords();
        await _applyLevelSettings();
        setState(() => hasChallengeStarted = true);
        _generateNewChallenge();
      },
    );
  }
}
