import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'dart:async';
import '../models/user_model.dart';
import '../models/character_model.dart';
import '../models/word_model.dart';
import 'level_manager.dart';
import 'game_item.dart';
import 'conquest_manager.dart';
import 'game_animations.dart';
import 'game_design.dart';
import 'sound_manager.dart';

class GamesSuperWidget extends StatefulWidget {
  final UserModel user;
  final String gameName;
  final int Function(LevelManager) level;
  final int Function(LevelManager) currentRound;
  final int Function(LevelManager) totalRounds;
  final Widget Function() topTextContent;
  final bool isFirstCycle;
  final Widget Function(BuildContext context, int currentRound, int totalRounds)
  builder;
  final VoidCallback? onRepeatInstruction;
  final String? introImagePath;
  final String? introAudioPath;
  final VoidCallback? onIntroFinished;
  final VoidCallback? onShowTutorial;

  const GamesSuperWidget({
    super.key,
    required this.user,
    required this.gameName,
    required this.level,
    required this.currentRound,
    required this.totalRounds,
    required this.topTextContent,
    required this.isFirstCycle,
    required this.builder,
    this.onRepeatInstruction,
    this.introImagePath,
    this.introAudioPath,
    this.onIntroFinished,
    this.onShowTutorial,
  });

  @override
  State<GamesSuperWidget> createState() => GamesSuperWidgetState();
}

