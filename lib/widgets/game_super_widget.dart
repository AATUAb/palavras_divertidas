import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/user_model.dart';
import 'level_manager.dart';
import 'game_item.dart';
import 'conquest_manager.dart';
import 'game_animations.dart';
import 'game_design.dart';

class GamesSuperWidget extends StatefulWidget {
  final UserModel user;
  final String gameName;
  final double progressValue;
  final int Function(LevelManager) level;
  final int Function(LevelManager) currentRound;
  final int Function(LevelManager) totalRounds;
  final Widget Function() topTextContent;
  final bool isFirstCycle;
  final Widget Function(
    BuildContext context,
    LevelManager levelManager,
    UserModel user,
  )
  builder;
  final VoidCallback? onRepeatInstruction;
  final String? introImagePath;
  final String? introAudioPath;
  final VoidCallback? onIntroFinished;

  const GamesSuperWidget({
    super.key,
    required this.user,
    required this.gameName,
    required this.progressValue,
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
  });

  @override
  State<GamesSuperWidget> createState() => GamesSuperWidgetState();
}

class GamesSuperWidgetState extends State<GamesSuperWidget>
    with SingleTickerProviderStateMixin {
  late LevelManager levelManager;
  late ConquestManager conquestManager;
  final Queue<MapEntry<String, int>> _retryQueue = Queue();
  int _roundCounter = 0;
  final int retryDelay = 3;
  bool introPlayed = false;
  bool introCompleted = false;
  late AnimationController _fadeController;
  late Animation<double> _rotationAnimation;

  Widget get correctIcon => GameAnimations.correctAnswerIcon();
  Widget get wrongIcon => GameAnimations.wrongAnswerIcon();

  @override
  void initState() {
    super.initState();
    levelManager = LevelManager(user: widget.user, gameName: widget.gameName);
    conquestManager = ConquestManager();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    if (widget.introImagePath != null && widget.introAudioPath != null) {
      final player = AudioPlayer();
      player.play(AssetSource(widget.introAudioPath!), volume: 1).then((_) {
        player.onPlayerComplete.first.then((_) {
          if (mounted) {
            _fadeController.forward().then((_) {
              if (mounted) {
                setState(() {
                  introPlayed = true;
                  introCompleted = true;
                });
                widget.onIntroFinished?.call();
              }
            });
          }
        });
      });
    } else {
      introPlayed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => introCompleted = true);
          widget.onIntroFinished?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameDesign(
      user: widget.user,
      progressValue: widget.progressValue,
      level: levelManager.level, // ← nível passado ao GameDesign
      topTextWidget: DefaultTextStyle(
        style: getInstructionFont(isFirstCycle: widget.isFirstCycle),
        textAlign: TextAlign.center,
        child: widget.topTextContent(),
      ),
      child: Stack(
        children: [
          if (!introCompleted && widget.introImagePath != null)
            FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.0).animate(_fadeController),
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80.h),
                    child: SizedBox(
                      width: 250.w,
                      height: 180.h,
                      child: Image.asset(
                        widget.introImagePath!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            widget.builder(context, levelManager, widget.user),
          if (widget.onRepeatInstruction != null && introCompleted)
            Positioned(
              top: 50,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.play_circle_fill, color: Colors.red, size: 30),
                onPressed: widget.onRepeatInstruction,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> playAnswerFeedback({required bool isCorrect}) async {
    await GameAnimations.playAnswerFeedback(isCorrect: isCorrect);
  }

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

  Future<void> showConquestFeedback({required VoidCallback onFinished}) async {
    await GameAnimations.showConquestDialog(
      context,
      onFinished: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        onFinished();
      },
    );
  }

  void showTimeout({
    required Future<void> Function() applySettings,
    required VoidCallback generateNewChallenge,
  }) async {
    if (!mounted) return;
    GameAnimations.showTimeoutSnackbar(context);
    await Future.delayed(const Duration(milliseconds: 400));

    generateNewChallenge();

    await levelManager.registerRoundForLevel(
      context: context,
      correct: false,
      applySettings: () async => await applySettings(),
      onFinished: () {},
      showLevelFeedback: (newLevel, increased) async {
        if (!mounted) return;
        await showLevelChangeFeedback(newLevel: newLevel, increased: increased);
      },
    );
  }

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

      await levelManager.registerRoundForLevel(
        context: context,
        correct: firstTry,
        applySettings: () async => await applySettings(),
        onFinished: () async {
          if (!mounted) return;

          final bool shouldConquer = await conquestManager
              .registerRoundForConquest(
                context: context,
                firstTry: firstTry,
                userKey: widget.user.key!,
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

          if (levelManager.levelChanged) {
            await showLevelChangeFeedback(
              newLevel: levelManager.level,
              increased: levelManager.levelIncreased,
            );
            await continueAfterFeedback();
          } else {
            await continueAfterFeedback();
          }
        },
        showLevelFeedback: (newLevel, increased) async {
          if (!mounted) return;
          await showLevelChangeFeedback(
            newLevel: newLevel,
            increased: increased,
          );
        },
      );
    }
  }

  Future<void> checkAnswer({
    required GameItem selectedItem,
    required String target,
    required int correctCount,
    required int currentTry,
    required int foundCorrect,
    required Future<void> Function() applySettings,
    required VoidCallback generateNewChallenge,
    required void Function(int) updateFoundCorrect,
    required VoidCallback cancelTimers,
  }) async {
    final isCorrect =
        selectedItem.content.toLowerCase() == target.toLowerCase();

    setState(() {
      selectedItem.isTapped = true;
      selectedItem.isCorrect = isCorrect;
    });

    await playAnswerFeedback(isCorrect: isCorrect);

    if (isCorrect) {
      await processCorrectAnswer(
        selectedItem: selectedItem,
        currentTry: currentTry,
        correctCount: correctCount,
        foundCorrect: foundCorrect,
        cancelTimers: cancelTimers,
        applySettings: applySettings,
        generateNewChallenge: generateNewChallenge,
        conquestManager: conquestManager,
        updateFoundCorrect: updateFoundCorrect,
        target: target,
      );
    } else {
      registerFailedRound(target);
    }
  }

  void registerFailedRound(String target) {
    final alreadyExists = _retryQueue.any(
      (entry) => entry.key.toLowerCase() == target.toLowerCase(),
    );
    if (!alreadyExists) {
      _retryQueue.add(MapEntry(target, _roundCounter));
      debugPrint('➕ Adicionado à fila de retry: $target');
    } else {
      debugPrint('🔁 Já na fila de retry: $target');
    }
    debugPrint('📋 Retry atual: ${_retryQueue.map((e) => e.key).toList()}');
  }

  String? peekNextRetryTarget() {
    if (_retryQueue.isNotEmpty) {
      final oldest = _retryQueue.first;
      final roundsSinceFail = _roundCounter - oldest.value;
      if (roundsSinceFail >= retryDelay) {
        return oldest.key;
      }
    }
    return null;
  }

  void removeFromRetryQueue(String target) {
    _retryQueue.removeWhere(
      (entry) => entry.key.toLowerCase() == target.toLowerCase(),
    );
    debugPrint('➖ Removido da fila de retry (já acertou): $target');
    debugPrint('📋 Retry atual: ${_retryQueue.map((e) => e.key).toList()}');
  }

  List<String> retryQueueContents() {
    return _retryQueue.map((e) => e.key).toList();
  }

  bool canUseRetry() {
    return _roundCounter >= retryDelay;
  }

  void registerCompletedRound() {
    _roundCounter++;
    debugPrint('🔄 Ronda concluída. Contador: $_roundCounter');
  }

  void showEndOfGameDialog({required VoidCallback onRestart}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Parabéns, chegaste ao fim do jogo!'),
            content: const Text('Queres jogar novamente?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRestart();
                },
                child: const Text('Sim'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).maybePop();
                },
                child: const Text('Não'),
              ),
            ],
          ),
    );
  }

  void showConquestNotification() {
    if (conquestManager.hasNewConquest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nova conquista desbloqueada!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
