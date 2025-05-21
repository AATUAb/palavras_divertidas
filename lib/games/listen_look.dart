import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';
import '../widgets/game_component.dart';

class ListenLookGame extends StatefulWidget {
  final UserModel user;
  const ListenLookGame({Key? key, required this.user});

  @override
  State<ListenLookGame> createState() => _ListenLookGameState();
}

class _ListenLookGameState extends State<ListenLookGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  bool hasChallengeStarted = false;
  late Duration levelTime;
  late int currentTry;
  late int foundCorrect;

  List<WordModel> _allWords = [];
  List<WordModel> _levelWords = [];
  List<String> _usedWords = [];
  late WordModel targetWord;
  bool showWord = false;

  bool isRoundActive = true;
  List<GameItem> gamesItems = [];
  Timer? roundTimer, progressTimer;
  late DateTime _startTime;
  double progressValue = 1.0;
  bool _isDisposed = false;
  late GameItem referenceItem;
  Map<String, String> pathByText = {};

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
  }

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

    // Garante que palavras da fila de retry continuam acessíveis
    final filtered =
        _allWords.where((w) {
          final diff = (w.difficulty).trim().toLowerCase();
          return diff == levelDifficulty &&
              !_usedWords.contains(
                w.text,
              ) && // ← evita repetir palavras já usadas
              (w.audioPath).trim().isNotEmpty &&
              (w.imagePath).trim().isNotEmpty;
        }).toList();

    // Garante que palavras da fila de retry continuam acessíveis
    final retryIds = _gamesSuperKey.currentState?.retryQueueContents() ?? [];
    final retryWords =
        _allWords.where((w) => retryIds.contains(w.text)).toList();

    // Junta os dois, evitando duplicações
    _levelWords = {...filtered, ...retryWords}.toList();
  }

  // Cancela os temporizadores ativos
  void _cancelTimers() {
    roundTimer?.cancel();
    progressTimer?.cancel();
  }

  /// 1) Chamado pelo super-widget (ícone de repetir áudio)
  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  }

  /// 2) Gera cada novo desafio: agora com 3 imagens
  Future<void> _generateNewChallenge() async {
    // sinal visual de início
    _gamesSuperKey.currentState?.playChallengeHighlight();

    if (!mounted || _isDisposed) return;
    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();

    // 2.1) Escolhe o WordModel atual (retry ou novo aleatório)
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
            : _gamesSuperKey.currentState!.safeSelectItem<WordModel>(
              availableItems: _levelWords,
            );

    if (!_usedWords.contains(targetWord.text)) {
      _usedWords.add(targetWord.text);
    }

    // 2.2) Prepara o GameItem que vai tocar o áudio
    referenceItem = GameItem(
      id: targetWord.text,
      type: GameItemType.text,
      content: targetWord.audioPath,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
      isCorrect: true,
    );

    // 2.3) Escolhe 2 distractors e monta a lista de 3 imagens
    final distractors =
        (_levelWords.where((w) => w.text != targetWord.text).toList()
              ..shuffle())
            .take(2)
            .toList();

    pathByText = <String, String>{
      for (final w in [targetWord, ...distractors]) w.text: w.imagePath,
    };
    // monta 3 GameItem de tipo image
    gamesItems =
        [targetWord, ...distractors]
            .map(
              (w) => GameItem(
                id: w.text,
                type: GameItemType.image,
                content: w.text, // caminho da imagem
                dx: 0,
                dy: 0,
                backgroundColor: Colors.transparent,
                isCorrect: w.text == targetWord.text,
              ),
            )
            .toList()
          ..shuffle();

    // 2.4) Toca o áudio logo após o build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || _isDisposed) return;
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    // 2.5) Reinicia timers e progress bar (igual antes)
    _cancelTimers();
    setState(() {
      isRoundActive = true;
      progressValue = 1.0;
      currentTry = 0;
      foundCorrect = 0;
    });

    _startTime = DateTime.now();
    progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _isDisposed) return t.cancel();
      final elapsed = DateTime.now().difference(_startTime);
      setState(() {
        progressValue =
            1.0 -
            (elapsed.inMilliseconds / levelTime.inMilliseconds).clamp(0.0, 1.0);
      });
    });

    roundTimer = Timer(levelTime, () {
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

    setState(() {
      currentTry++;
      item.isTapped = true;
    });

    await s.checkAnswerSingle(
      selectedItem: item,
      target: targetWord.text,
      retryId: targetWord.text,
      currentTry: currentTry,
      applySettings: _applyLevelSettings,
      generateNewChallenge: _generateNewChallenge,
      cancelTimers: _cancelTimers,
      showExtraFeedback: () async {
        setState(() {
          isRoundActive = false;
          showWord = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() => showWord = false);
      },
    );

    setState(() => currentTry++);
  }

  // Constrói o widget principal do jogo
  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Ouvir e Procurar Imagem',
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

  Widget _buildBoard(BuildContext ctx, _, __) {
    if (!hasChallengeStarted || gamesItems.isEmpty) return const SizedBox();
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 50.w,
          runSpacing: 50.h,
          children:
              gamesItems.map((item) {
                return GestureDetector(
                  onTap: () => _handleTap(item),
                  child: SizedBox(
                    // aqui use as mesmas dimensões do ImageCardBox
                    width: 160.w,
                    height: 100.h,
                    child:
                        item.isTapped
                            // se já foi tocado, mostra só o ícone, sem o quadrado verde
                            ? Center(
                              child:
                                  item.isCorrect
                                      ? _gamesSuperKey.currentState!.correctIcon
                                      : _gamesSuperKey.currentState!.wrongIcon,
                            )
                            // senão, mostra o card normal com a imagem
                            : ImageCardBox(
                              imagePath: pathByText[item.content]!,
                            ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
