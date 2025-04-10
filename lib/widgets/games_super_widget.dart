import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'level_manager.dart';
import 'games_design.dart';
import 'games_animations.dart';

/// Widget base para todos os jogos
class GamesSuperWidget extends StatelessWidget {
  final UserModel user;
  final double progressValue;
  final int Function(LevelManager) level;
  final int Function(LevelManager) currentRound;
  final int Function(LevelManager) totalRounds;
  final Widget Function() topTextContent;
  final Widget Function(
    BuildContext context,
    LevelManager levelManager,
    UserModel user,
  )
  builder;

  const GamesSuperWidget({
    super.key,
    required this.user,
    required this.progressValue,
    required this.level,
    required this.currentRound,
    required this.totalRounds,
    required this.topTextContent,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final levelManager = LevelManager(user: user);
    return GamesDesign(
      user: user,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: GameAnimations.buildTopInfo(
              progressValue: progressValue,
              level: level(levelManager),
              currentRound: currentRound(levelManager),
              totalRounds: totalRounds(levelManager),
              topTextWidget: topTextContent(),
            ),
          ),
          builder(context, levelManager, user),
        ],
      ),
    );
  }
}

/// Mostra animação de sucesso, se aplicável
Widget buildSuccessAnimation(bool showSuccessAnimation) {
  return showSuccessAnimation
      ? IgnorePointer(
        ignoring: true,
        child: GameAnimations.coffetiesTimed(),
      )
      : const SizedBox.shrink();
}

/// Mostra animação de conquista, se aplicável
Widget buildConquestAnimation(bool showConquestAnimation) {
  return showConquestAnimation
      ? IgnorePointer(
        ignoring: true,
        child: GameAnimations.conquestTimed(),
      )
      : const SizedBox.shrink();
}
