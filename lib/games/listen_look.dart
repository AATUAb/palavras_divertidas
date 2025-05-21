// Estrutura do jogo "Ouvir e identficar imagens"
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';
import '../widgets/game_component.dart';
import '../widgets/level_manager.dart';

/*class ListenLookGame extends StatefulWidget {
  final UserModel user;
  const ListenLookGame({Key? key, required this.user}) : super(key: key);*/

class ListenLookGame extends StatefulWidget {
  final UserModel user;
  const ListenLookGame({Key? key, required this.user});
 
  @override
  State<ListenLookGame> createState() => _ListenLookGameState();
}

class _ListenLookGameState extends State<ListenLookGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  bool hasChallengeStarted = false;


  Duration levelTime = const Duration(seconds: 15);
  List<WordModel> _allWords = [];
  List<WordModel> _levelWords = [];
  List<String> _usedWords = [];
  late WordModel targetWord;
  late GameItem referenceItem; // → audio preview
  List<GameItem> gamesItems = [];

  bool isRoundActive = true;
  Timer? _roundTimer, _progressTimer;
  late DateTime _startTime;
  double progressValue = 1.0;
  bool _isDisposed = false;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

 //////////////// Em Falta /////////////////
  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
  }
////////////// Fiim do em falta /////////////

  // Fecha o player de áudio e cancela os temporizadores
  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    super.dispose();
  }

  // Carrega as palavras do banco de dados Hive
  Future<void> _loadWords() async {
    final box = await Hive.openBox<WordModel>('words');
    _allWords = box.values.toList();
  }

  // Aplica as definições de nível com base no nível atual do jogador
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

    final filtered =
        _allWords.where((w) {
          return w.difficulty.toLowerCase().trim() == label &&
              !_usedWords.contains(w.text) &&
              w.audioPath.isNotEmpty &&
              w.imagePath.isNotEmpty;
        }).toList();

    final retryIds = _gamesSuperKey.currentState?.retryQueueContents() ?? [];
    final retryWords =
        _allWords.where((w) => retryIds.contains(w.text)).toList();

    _levelWords = {...filtered, ...retryWords}.toList();
  }

  // Cancela os temporizadores ativos
  void _cancelTimers() {
    _roundTimer?.cancel();
    _progressTimer?.cancel();
  }

  /// 1) Chamado pelo super-widget (ícone de repetir áudio)
  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  }

  /// 2) Gera um novo desafio
  Future<void> _generateNewChallenge() async {
    _gamesSuperKey.currentState?.playChallengeHighlight();   // Novo para dar efeito especial a iniciar um desafio

    if (!mounted || _isDisposed) return;

    // 2.1) escolhe retry ou novo
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

    // 2.2) prepara o GameItem de áudio (só o path “sounds/words/xxx” sem “assets/” e sem “.ogg”)
    final raw = targetWord.audioPath; // ex: “assets/sounds/words/pena.ogg”
    final sanitized = raw
        .replaceFirst(RegExp(r'^assets/'), '') // -> “sounds/words/pena.ogg”
        .replaceFirst(RegExp(r'\.ogg$'), ''); // -> “sounds/words/pena”
    referenceItem = GameItem(
      id: targetWord.text,
      type: GameItemType.text,
      content: sanitized,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
      isCorrect: true,
    );

    // 2.3) distractors visuais
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

    // 2.4) dispara o áudio logo após o próximo build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || _isDisposed) return;
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    // 2.5) reinicia timers e progress bar
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
    final font = getFontFamily(
      isFirstCycle ? FontStrategy.slabo : FontStrategy.none,
    );
    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child: Text(
        hasChallengeStarted
            ? 'Escolhe a imagem correta para a palavra que ouviste'
            : 'Vamos ouvir com atenção, para encontrar a imagem correta',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: font,
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBoard(BuildContext ctx, LevelManager lm, UserModel user) {
    if (!hasChallengeStarted || gamesItems.isEmpty) return const SizedBox();
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
      gameName: 'Ouvir e procurar imagem',
      progressValue: progressValue,
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/listen_look.webp',
      introAudioPath: 'sounds/games/listen_look.ogg',
      onIntroFinished: () async {
        await _loadWords();
        await _applyLevelSettings();
        setState(() => hasChallengeStarted = true);
        _generateNewChallenge();
      },
    );
  }
}
