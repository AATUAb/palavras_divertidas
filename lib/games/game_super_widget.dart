import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/level_manager.dart';
import '../widgets/game_item.dart';
import '../widgets/conquest_manager.dart';
import '../widgets/game_animations.dart';
import '../widgets/game_design.dart';

/// Widget base para todos os jogos
class GamesSuperWidget extends StatefulWidget {
  final UserModel user;
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
  ) builder;

  const GamesSuperWidget({
    super.key,
    required this.user,
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
  bool isConquestAnimationShown = false;
  Widget get correctIcon => GameAnimations.correctAnswerIcon();
  Widget get wrongIcon => GameAnimations.wrongAnswerIcon();

// Método para reproduzir o som da resposta
  Future<void> playAnswerFeedback({required bool isCorrect}) async {
    print("🔊 Reproduzir som: ${isCorrect ? 'correto' : 'errado'}");
    await GameAnimations.playAnswerFeedback(isCorrect: isCorrect);
  }

  @override
  void initState() {
    super.initState();
    levelManager = LevelManager(user: widget.user, gameName: 'generic');
    conquestManager = ConquestManager();
  }

 @override
Widget build(BuildContext context) {
  // recebe o design a aplicar nos jogos
  return GameDesign(
    user: widget.user,
    progressValue: widget.progressValue,     // envia o progresso para a barra
    topTextWidget: DefaultTextStyle(         // mostra a instrução no topo    
      style: getInstructionFont(isFirstCycle: widget.isFirstCycle),
      textAlign: TextAlign.center,
      child: widget.topTextContent(),
    ),
    child: widget.builder(
      context,
      levelManager,                       // envia o levelManager para o jogo
      widget.user,                       // envia o utilizador para o jogo
      
    ),
  );
}

// Função para exibir feedback de sucesso
  Future<void> showSuccessFeedback() async {
    print("🎉 Mostrar animação de sucesso");
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GameAnimations.coffetiesTimed(
          onFinished: () {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context, rootNavigator: true).maybePop();
            }
          },
        ),
      ),
    );
  }

  Future<void> showLevelChangeFeedback({
    required int newLevel,
    required bool increased,
    VoidCallback? onFinished,
  }) async {
    final message = GameAnimations.levelMessage(
      level: newLevel,
      increased: increased,
    );
    print("📈 Feedback de nível: \$message");

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameAnimations.starByLevel(
              level: newLevel,
              onFinished: () {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context, rootNavigator: true).maybePop();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Função para exibir feedback de conquista
  Future<void> showConquestFeedback({required VoidCallback onFinished}) async {
    await GameAnimations.showConquestDialog(
      context,
      onFinished: onFinished,
    );
    print("🏅 Mostrar conquista");
  }

  void showTimeout({
  required Future<void> Function() applySettings,
  required VoidCallback generateNewChallenge,
}) {
  if (!mounted) return;
  print("⏰ Tempo esgotado!");
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Tempo esgotado! ⏰',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 2),
    ),
  );

  levelManager.registerRoundForLevel(
    context: context,
    correct: false,
    applySettings: () async {
      await applySettings();
    },
    onFinished: () {
      if (mounted) generateNewChallenge();
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
  print("🔢 Atualizar foundCorrect: $newFoundCorrect");

  if (newFoundCorrect >= correctCount) {
    print("🛑 Temporizadores cancelados após sucesso");
    cancelTimers();

    await showSuccessFeedback();
    if (!mounted) return;

    final bool firstTry = currentTry == correctCount;

    await levelManager.registerRoundForLevel(
      context: context,
      correct: firstTry,
      applySettings: () async {
        await applySettings();
      },
      onFinished: () async {
        if (!mounted) return;

        final bool shouldConquer = await conquestManager.registerRoundForConquest(
          context: context,
          firstTry: firstTry,
          userKey: widget.user.key!,
          applySettings: applySettings,
        );

        // Mostrar animação de conquista apenas se a conquista for nova e se a animação ainda não foi exibida
        if (shouldConquer) {
          await showConquestFeedback(
            onFinished: () {
              if (mounted) {
                generateNewChallenge();
              }
            },
          );
        } else {
          if (mounted) generateNewChallenge();
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
  print("✅ checkAnswer chamado para \${selectedItem.content}");

  final isCorrect = selectedItem.content.toLowerCase() == target.toLowerCase();

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
    await levelManager.registerRoundForLevel(
      context: context,
      correct: false,
      applySettings: () async {
        await applySettings();
      },
      onFinished: () {},
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
  
    // Mostrar animação de destaque, no ecrã de menus de jogos
  void showConquestNotification() {
  // Verifica se há novas conquistas
  if (conquestManager.hasNewConquest) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Nova conquista desbloqueada!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
  }
}