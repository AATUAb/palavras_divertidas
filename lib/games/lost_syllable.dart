// Jogo "Sílaba Perdida":
// O jogador ouve uma palavra, visualiza a sua imagem e a sua forma escrita com uma sílaba ocultada.
// As opções de multipla são 3 sílabas.
// As palavras apresentadas são baseadas nas letras/sons conhecidas do utilizador,
// Quando o utilizador aprende uma letra/som novo, o nível do jogo é reiniciado para o 1.
// A dificuldade e tempo variam com o nível.
// A resposta correta mostra a palavra, na forma escrita correspondente.

import 'dart:async';
import 'dart:math';
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
class LostSyllableGame extends StatefulWidget {
  final UserModel user;
  const LostSyllableGame({super.key, required this.user});

  @override
  State<LostSyllableGame> createState() => _LostSyllableGameState();
}

// Classe que controla o estado do jogo
class _LostSyllableGameState extends State<LostSyllableGame> {
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
  String correctSyllable = '';
  int hiddenIndex = 0;

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
        levelTime = const Duration(seconds: 15);
        levelDifficulty = 'baixa';
        break;
      case 2:
        levelTime = const Duration(seconds: 15);
        levelDifficulty = 'media';
        break;
      default:
        levelTime = const Duration(seconds: 15);
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

    // Verifica se a palavra é válida para o nível atual e se tem mais de 1 sílaba
    bool isValidWord(WordModel w) {
      return w.difficulty.trim().toLowerCase() == levelDifficulty &&
          !_usedWords.contains(w.text) &&
          w.audioPath.trim().isNotEmpty &&
          w.imagePath.trim().isNotEmpty &&
          expandedLetters.contains(w.newLetter.trim().toLowerCase()) &&
          w.syllables.length > 1;
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

  List<String> generateDistractorsWithRules(
    String correctSyllable, {
    int count = 2,
  }) {
    final rules = {
      'a': ['e'],
      'e': ['i'],
      'i': ['e'],
      'o': ['u'],
      'u': ['o'],
      'ão': ['ao', 'ã'],
      'b': ['v', 'p'],
      'c': ['qu', 'ç'],
      'ç': ['c', 'ss'],
      'd': ['t'],
      'f': ['v'],
      'g': ['gu', 'j'],
      'gu': ['g'],
      'h': [''],
      'j': ['g'],
      'm': ['n'],
      'n': ['m'],
      'p': ['t', 'b', 'v'],
      'qu': ['q'],
      'r': ['rr'],
      'rr': ['r'],
      's': ['z', 'ss'],
      'ss': ['s', 'ç'],
      't': ['p'],
      'v': ['f', 'b'],
      'x': ['ch', 'nh'],
      'nh': ['lh', 'ch'],
      'lh': ['ch', 'nh'],
      'br': ['dr'],
      'gr': ['dr'],
      'pr': ['vr'],
      'tr': ['pr'],
    };

    Set<String> alternatives = {};

    // Apply substitution rules
    rules.forEach((key, substitutes) {
      if (key == 'h') {
        if (correctSyllable.startsWith('h')) {
          for (var sub in substitutes) {
            final result = correctSyllable.replaceFirst(RegExp('^h'), sub);
            if (result != correctSyllable) {
              alternatives.add(result);
            }
          }
        }
      } else if (correctSyllable.contains(key)) {
        for (var sub in substitutes) {
          alternatives.add(correctSyllable.replaceFirst(key, sub));
        }
      }
    });

    // Remove the correct syllable and return limited results
    alternatives.remove(correctSyllable);
    return alternatives.take(count).toList();
  }

  // Gera um novo desafio novo, baseado nas palavras disponíveis e letras conhecidas
  Future<void> _generateNewChallenge() async {
    _gamesSuperKey.currentState?.playChallengeHighlight();

    // Verifica se há retry a usar e as plavras prioritárias
    if (!mounted || _isDisposed) return;

    final known = widget.user.knownLetters;
    final expandedLetters = expandKnownLetters(known);
    final ultimaLetra =
        expandedLetters.isNotEmpty
            ? expandedLetters.last.trim().toLowerCase()
            : '';

    final retry = _gamesSuperKey.currentState?.peekNextRetryTarget();
    final hasRetry = retry != null;
    final availableWords =
        _levelWords.where((w) => !_usedWords.contains(w.text)).toList();

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

    // Escolhe índice da sílaba a ocultar
    if (targetWord.syllables.length > 1) {
      hiddenIndex = Random().nextInt(targetWord.syllables.length);
    } else {
      hiddenIndex = 0;
    }

    // Define a sílaba correta (a ser adivinhada)
    correctSyllable = targetWord.syllables[hiddenIndex];

    // Prepara o GameItem para tocar o áudio
    referenceItem = GameItem(
      id: targetWord.text,
      type: GameItemType.text,
      content: targetWord.audioPath,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
      isCorrect: true,
    );

    final fallbackDistractors = [
      'ba',
      'bo',
      'la',
      'tu',
      'po',
      'me',
      'si',
      'mo',
      'le',
      'ra',
      'na',
      'ca',
    ]..remove(correctSyllable);

    final distractors = generateDistractorsWithRules(
      correctSyllable,
      count: numDistractors,
    );

    if (distractors.length < numDistractors) {
      final needed = numDistractors - distractors.length;
      fallbackDistractors.shuffle();
      distractors.addAll(fallbackDistractors.take(needed));
    }

    // Junta a correta com as falsas e baralha
    final answerSyllables = [correctSyllable, ...distractors]..shuffle();

    // Cria os GameItems com base nas sílabas
    gamesItems =
        answerSyllables.map((syll) {
          return GameItem(
            id: syll,
            type: GameItemType.text,
            content: syll,
            dx: 0,
            dy: 0,
            backgroundColor: Colors.transparent,
            isCorrect: syll == correctSyllable,
          );
        }).toList();

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
        gameName: 'Sílaba perdida',
      );
    }

