import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

class LevelManager {
  final UserModel user;
  final String gameName;

  int level;
  int totalRounds = 0;
  int correctAnswers = 0;
  bool levelChanged = false;
  bool levelIncreased = false;

  final int maxLevel;
  final int minLevel;
  final int roundsToEvaluate;

  LevelManager({
    required this.user,
    required this.gameName,
    int? level,
    this.maxLevel = 3,
    this.minLevel = 1,
    this.roundsToEvaluate = 4, //roundas para avaliar o nível
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
  registerRound(correct: correct);

  final userKey = user.key;
  if (userKey == null) return;

  bool subiuNivel = false;
  bool desceuNivel = false;

  final double accuracy = correctAnswers / totalRounds;

  if (totalRounds >= roundsToEvaluate * 2 && accuracy >= 0.8 && level < maxLevel) {
    level++;
    subiuNivel = true;
  } else if (totalRounds >= roundsToEvaluate && accuracy <= 0.5 && level > minLevel) {
    level--;
    desceuNivel = true;
  }

  levelChanged = subiuNivel || desceuNivel;
  levelIncreased = subiuNivel;

  // 🧠 Se mudou de nível, limpa estatísticas ANTES de guardar
  if (levelChanged) {
    totalRounds = 0;
    correctAnswers = 0;
  }

  // 📝 Atualiza info do utilizador
  user.gameLevel = level;
  user.updateAccuracy(level: level, accuracy: accuracy);
  user.accuracyByLevel[level] = accuracy;

  await HiveService.updateUserByKey(userKey, user);
  await HiveService.updateGameAccuracy(
    userKey: userKey,
    gameName: gameName,
    accuracyPerLevel: [accuracy],
  );

 /* // 🎯 Feedback visual (nível mudou)
  if (levelChanged && showLevelFeedback != null) {
    showLevelFeedback(level, subiuNivel);
  }*/

  applySettings();
  onFinished();
}
}