class GamesSuperWidgetState extends State<GamesSuperWidget>
    with TickerProviderStateMixin {
  late LevelManager levelManager;
  int _visibleLevel = 1;
  late ConquestManager conquestManager;
  final Queue<MapEntry<String, int>> _retryQueue = Queue();
  int _roundCounter = 0;
  final int retryDelay = 4;
  bool introCompleted = false;
  late AnimationController _fadeController;
  late Animation<double> _rotationAnimation;
  bool get isFirstCycle => widget.isFirstCycle;
  bool _isDisposed = false;
  OverlayEntry? _introOverlay;
  bool get canShowTutorial => mounted;

  GameItem? _currentChallengeItem;

  Widget get correctIcon => GameAnimations.correctAnswerIcon();
  Widget get wrongIcon => GameAnimations.wrongAnswerIcon();

  late AnimationController _highlightController;
  late Animation<double> _highlightOpacity;
  late Animation<double> _highlightScale;

  double _progressValue = 1.0;
  DateTime? _startTime;
  Timer? _progressTimer;

  //get isTutorialVisible => null;
  bool isTutorialVisible = false;

  @override
  void initState() {
    super.initState();

    levelManager = LevelManager(user: widget.user, gameName: widget.gameName);
    conquestManager = ConquestManager();

    // animação para a imagem incial de jogo
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // animação para cada desafio novo
    _highlightOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeOut),
    );

    _highlightScale = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeOut),
    );

    // Carrega o nível de cada jogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLevelAndIntro();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    SoundManager.stopAll();
    _highlightController.dispose();
    _fadeController.dispose();
    _introOverlay?.remove();
    _introOverlay = null;
    super.dispose();
  }

  // Inicializa o nível e a introdução do jogo
  Future<void> _initializeLevelAndIntro() async {
    await levelManager.loadLevel();
    setState(() {
      _visibleLevel = levelManager.level;
    });
    if (widget.introImagePath != null && widget.introAudioPath != null) {
      _introOverlay = await GameAnimations.showIntro(
        context: context,
        imagePath: widget.introImagePath!,
        audioFile: widget.introAudioPath!,
        introTextStyle: getInstructionFont(isFirstCycle: widget.isFirstCycle),
        onFinished: () {
          if (!mounted) return;
          setState(() {
            introCompleted = true;
            _introOverlay = null;
          });
          widget.onIntroFinished?.call();
        },
      );
    }
  }

  void showTutorialDialog({VoidCallback? onTutorialClosed, String? retryId}) {
    isTutorialVisible = true;
    if (retryId != null) {
      registerFailedRound(retryId);
    }
    cancelProgressTimer();
    GameAnimations.showTutorialVideo(
      context: context,
      fileName: widget.gameName,
      onFinished: () {
        onTutorialClosed?.call();
      },
    );
  }

  Future<void> playNewChallengeSound(GameItem item) async {
    if (_isDisposed) return;
    _currentChallengeItem = item;
    await SoundManager.playGameItem(item);
  }

  T safeSelectItem<T>({required List<T> availableItems}) {
    if (availableItems.isEmpty) {
      throw Exception('No items available');
    }

    final rand = Random();
    final item = availableItems[rand.nextInt(availableItems.length)];

    if (item is String) {
      registerCompletedRound(item);
    } else if (item is WordModel) {
      registerCompletedRound(item.text);
    } else if (item is CharacterModel) {
      registerCompletedRound(item.character);
    }

    return item;
  }

  T safeRetry<T>({
    required List<T> list,
    required String retryId,
    required bool Function(T) matcher,
    required T Function() fallback,
  }) {
    try {
      final item = list.firstWhere(matcher);
      removeFromRetryQueue(retryId);

      if (item is String) {
        registerCompletedRound(item);
      } else if (item is WordModel) {
        registerCompletedRound(item.text);
      } else if (item is CharacterModel) {
        registerCompletedRound(item.character);
      }

      return item;
    } catch (_) {
      removeFromRetryQueue(retryId);
      final fallbackItem = fallback();

      if (fallbackItem is String) {
        registerCompletedRound(fallbackItem);
      } else if (fallbackItem is WordModel) {
        registerCompletedRound(fallbackItem.text);
      } else if (fallbackItem is CharacterModel) {
        registerCompletedRound(fallbackItem.character);
      }

      return fallbackItem;
    }
  }

  // Reincia o jogo e o seu progresso
  Future<void> restartGame() async {
    await levelManager.resetLevelToOne();
    setState(() {
      _visibleLevel = 1;
      _retryQueue.clear();
      _roundCounter = 0;
    });
  }

  // Verifica se ainda existem itens disponíveis, para determinar se o jogo terminou
  bool isEndOfGame<T>({required List<T> availableItems}) {
    final retry = peekNextRetryTarget();
    return availableItems.isEmpty && retry == null;
  }

  Future<void> playChallengeHighlight() async {
    try {
      await _highlightController.forward(from: 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GameDesign(
      user: widget.user,
      progressValue: _progressValue,
      level: _visibleLevel,
      topTextWidget: DefaultTextStyle(
        style: getInstructionFont(isFirstCycle: widget.isFirstCycle),
        textAlign: TextAlign.center,
        child: widget.topTextContent(),
      ),
      onShowTutorial: widget.onShowTutorial,
      child: Stack(
        children: [
          if (introCompleted)
            FadeTransition(
              opacity: _highlightOpacity,
              child: ScaleTransition(
                scale: _highlightScale,
                child: widget.builder(
                  context,
                  levelManager.level,
                  _roundCounter,
                ),
              ),
            ),

          if (introCompleted)
            Positioned(
              top: 100,
              left: 10,
              child: IconButton(
                icon: Icon(
                  Icons.play_circle_fill,
                  color: Colors.red,
                  size: 70.sp,
                ),
                onPressed:
                    widget.onRepeatInstruction ??
                    () async {
                      if (_currentChallengeItem != null) {
                        await SoundManager.playGameItem(_currentChallengeItem!);
                      }
                    },
              ),
            ),
        ],
      ),
    );
  }

  // Mostra o feedback de resposta correta ou errada
  Future<void> playAnswerFeedback({required bool isCorrect}) async {
    await GameAnimations.playAnswerFeedback(isCorrect: isCorrect);
  }

  // Mostra o feedback de sucesso
  Future<void> showSuccessFeedback() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: SizedBox(
              width: 0.9.sw,
              height: 0.6.sh,
              child: GameAnimations.showSuccessAnimation(
                onFinished: () {
                  if (mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context, rootNavigator: true).maybePop();
                  }
                },
              ),
            ),
          ),
    );
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Mostra o feedback de mudança de nível
  Future<void> showLevelChangeFeedback({
    required int newLevel,
    required bool increased,
  }) async {
    await GameAnimations.showLevelChangeDialog(
      context,
      level: newLevel,
      increased: increased,
      onFinished: () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context, rootNavigator: true).maybePop();
        }
      },
    );
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Mostra o feedback de conquista
  Future<void> showConquestFeedback({required VoidCallback onFinished}) async {
    await GameAnimations.showConquestDialog(
      context,
      onFinished: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        onFinished();
      },
    );
  }

  // Mostra o aviso de tempo esgotado e gere a animação de nível se ocorrer em simultâneo
  void showTimeout({
    required Future<void> Function() applySettings,
    required VoidCallback generateNewChallenge,
  }) async {
    final levelChanged = await levelManager.registerRoundForLevel(
      correct: false,
    );
    await applySettings();

    if (!mounted) return;

    if (levelChanged) {
      await showLevelChangeFeedback(
        newLevel: levelManager.level,
        increased: levelManager.levelIncreased,
      );
      if (mounted) {
        setState(() => _visibleLevel = levelManager.level);
        generateNewChallenge();
      }
    } else {
      await GameAnimations.showTimeoutSnackbar(context);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) generateNewChallenge();
    }
  }

  // Processa a resposta correta e gere o feedback
  Future<void> processCorrectAnswer({
    required GameItem selectedItem,
    required int currentTry,
    required int correctCount,
    required int foundCorrect,
    required VoidCallback cancelTimers,
    required Future<void> Function() applySettings,
    required VoidCallback generateNewChallenge,
    required ConquestManager conquestManager,
    required void Function(int) updateFoundCorrect,
    required String target,
  }) async {
    final newFoundCorrect = foundCorrect + 1;
    updateFoundCorrect(newFoundCorrect);

    if (newFoundCorrect >= correctCount) {
      cancelTimers();

      await showSuccessFeedback();
      if (!mounted) return;

      final bool firstTry = currentTry == correctCount;

      final levelChanged = await levelManager.registerRoundForLevel(
        correct: firstTry,
      );
      await applySettings();

      final shouldConquer = await conquestManager.registerRoundForConquest(
        context: context,
        firstTry: firstTry,
        user: widget.user,
        applySettings: applySettings,
      );

      Future<void> continueAfterFeedback() async {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 300));
        if (shouldConquer) {
          await showConquestFeedback(
            onFinished: () {
              if (mounted) generateNewChallenge();
            },
          );
        } else {
          if (mounted) generateNewChallenge();
        }
      }

      if (levelChanged) {
        await showLevelChangeFeedback(
          newLevel: levelManager.level,
          increased: levelManager.levelIncreased,
        );
        await continueAfterFeedback();
      } else {
        await continueAfterFeedback();
      }
    }
  }

  // Jogos com várias respostas corretas. Verifica se a resposta está correta e atualiza o estado do item
  Future<void> checkAnswerMultiple({
    required GameItem selectedItem,
    required String target,
    required String retryId,
    required int correctCount,
    required int currentTry,
    required int foundCorrect,
    required Future<void> Function() applySettings,
    required VoidCallback generateNewChallenge,
    required void Function(int) updateFoundCorrect,
    required VoidCallback cancelTimers,
    required VoidCallback markRoundFinished,
  }) async {
    final isCorrect =
        selectedItem.content.toLowerCase() == target.toLowerCase();

    //Marca o estado visual do item
    setState(() {
      selectedItem.isTapped = true;
      selectedItem.isCorrect = isCorrect;
    });

    //Feedback sonoro/visual imediato
    await playAnswerFeedback(isCorrect: isCorrect);

    //Se errou, registra no retry e sai
    if (!isCorrect) {
      registerFailedRound(retryId);
      return;
    }

    //Se acertou, incrementa o contador parcial
    final newFoundCorrect = foundCorrect + 1;
    updateFoundCorrect(newFoundCorrect);

    // Se ainda não completou todas as respostas, espera próxima tentativa
    if (newFoundCorrect < correctCount) {
      return;
    }

    // Ronda completadoacom sucesso
    cancelTimers();
    markRoundFinished();

    // retira o item da fila de retry se acertou as vezes necessárias
    removeFromRetryQueue(retryId);

    await showSuccessFeedback();
    if (!mounted) return;

    // Determina se foi "first try" (nenhum erro antes)
    final bool firstTry = currentTry == correctCount;

    // Regista nível
    final levelChanged = await levelManager.registerRoundForLevel(
      correct: firstTry,
    );
    await applySettings();

    // Regista conquista (inclui persistência via ConquestManager)
    final shouldConquer = await conquestManager.registerRoundForConquest(
      context: context,
      firstTry: firstTry,
      user: widget.user,
      applySettings: applySettings,
    );

    // Callback para gerar próximo desafio após todos os feedbacks
    Future<void> continueAfterFeedback() async {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _visibleLevel = levelManager.level;
      });
      if (shouldConquer) {
        await showConquestFeedback(onFinished: generateNewChallenge);
      } else {
        generateNewChallenge();
      }
    }

    // Exibe a mudança de nível, caso hava
    if (levelChanged) {
      await showLevelChangeFeedback(
        newLevel: levelManager.level,
        increased: levelManager.levelIncreased,
      );
    }

    // Continua para o próximo desafio
    await continueAfterFeedback();
  }

  // Jogos com uma única resposta correta. Verifica se a resposta está correta e atualiza o estado do item
  Future<void> checkAnswerSingle({
    required GameItem selectedItem,
    required String target,
    required String retryId,
    required int currentTry,
    required Future<void> Function() applySettings,
    required VoidCallback generateNewChallenge,
    required VoidCallback cancelTimers,
    required Future<void> Function() showExtraFeedback,
  }) async {
    // 1) Determina se acertou
    final isCorrect =
        selectedItem.content.toLowerCase() == target.toLowerCase();

    // 2) Atualiza estado visual
    setState(() {
      selectedItem.isTapped = true;
      selectedItem.isCorrect = isCorrect;
    });

    // 4) Cancela timer e toca feedback
    cancelTimers();
    await playAnswerFeedback(isCorrect: isCorrect);

    // 5) Verifica se acertou à primeira tentativa
    final bool firstTry = isCorrect;

    // 6) Regista nível
    final levelChanged = await levelManager.registerRoundForLevel(
      correct: isCorrect,
    );
    await applySettings();

    // 7) Regista conquista (conta persistência ou firstTry)
    final shouldConquer = await conquestManager.registerRoundForConquest(
      context: context,
      firstTry: firstTry,
      user: widget.user,
      applySettings: applySettings,
    );

    // 8) Em caso de erro, regista retry, possivelmente mostra conquista e sai
    if (!isCorrect) {
      registerFailedRound(retryId);

      // Se disparou conquista com esse erro, mostra feedback e termina
      if (shouldConquer) {
        await showConquestFeedback(onFinished: generateNewChallenge);
        return;
      }

      if (levelChanged) {
        await showLevelChangeFeedback(
          newLevel: levelManager.level,
          increased: levelManager.levelIncreased,
        );
        setState(() => _visibleLevel = levelManager.level);
      }

      generateNewChallenge();
      return;
    }

    // 9) Em caso de sucesso
    await showExtraFeedback();
    await showSuccessFeedback();

    // 10) Geração de próximo desafio após feedbacks de nível/conquista
    Future<void> continueAfterFeedback() async {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _visibleLevel = levelManager.level);

      if (shouldConquer) {
        await showConquestFeedback(onFinished: generateNewChallenge);
      } else {
        generateNewChallenge();
      }
    }

    if (levelChanged) {
      await showLevelChangeFeedback(
        newLevel: levelManager.level,
        increased: levelManager.levelIncreased,
      );
    }
    await continueAfterFeedback();
  }

  // Se a resposta estiver errada, regista o item na fila de retry, sem repetição e gere a sua exibição
  void registerFailedRound(String retryId) {
    final alreadyExists = _retryQueue.any(
      (entry) => entry.key.toLowerCase() == retryId.toLowerCase(),
    );
    if (!alreadyExists) {
      _retryQueue.add(MapEntry(retryId, _roundCounter));
    }
    debugPrint('📋 Retry atual: ${_retryQueue.map((e) => e.key).toList()}');
  }

  // Se a fila de retry não estiver vazia, verifica se o item mais antigo pode ser usado
  String? peekNextRetryTarget() {
    if (_retryQueue.isNotEmpty) {
      final oldest = _retryQueue.first;
      final roundsSinceFail = _roundCounter - oldest.value;
      if (roundsSinceFail > retryDelay) {
        return oldest.key;
      }
    }
    return null;
  }

  // Se o item da fila retry for respondido de forma correta, remove-o
  void removeFromRetryQueue(String target) {
    _retryQueue.removeWhere(
      (entry) => entry.key.toLowerCase() == target.toLowerCase(),
    );
    debugPrint('📋 Retry atual: ${_retryQueue.map((e) => e.key).toList()}');
  }

  List<String> retryQueueContents() {
    return _retryQueue.map((e) => e.key).toList();
  }

  bool canUseRetry() {
    return _roundCounter >= retryDelay;
  }

  // Regista a ronda concluída
  void registerCompletedRound(String retryId) {
    _roundCounter++;
  }

  // Regista o início da ronda actual
  void registerRoundStartTime() {
    _startTime = DateTime.now();
  }

  // Inicia o progress timer da ronda actual.
  void startProgressTimer({
    required Duration levelTime,
    required VoidCallback onTimeout,
  }) {
    registerRoundStartTime();

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return t.cancel();
      final elapsed = DateTime.now().difference(_startTime!);
      final frac = elapsed.inMilliseconds / levelTime.inMilliseconds;

      setState(() {
        if (frac >= 1.0) {
          _progressValue = 0.0;
          t.cancel();
          onTimeout();
        } else {
          _progressValue = 1.0 - frac;
        }
      });
    });
  }

  double getCurrentResponseTimeInSeconds() {
    if (_startTime == null) return 0.0;
    final elapsed = DateTime.now().difference(_startTime!);
    return elapsed.inMilliseconds / 1000.0;
  }

  void registerResponseTimeForCurrentRound({
    required UserModel user,
    required String gameName,
  }) {
    if (_startTime == null) return;
    final elapsed = DateTime.now().difference(_startTime!);
    final responseTimeInSeconds = elapsed.inMilliseconds / 1000.0;

    levelManager.registerResponseTime(
      user: user,
      gameName: gameName,
      responseTimeInSeconds: responseTimeInSeconds,
    );
  }

  void cancelProgressTimer() {
    _progressTimer?.cancel();
  }

  // Mostra o diálogo de fim de jogo
  void showEndOfGameDialog({required VoidCallback onRestart}) {
    GameAnimations.showEndOfGameDialog(
      context: context,
      onRestart: onRestart,
      user: widget.user,
    );
  }
}