    // Delega validação ao super widget, mas com callback local
    await s.checkAnswerSingle(
      selectedItem: item,
      target: correctSyllable,
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
      gameName: 'Sílaba perdida',
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/lost_syllable.webp',
      introAudioPath: 'lost_syllable.ogg',
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
            ? 'Encontra a sílaba perdida para completar a palavra'
            : 'Vamos encontrar a sílaba perdida',
      ),
    );
  }

  // Constrói o tabuleiro do jogo, com base WordHighlightBox do game_component.dart
  Widget _buildBoard(BuildContext context, _, __) {
    if (!hasChallengeStarted || _levelWords.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 30.h),

          // Palavra e imagem com flexibilidade
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (targetWord.imagePath.trim().isNotEmpty)
                          ImageCardBox(imagePath: targetWord.imagePath),
                        SizedBox(width: 50.w),
                        _buildSyllableWordBox(
                          syllables: targetWord.syllables,
                          hiddenIndex: hiddenIndex,
                        ),
                      ],
                    ),
                    if (showWord)
                      Positioned(
                        top: 0,
                        child: WordHighlightBox(
                          word: targetWord.text,
                          user: widget.user,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Botões de resposta no fundo
          Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12.w,
                runSpacing: 10.h,
                children:
                    gamesItems.map((item) {
                      return GestureDetector(
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
                      );
                    }).toList(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ],
      ),
    );
  }

  // Constrói a caixa de palavra com sílabas, ocultando uma delas
  Widget _buildSyllableWordBox({
    required List<String> syllables,
    required int hiddenIndex,
  }) {
    final isFirstCycle = widget.user.schoolLevel == '1º Ciclo';
    final font = isFirstCycle ? 'Cursive' : null;
    final fontSize = isFirstCycle ? 30.sp : 22.sp;

    final wordDisplay =
        syllables
            .asMap()
            .entries
            .map((e) => e.key == hiddenIndex ? '__' : e.value)
            .join();

    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.r,
              offset: Offset(2, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          wordDisplay,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: font,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
