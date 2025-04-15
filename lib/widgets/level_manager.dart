import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
//import 'game_animations.dart';
//import '../games/game_super_widget.dart';

class LevelManager {
  final UserModel user;
  final String gameName; // ⚠️ Obrigatório e consistente com o dashboard

  int level;
  int totalRounds = 0;
  int correctAnswers = 0;

  final int maxLevel;
  final int minLevel;
  final int roundsToEvaluate;

  LevelManager({
    required this.user,
    required this.gameName,
    int? level,
    this.maxLevel = 3,
    this.minLevel = 1,
    this.roundsToEvaluate = 1, // aumentar para 4 na release
  }) : level = level ?? user.gameLevel;

  int get totalRoundsCount => totalRounds;
  int get evaluationRounds => roundsToEvaluate;

  void registerRound({required bool correct}) {
    totalRounds++;
    if (correct) correctAnswers++;
  }

  Future<void> registerRoundForLevel({
  required BuildContext context,
  required bool correct,
  required VoidCallback applySettings,
  required VoidCallback onFinished,
  required void Function(int newLevel, bool increased)? showLevelFeedback,
}) async {
  final int previousLevel = level;

  registerRound(correct: correct);

  final double accuracy = correctAnswers / totalRounds;
  final int userKey = user.key as int;

  user.updateAccuracy(level: level, accuracy: accuracy);
  await HiveService.updateUserByKey(userKey, user);

  bool subiuNivel = false;
  bool desceuNivel = false;

  if (totalRounds >= roundsToEvaluate * 2 && accuracy >= 0.8 && level < maxLevel) {
    level++;
    subiuNivel = true;
  } else if (totalRounds >= roundsToEvaluate && accuracy < 0.5 && level > minLevel) {
    level--;
    desceuNivel = true;
  }

  if (subiuNivel || desceuNivel) {
    user.gameLevel = level;
    await HiveService.updateUserByKey(userKey, user);

    if (showLevelFeedback != null) {
      showLevelFeedback(level, subiuNivel);
    }

    totalRounds = 0;
    correctAnswers = 0;
  }

  applySettings();
  onFinished();
}
}



 /* int get totalRoundsCount => totalRounds;
  int get evaluationRounds => roundsToEvaluate;

  void registerRound({required bool correct}) {
    totalRounds++;
    if (correct) correctAnswers++;

    final double accuracy = correctAnswers / totalRounds;
    final int userKey = user.key as int;

    user.updateAccuracy(level: level, accuracy: accuracy);
    HiveService.updateUserByKey(userKey, user);

    // Ajuste automático do nível
    if (totalRounds >= roundsToEvaluate * 2 &&
        accuracy >= 0.8 &&
        level < maxLevel) {
      level++;
      user.gameLevel = level;
      HiveService.updateUserByKey(userKey, user);
      totalRounds = 0;
      correctAnswers = 0;
    } else if (totalRounds >= roundsToEvaluate &&
        accuracy < 0.5 &&
        level > minLevel) {
      level--;
      user.gameLevel = level;
      HiveService.updateUserByKey(userKey, user);
      totalRounds = 0;
      correctAnswers = 0;
    }
  }

  /Future<void> registerRoundForLevel({
    required BuildContext context,
    required bool correct,
    required VoidCallback applySettings,
    required VoidCallback onFinished,
  }) async {
    final int previousLevel = level;
    final int userKey = user.key as int;

    registerRound(correct: correct);

    // ✅ Atualiza a taxa de acerto sem modificar Map imutável
    if (totalRounds == roundsToEvaluate) {
      final double accuracy = correctAnswers / totalRounds;

      final original = user.gamesAccuracy[gameName];
      final List<double> updated =
          original != null ? List<double>.from(original) : [0.0, 0.0, 0.0];

      if (level >= 1 && level <= updated.length) {
        updated[level - 1] = accuracy;
      }

      // 🧠 Atualiza o Map completo de forma segura (cópia do Map)
      final newMap = Map<String, List<double>>.from(user.gamesAccuracy)
        ..[gameName] = updated;

      user.gamesAccuracy = newMap;

      await HiveService.updateUserByKey(userKey, user);
    }

    // 🎯 Animação de mudança de nível
    final bool leveledUp = level > previousLevel;
    final bool leveledDown = level < previousLevel;

    if (leveledUp || leveledDown) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(16.w),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: GameAnimations.starByLevel(
                        level: level,
                        width: 350.w,
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FittedBox(
                      child: Text(
                        leveledUp
                            ? 'Parabéns! Subiste para o nível $level!'
                            : 'Vamos treinar melhor o nível $level!',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: leveledUp ? Colors.orange : Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      user.gameLevel = level;
      HiveService.updateUserByKey(userKey, user);
    }

    applySettings();
    onFinished();
  }
}*/
