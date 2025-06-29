// Jogo "Contar sílabas":
// O jogador ouve uma palavra e visualiza a sua imagem e escolhe entre 3 opções numéricas.
// A dificuldade e tempo variam com o nível.
// A resposta correta mostra o texto da palavra com a divisão silábica correspondente.

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

// Classe principal do jogo, que recebe o utilizador como argumento
class CountSyllablesGame extends StatefulWidget {
  final UserModel user;
  const CountSyllablesGame({super.key, required this.user});

  @override
  State<CountSyllablesGame> createState() => _CountSyllablesGame();
}

// Classe que controla o estado do jogo
class _CountSyllablesGame extends State<CountSyllablesGame> {
  final _gamesSuperKey = GlobalKey<GamesSuperWidgetState>();
  bool hasChallengeStarted = false;
  late Duration levelTime;
  late int currentTry;
  late int foundCorrect;

  List<WordModel> _allWords = [];
  List<WordModel> _levelWords = [];
  List<String> usedWords = [];
  WordModel? targetWord;
  bool showSyllables = false;

  bool isRoundActive = true;
  List<GameItem> gamesItems = [];
  final _isDisposed = false;
  late GameItem referenceItem;
  late int numDistractors;

  bool get isFirstCycle => widget.user.schoolLevel == '1º Ciclo';

  // Inicializa o estado do jogo
  @override
  void initState() {
    super.initState();
  }

  // Carrega as palavras do banco de dados Hive
  Future<void> _loadWords() async {
    final box = await Hive.openBox<WordModel>('words');
    _allWords = box.values.toList();
  }

  // Aplica as definições de nível com base no nível atual do jogador
  Future<void> _applyLevelSettings() async {
    final lvl = _gamesSuperKey.currentState?.levelManager.level ?? 1;
    final schoolLevel = widget.user.schoolLevel;

    const Map<String, List<int>> game3TimesPerLevel = {
      'Pré-Escolar': [20, 20, 15],
      '1º Ciclo': [10, 10, 10],
    };

    // --- Tempo conforme tabela do Jogo 3 ---
    final times = game3TimesPerLevel[schoolLevel] ?? [15, 15, 15];
    levelTime = Duration(seconds: times[(lvl - 1).clamp(0, times.length - 1)]);

    numDistractors = lvl == 1 ? 1 : 2;
    late String levelDifficulty;
    switch (lvl) {
      case 1:
        levelDifficulty = 'baixa';
        break;
      case 2:
        levelDifficulty = 'media';
        break;
      default:
        levelDifficulty = 'dificil';
    }

    // Resto da lógica igual...
    final filtered =
        _allWords.where((w) {
          final diff = (w.difficulty).trim().toLowerCase();
          return diff == levelDifficulty &&
              !usedWords.contains(w.text) &&
              (w.audioPath).trim().isNotEmpty &&
              (w.imagePath).trim().isNotEmpty;
        }).toList();

    final retryIds = _gamesSuperKey.currentState?.retryQueueContents() ?? [];
    final retryWords =
        _allWords.where((w) => retryIds.contains(w.text)).toList();

    _levelWords = {...filtered, ...retryWords}.toList();
  }

  // Cancela os temporizadores ativos
  void _cancelTimers() {
    _gamesSuperKey.currentState?.cancelProgressTimer();
  }

  // Reproduz a instrução de áudio para o jogador
  Future<void> _playInstruction() async {
    if (!mounted || _isDisposed) return;
    await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
  }

  // Gera uma lista de distratores com base na palavra correta
  List<int> generateDistractors({
    required int correct,
    required int numDistractors,
  }) {
    // Caso especial: 1 sílaba → força [2], [2,3]
    if (correct == 1) {
      return numDistractors == 1 ? [2] : [2, 3];
    }

    final Set<int> optionSet = {};
    int offset = 1;

    while (optionSet.length < numDistractors) {
      if (correct - offset >= 1) optionSet.add(correct - offset);
      if (correct + offset <= 9) optionSet.add(correct + offset);
      offset++;
    }

    final distractors = optionSet.toList();
    distractors.length = min(numDistractors, distractors.length);
    return distractors;
  }

