 // Jogo "Ouvir e Procurar Imagem":
// O jogador ouve uma palavra e escolhe entre 3 imagens.
// A dificuldade e tempo variam com o nível.
// A resposta correta mostra o texto da palavra correspondente.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';
import '../widgets/game_component.dart';

// Classe principal do jogo, que recebe o utilizador como argumento
class ListenLookGame extends StatefulWidget {
  final UserModel user;
  const ListenLookGame({super.key, required this.user});

  @override
  State<ListenLookGame> createState() => _ListenLookGameState();
}

// Classe que controla o estado do jogo
class _ListenLookGameState extends State<ListenLookGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  bool hasChallengeStarted = false;
  late Duration levelTime;
  late int currentTry;
  late int foundCorrect;

  List<WordModel> _allWords = [];
  List<WordModel> _levelWords = [];
  final List<String> _usedWords = [];
  late WordModel targetWord;
  bool showWord = false;

  bool isRoundActive = true;
  List<GameItem> gamesItems = [];
  bool _isDisposed = false;
  late GameItem referenceItem;
  Map<String, String> pathByText = {};
  late int numDistractors;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  int _roundCounter = 0;

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
    numDistractors = lvl == 1 ? 1 : 2;
    late String levelDifficulty;
    switch (lvl) {
      case 1:
        levelTime = const Duration(seconds: 120);
        levelDifficulty = 'baixa';
        break;
      case 2:
        levelTime = const Duration(seconds: 120);
        levelDifficulty = 'media';
        break;
      default:
        levelTime = const Duration(seconds: 120);
        levelDifficulty = 'dificil';
    }

    // Garante que palavras da fila de retry continuam acessíveis
    final filtered = _allWords.where((w) {
          final diff = (w.difficulty).trim().toLowerCase();
          return diff == levelDifficulty &&
              ! _usedWords.contains(w.text) && // ← evita repetir palavras já usadas
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
    _gamesSuperKey.currentState?.cancelProgressTimer();
  }

  // Chamado pelo super-widget (ícone de repetir áudio)
  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  }

  // Gera um novo desafio com 3 imagens, baseando-se no áudio do item correto
  Future<void> _generateNewChallenge() async {
    _gamesSuperKey.currentState?.playChallengeHighlight();

  // Verifica se há retry a usar
  if (!mounted || _isDisposed) return;

  final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();
  final available = _levelWords.where((w) => !_usedWords.contains(w.text)).toList();
  final hasRetry = retry != null;

  if (available.isEmpty && !hasRetry) {
    _gamesSuperKey.currentState?.showEndOfGameDialog(
      onRestart: () async {
        await _gamesSuperKey.currentState?.restartGame();
        _usedWords.clear();
        await _applyLevelSettings();
        if (mounted) _generateNewChallenge();
      },
    );
    return;
  }

  // Escolhe o WordModel atual (retry ou novo aleatório)
  targetWord = retry != null
      ? _gamesSuperKey.currentState!.safeRetry<WordModel>(
          list: _levelWords,
          retryId: retry,
          matcher: (w) => w.text == retry,
          fallback: () => _gamesSuperKey.currentState!.safeSelectItem(
            availableItems: available,
          ),
        )
      : _gamesSuperKey.currentState!.safeSelectItem<WordModel>(
          availableItems: available,
        );


      if (!_usedWords.contains(targetWord.text)) {
        _usedWords.add(targetWord.text);
      }

    // Prepara o GameItem que vai tocar o áudio
    referenceItem = GameItem(
      id: targetWord.text,
      type: GameItemType.text,
      content: targetWord.audioPath,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
      isCorrect: true,
    );

    // Escolhe 2 distractors e monta a lista de 3 imagens, do mesmo tópico
    final correctTopic = targetWord.topic.trim().toLowerCase();

    final sameTopicDistractors = _allWords.where((w) =>
      w.text != targetWord.text &&
      w.topic.trim().toLowerCase() == correctTopic &&
      w.imagePath.trim().isNotEmpty &&
      w.audioPath.trim().isNotEmpty
    ).toList();

    // Distratores do mesmo nível e tópico
    List<WordModel> distractors;
    if (sameTopicDistractors.length >= numDistractors) {
      distractors = (sameTopicDistractors..shuffle()).take(numDistractors).toList();
    } else {
      final fallbackDistractors = _allWords.where((w) =>
        w.text != targetWord.text &&
        w.imagePath.trim().isNotEmpty &&
        w.audioPath.trim().isNotEmpty
      ).toList();
      distractors = (sameTopicDistractors + (fallbackDistractors..shuffle()))
          .where((w) => w.text != targetWord.text)
          .take(numDistractors)
          .toList();
    }

    // Cria 3 GameItem de tipo imagem. 1 correto e 2 distratores
    gamesItems = [targetWord, ...distractors]
      .map((w) => GameItem(
        id: w.text,
        type: GameItemType.image,
        content: w.imagePath,       
        dx: 0, dy: 0,
        backgroundColor: Colors.transparent,
        isCorrect: w.text == targetWord.text,
      ))
      .toList()
    ..shuffle();

    // Toca o áudio logo após o build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || _isDisposed) return;
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    // Reinicia timers e progress bar 
    _cancelTimers();
    setState(() {
      isRoundActive = true;
      currentTry = 0;
      foundCorrect = 0;
    });

    // Sincroniza temporizadores com o tempo de nív
   _gamesSuperKey.currentState?.startProgressTimer(
      levelTime: levelTime,
      onTimeout: () {
        if (!mounted || _isDisposed) return;
        setState(() => isRoundActive = false);
        _gamesSuperKey.currentState?.registerFailedRound(targetWord.text);
        _gamesSuperKey.currentState?.showTimeout(
          applySettings: _applyLevelSettings,
          generateNewChallenge: _generateNewChallenge,
        );
      },
    );
  }

  // Lida com o toque do jogador num item do jogo
  void _handleTap(GameItem item) async {
    if (!isRoundActive || item.isTapped) return;
    final s = _gamesSuperKey.currentState;
    if (s == null) return;

    setState(() {
      item.isTapped = true;
    });

    if (item.isCorrect) {
      _gamesSuperKey.currentState?.registerResponseTimeForCurrentRound(
        user: widget.user,
        gameName: 'Ouvir e Procurar Imagem',
      );
    }

    // Delega validação ao super widget, mas com callback local
    await s.checkAnswerSingle(
      selectedItem: item,
      target: targetWord.imagePath,
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
     _gamesSuperKey.currentState?.registerCompletedRound(targetWord.text);
    setState(() => currentTry++);   
  }

  void _showTutorial() {
    final state = _gamesSuperKey.currentState;

    final safeRetryId = hasChallengeStarted ? targetWord.text : null;

    state?.showTutorialDialog(
      retryId: safeRetryId,
      onTutorialClosed: () {
        _generateNewChallenge();
      },
    );
  }

  // Constrói o widget principal do jogo
  @override
  Widget build(BuildContext context) {
    return GamesSuperWidget(
      key: _gamesSuperKey,
      user: widget.user,
      gameName: 'Ouvir e Procurar Imagem',
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/listen_look.webp',
      introAudioPath: 'listen_look.ogg',
      onIntroFinished: () async {
        await _loadWords();
        await _applyLevelSettings();
        if (!mounted || _isDisposed) return;
      setState(() => hasChallengeStarted = true);
      if (!_gamesSuperKey.currentState!.isTutorialVisible) {
        _generateNewChallenge();
      }
    },
    onShowTutorial: () {
      _showTutorial();
    },
  );
}

  

  // Constrói o texto superior que é apresenado quando o jogo arranca
    Widget _buildTopText() {
      return Padding(
        padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
        child: Text(
          hasChallengeStarted
            ? 'Escolhe a imagem correta para a palavra que ouviste'
            : 'Vamos ouvir com atenção para encontrar a imagem correta',
        ),
      );
    }

    // Constrói o tabuleiro do jogo, com base WordHighlightBox do game_component.dart
  Widget _buildBoard(BuildContext context, _, __) {
    if (!hasChallengeStarted || gamesItems.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 30.h),

          // Área central com imagens e palavra sobreposta, quando correto
          Flexible(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Linha com 3 imagens
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: gamesItems.map((item) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _handleTap(item),
                          // Dentro do seu Row, no lugar daquele child antigo:
                          child: item.isTapped
                            ? SizedBox(
                                width: 160.w,
                                // Remova o height fixo se quiser crescer para caber o texto
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ícone de certo ou errado
                                    Center(
                                      child: item.isCorrect
                                          ? _gamesSuperKey.currentState!.correctIcon
                                          : _gamesSuperKey.currentState!.wrongIcon,
                                    ),
                                    // somente se for o correto E showWord estiver true
                                    if (item.isCorrect && showWord)
                                      Padding(
                                        padding: EdgeInsets.only(top: 8.h),
                                        child: WordHighlightBox(
                                          word: targetWord.text,
                                          user: widget.user,
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : ImageCardBox(imagePath: item.content),
                        ),
                      );
                    }).toList(),
                  ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      );
    }
  }