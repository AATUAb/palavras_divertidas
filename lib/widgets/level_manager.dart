import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

class LevelManager {
  final UserModel user;
  final String gameName; 

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
    this.roundsToEvaluate = 4, // aumentar para 4 na release
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