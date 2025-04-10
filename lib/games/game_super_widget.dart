import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../widgets/level_manager.dart';
import '../widgets/game_design.dart';
import '../widgets/game_animations.dart';
import '../widgets/conquest_manager.dart'; 
import '../services/hive_service.dart';

/// Callback function type for triggering conquest feedback.
typedef ConquestFeedbackCallback = Future<void> Function({
  required bool firstTry,
  required VoidCallback applySettings,
  required VoidCallback onFinished,
});

/// Widget base para todos os jogos
class GamesSuperWidget extends StatefulWidget {
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
    ConquestFeedbackCallback triggerConquestFeedback,
  ) builder;

  const GamesSuperWidget({
    Key? key,
    required this.user,
    required this.progressValue,
    required this.level,
    required this.currentRound,
    required this.totalRounds,
    required this.topTextContent,
    required this.builder,
  }) : super(key: key);

  @override
  State<GamesSuperWidget> createState() => _GamesSuperWidgetState();
}

class _GamesSuperWidgetState extends State<GamesSuperWidget> {
  late final ConquestManager _conquestManager;

  @override
  void initState() {
    super.initState();
    _conquestManager = ConquestManager();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Lógica de conquista centralizada, delegada ao ConquestManager
  Future<void> triggerConquestFeedback({
    required bool firstTry,
    required VoidCallback applySettings,
    required VoidCallback onFinished,
  }) async {
    final userKey = HiveService.getUserKey(widget.user.key);
    await _conquestManager.registerRoundForConquest(
      context: context,
      firstTry: firstTry,
      applySettings: applySettings,
      onFinished: onFinished,
      userKey: userKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelManager = LevelManager(user: widget.user);

    return GamesDesign(
      user: widget.user,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: GameAnimations.buildTopInfo(
              progressValue: widget.progressValue,
              level: widget.level(levelManager),
              currentRound: widget.currentRound(levelManager),
              totalRounds: widget.totalRounds(levelManager),
              topTextWidget: widget.topTextContent(),
            ),
          ),
          widget.builder(
            context,
            levelManager,
            widget.user,
            triggerConquestFeedback,
          ),
        ],
      ),
    );
  }
}
