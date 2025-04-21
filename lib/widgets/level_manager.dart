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
    this.roundsToEvaluate = 4,
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

    final double accuracy = correctAnswers / totalRounds;
    final int userKey = user.key as int;

    user.updateAccuracy(level: level, accuracy: accuracy);
    user.accuracyByLevel[level] = accuracy;
    await HiveService.updateUserByKey(userKey, user);

    bool increasedLevel = false;
    bool decreasedLevel = false;

    if (totalRounds >= roundsToEvaluate * 2 &&
        accuracy >= 0.8 &&
        level < maxLevel) {
      level++;
      increasedLevel = true;
    } else if (totalRounds >= roundsToEvaluate &&
        accuracy < 0.5 &&
        level > minLevel) {
      level--;
      decreasedLevel = true;
    }

    levelChanged = increasedLevel || decreasedLevel;
    levelIncreased = increasedLevel;

    // ✅ Update total correct answers and attempts per game
    final updatedCorrect = {
      ...user.totalCorrectPerGame,
      gameName: (user.totalCorrectPerGame[gameName] ?? 0) + correctAnswers,
    };

    final updatedAttempts = {
      ...user.totalAttemptsPerGame,
      gameName: (user.totalAttemptsPerGame[gameName] ?? 0) + totalRounds,
    };

    user.totalCorrectPerGame = updatedCorrect;
    user.totalAttemptsPerGame = updatedAttempts;

    final totalCorrect = updatedCorrect[gameName]!;
    final totalAttempts = updatedAttempts[gameName]!;
    final cumulativeAverage =
        totalAttempts > 0 ? totalCorrect / totalAttempts : 0.0;

    await HiveService.updateGameAccuracy(
      userKey: userKey,
      gameName: gameName,
      accuracyPerLevel: [cumulativeAverage],
    );

    if (increasedLevel || decreasedLevel) {
      user.gameLevel = level;
      await HiveService.updateUserByKey(userKey, user);

      if (showLevelFeedback != null) {
        showLevelFeedback(level, increasedLevel);
      }

      totalRounds = 0;
      correctAnswers = 0;
    }

    applySettings();
    onFinished();
  }
}