  // Gera um novo desafio
  Future<void> _generateNewChallenge() async {
    _gamesSuperKey.currentState?.playChallengeHighlight();

    // Verifica se há retry a usar
    if (!mounted || _isDisposed) return;
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
                            .where((w) => !usedWords.contains(w.text))
                            .toList(),
                  ),
            )
            : _gamesSuperKey.currentState!.safeSelectItem(
              availableItems: _levelWords,
            );

    final wordText = targetWord!.text;
    if (!usedWords.contains(wordText)) {
      usedWords.add(wordText);
    }

    final availableWords =
        _levelWords
            .where((w) => !usedWords.contains(w.text))
            .map((w) => w.text)
            .toList();

    // Verifica se o jogo terminou antes de gerar desafio
    final hasRetry = retry != null;

    if (availableWords.isEmpty && !hasRetry) {
      if (!mounted || _isDisposed) return;
      _gamesSuperKey.currentState?.showEndOfGameDialog(
        onRestart: () async {
          await _gamesSuperKey.currentState?.restartGame();
          await _applyLevelSettings();
          if (mounted) _generateNewChallenge();
        },
      );
      return;
    }

    _cancelTimers();
    setState(() {
      isRoundActive = true;
      gamesItems.clear();
      currentTry = 0;
      foundCorrect = 0;
    });

    // Gera distratores corretos com a função helper
    final correct = targetWord!.syllableCount;
    final distractors = generateDistractors(
      correct: correct,
      numDistractors: numDistractors,
    );

    // Junta tudo e aplica regra:
    final List<int> allOptions = [correct, ...distractors];

    if (numDistractors == 1) {
      allOptions.sort();
    } else {
      allOptions.shuffle();
    }

    final List<String> options = allOptions.map((v) => v.toString()).toList();

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
      content: targetWord!.audioFileName ?? targetWord!.text,
      dx: 0,
      dy: 0,
      backgroundColor: Colors.transparent,
    );

    // Reproduz o som da palavra alvo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted || _isDisposed) return;
      await _gamesSuperKey.currentState?.playNewChallengeSound(referenceItem);
    });

    // Sincroniza temporizadores com o tempo de nível
    _gamesSuperKey.currentState?.startProgressTimer(
      levelTime: levelTime,
      onTimeout: () {
        if (!mounted || _isDisposed) return;
        setState(() => isRoundActive = false);
        _gamesSuperKey.currentState?.registerFailedRound(targetWord!.text);
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
        gameName: 'Contar sílabas',
      );
      // 🔁 Se a palavra estava na retry list, remove-a
      final retryQueue =
          _gamesSuperKey.currentState?.retryQueueContents() ?? [];
      if (retryQueue.contains(targetWord!.text)) {
        _gamesSuperKey.currentState?.removeFromRetryQueue(targetWord!.text);
      }
    }

    // Delega validação ao super widget, mas com callback local
    await s.checkAnswerSingle(
      selectedItem: item,
      target: targetWord!.syllableCount.toString(),
      retryId: targetWord!.text,
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
    _gamesSuperKey.currentState?.registerCompletedRound(targetWord!.text);
    setState(() => currentTry++);
  }

  void _showTutorial() {
    final state = _gamesSuperKey.currentState;
    final safeRetryId = hasChallengeStarted ? targetWord!.text : null;
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
      gameName: 'Contar sílabas',
      level: (_) => _gamesSuperKey.currentState?.levelManager.level ?? 1,
      currentRound: (_) => 1,
      totalRounds: (_) => 3,
      isFirstCycle: isFirstCycle,
      topTextContent: _buildTopText,
      builder: _buildBoard,
      onRepeatInstruction: _playInstruction,
      introImagePath: 'assets/images/games/count_syllables.webp',
      introAudioPath: 'count_syllables.ogg',
      onIntroFinished: () async {
        await _loadWords();
        await _applyLevelSettings();
        if (mounted) {
          setState(() => hasChallengeStarted = true);
          if (!_gamesSuperKey.currentState!.isTutorialVisible) {
            _generateNewChallenge();
          }
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
            ? 'Quantas sílabas tem a palavra ${targetWord!.text}?'
            : 'Vamos contar as sílabas das palavras',
      ),
    );
  }

  // Constrói o tabuleiro do jogo, com base WordHighlightBox do game_component.dart
  Widget _buildBoard(BuildContext context, _, __) {
    if (!hasChallengeStarted || _levelWords.isEmpty || targetWord == null) {
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
                        WordHighlightBox(
                          word: targetWord!.text,
                          user: widget.user,
                        ),
                        SizedBox(width: 50.w),
                        if (targetWord!.imagePath.trim().isNotEmpty)
                          ImageCardBox(imagePath: targetWord!.imagePath),
                      ],
                    ),
                    if (showSyllables)
                      Positioned(
                        top: 0,
                        child: WordHighlightBox(
                          word: targetWord!.syllables.join(' - '),
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
}
