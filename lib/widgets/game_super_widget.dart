import 'package:flutter/material.dart';
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
  });

  @override
  State<GamesSuperWidget> createState() => GamesSuperWidgetState();
}

class GamesSuperWidgetState extends State<GamesSuperWidget> {
  late LevelManager levelManager;
  late ConquestManager conquestManager;

  Widget get correctIcon => GameAnimations.correctAnswerIcon();
  Widget get wrongIcon => GameAnimations.wrongAnswerIcon();

  @override
  void initState() {
    super.initState();
    levelManager = LevelManager(user: widget.user, gameName: widget.gameName);
    conquestManager = ConquestManager();
  }

  @override
  Widget build(BuildContext context) {
    return GameDesign(
      user: widget.user,
      progressValue: widget.progressValue,
      topTextWidget: DefaultTextStyle(
        style: getInstructionFont(isFirstCycle: widget.isFirstCycle),
        textAlign: TextAlign.center,
        child: widget.topTextContent(),
      ),
      child: widget.builder(context, levelManager, widget.user),
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
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
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

    // Espera adicional para garantir fecho completo do modal
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

    // Delay para evitar sobreposição com próximo diálogo
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
    }
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
