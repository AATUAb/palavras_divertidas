// Jogo "Identificar Palavras":
// O jogador ouve uma palavra e escolhe entre 3 palavras escritas.
// As palavras apresentadas são baseadas nas letras/sons conhecidas do utilizador,
// Quando o utilizador aprende uma letra/som novo, o nível do jogo é reiniciado para o 1.
// A dificuldade e tempo variam com o nível.
// A resposta correta mostra a imagem correspondente.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/word_model.dart';
import '../widgets/game_item.dart';
import '../widgets/game_super_widget.dart';
import '../widgets/game_component.dart';
import '../screens/letters_selection.dart';

// Classe principal do jogo, que recebe o utilizador como argumento
class IdentifyWordGame extends StatefulWidget {
  final UserModel user;
  const IdentifyWordGame({super.key, required this.user});

  @override
  State<IdentifyWordGame> createState() => _IdentifyWordGameState();
}

// Classe que controla o estado do jogo
class _IdentifyWordGameState extends State<IdentifyWordGame> {
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

  bool wordIsAllowed(WordModel word, List<String> knownLettersExpanded) {
    final normalized = word.newLetter.trim().toLowerCase();

    // Verifica se todas as letras compostas da 'newLetter' estão nas letras conhecidas
    if (normalized.contains(',')) {
      final parts = normalized.split(',').map((e) => e.trim()).toList();
      return parts.any((part) => knownLettersExpanded.contains(part));
    }
    return knownLettersExpanded.contains(normalized);
  }

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
  }

  // Fecha o player de áudio e cancela os temporizadores
  @override
  void dispose() {
    _isDisposed = true;
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

    // Expande letras conhecidas para aplicar regras de dificuldade
    final known = widget.user.knownLetters;
    final expandedLetters = expandKnownLetters(known);
    if (expandedLetters.isEmpty ||
        (expandedLetters.length <= 5 &&
            expandedLetters.every(
              (l) => ['a', 'e', 'i', 'o', 'u'].contains(l),
            ))) {
      _levelWords = []; // bloqueia início do jogo
      return;
    }

    // Verifica a última letra conhecida e a lista retry
    final ultimaLetra = expandedLetters.last.trim().toLowerCase();
    final retryIds = _gamesSuperKey.currentState?.retryQueueContents() ?? [];

    // Verifica se a palavra é válida para o nível atual
    bool isValidWord(WordModel w) {
      return w.difficulty.trim().toLowerCase() == levelDifficulty &&
          !_usedWords.contains(w.text) &&
          w.audioPath.trim().isNotEmpty &&
          w.imagePath.trim().isNotEmpty &&
          expandedLetters.contains(w.newLetter.trim().toLowerCase());
    }

    // Filtra as palavras com base na última letra conhecida e na lista de retry
    final priorityWords =
        _allWords
            .where(
              (w) =>
                  isValidWord(w) &&
                  w.newLetter.trim().toLowerCase() == ultimaLetra,
            )
            .toList();

    // Palavras que não são prioritárias, mas ainda válidas
    final fallbackWords =
        _allWords
            .where(
              (w) =>
                  isValidWord(w) &&
                  w.newLetter.trim().toLowerCase() != ultimaLetra,
            )
            .toList();

    // Palavras que estão na lista de retry, mas ainda válidas
    final retryWords =
        _allWords
            .where(
              (w) =>
                  retryIds.contains(w.text) &&
                  w.difficulty.trim().toLowerCase() == levelDifficulty &&
                  w.audioPath.trim().isNotEmpty &&
                  w.imagePath.trim().isNotEmpty &&
                  expandedLetters.contains(w.newLetter.trim().toLowerCase()),
            )
            .toList();

    // Junta todos, com prioridade para a última letra aprendida
    _levelWords = {...priorityWords, ...fallbackWords, ...retryWords}.toList();

    // DEBUG:
    debugPrint('Letras conhecidas: $expandedLetters');
    debugPrint(
      'Palavras prioritárias: ${priorityWords.map((w) => w.text).toList()}',
    );
    debugPrint(
      'Palavras filtradas: ${_levelWords.map((w) => w.text).toList()}',
    );
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

  // Gera um novo desafio novo, baseado nas palavras disponíveis e letras conhecidas
  Future<void> _generateNewChallenge() async {
    if (_gamesSuperKey.currentState?.isTutorialVisible ?? false) return;
    _gamesSuperKey.currentState?.playChallengeHighlight();

    // Verifica se há retry a usar e as plavras prioritárias
    if (!mounted || _isDisposed) return;

    final known = widget.user.knownLetters;
    final expandedLetters = expandKnownLetters(known);
    final ultimaLetra =
        expandedLetters.isNotEmpty
            ? expandedLetters.last.trim().toLowerCase()
            : '';

    final availableWords =
        _levelWords.where((w) => !_usedWords.contains(w.text)).toList();
    final hasRetry = _gamesSuperKey.currentState?.peekNextRetryTarget() != null;

    // Verifica se o jogo terminou antes de gerar desafio
    if (availableWords.isEmpty && !hasRetry) {
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
    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();

    // Escolhe o WordModel atual (retry ou novo aleatório, com prioridade para a última letra conhecida)
    final priorityWords =
        availableWords
            .where((w) => w.newLetter.trim().toLowerCase() == ultimaLetra)
            .toList();

    targetWord =
        retry != null
            ? _gamesSuperKey.currentState!.safeRetry<WordModel>(
              list: _levelWords,
              retryId: retry,
              matcher: (w) => w.text == retry,
              fallback:
                  () => _gamesSuperKey.currentState!.safeSelectItem(
                    availableItems:
                        priorityWords.isNotEmpty
                            ? priorityWords
                            : availableWords,
                  ),
            )
            : _gamesSuperKey.currentState!.safeSelectItem<WordModel>(
              availableItems:
                  priorityWords.isNotEmpty ? priorityWords : availableWords,
            );

    if (!_usedWords.contains(targetWord.text)) {
      _usedWords.add(targetWord.text);
    }
    debugPrint(
      '⚠️ Palavra escolhida: ${targetWord.text} (letra nova: ${targetWord.newLetter})',
    );

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
    final correctDifficulty = targetWord.difficulty.trim().toLowerCase();

    // Distratores do mesmo nível e tópico
    List<WordModel> sameLevelDistractors =
        _levelWords
            .where(
              (w) =>
                  w.text != targetWord.text &&
                  w.topic.trim().toLowerCase() == correctTopic &&
                  w.difficulty.trim().toLowerCase() == correctDifficulty &&
                  w.text.trim().isNotEmpty &&
                  w.audioPath.trim().isNotEmpty &&
                  w.imagePath.trim().isNotEmpty,
            )
            .toList();

    // Fallback: vai buscar distratores de nível abaixo, se necessário
    if (sameLevelDistractors.length < 2) {
      final fallbackDistractors =
          _allWords
              .where(
                (w) =>
                    w.text != targetWord.text &&
                    w.topic.trim().toLowerCase() == correctTopic &&
                    w.text.trim().isNotEmpty &&
                    w.audioPath.trim().isNotEmpty &&
                    w.imagePath.trim().isNotEmpty &&
                    w.difficulty.trim().toLowerCase() !=
                        'dificil', // nunca vai buscar distratores ao nivel acima
              )
              .toList();

      sameLevelDistractors += fallbackDistractors;
    }
    final distractors = (sameLevelDistractors..shuffle()).take(numDistractors).toList();

    // monta 3 GameItem de tipo texto, 1 correto e 2 distratores
    gamesItems =
        [targetWord, ...distractors]
            .map(
              (w) => GameItem(
                id: w.text,
                type: GameItemType.text,
                content: w.text,
                dx: 0,
                dy: 0,
                backgroundColor: Colors.transparent,
                isCorrect: w.text == targetWord.text,
              ),
            )
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

    // Sincroniza temporizadores com o tempo de nível
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

  // Lida com o toque em um item do jogo
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
        gameName: 'Ouvir e Procurar Palavra',
        );
      }

    // Delega validação ao super widget, mas com callback local
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

    setState(
      () => currentTry++,
    ); // Incrementa o número de tentativas feitas nesta ronda
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
      gameName: 'Ouvir e Procurar Palavra',
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/identify_words.webp',
      introAudioPath: 'identify_words.ogg',
      onIntroFinished: () async {
      await _loadWords();
      await _applyLevelSettings();
      if (mounted) {
        setState(() => hasChallengeStarted = true);
        _generateNewChallenge();
      }
    },
    onShowTutorial: () {
      _showTutorial();
  }
  );
}

  // Constrói o texto superior que é apresenado quando o jogo arranca
  Widget _buildTopText() {
    return Padding(
      padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
      child: Text(
        hasChallengeStarted
            ? 'Escolhe a palavra correta para o som que ouvistes'
              : 'Vamos ouvir com atenção para encontrar a palavra correta',
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
          SizedBox(height: 50.h),
          Flexible(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        gamesItems.map((item) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _handleTap(item),
                              child:
                                  item.isTapped
                                      ? SizedBox(
                                        width: 160.w,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                              child:
                                                  item.isCorrect
                                                      ? _gamesSuperKey
                                                          .currentState!
                                                          .correctIcon
                                                      : _gamesSuperKey
                                                          .currentState!
                                                          .wrongIcon,
                                            ),
                                            if (item.isCorrect && showWord)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 8.h,
                                                ),
                                                child: ImageCardBox(
                                                  imagePath:
                                                      targetWord.imagePath,
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                      : ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: 50.h,
                                          maxHeight: 80.h,
                                        ),
                                        child: Center(
                                          child: WordHighlightBox(
                                            word: item.content,
                                            user: widget.user,
                                          ),
                                        ),
                                      ),
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

