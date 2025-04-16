import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

class LevelSettings {
  final int correctCount;
  final int wrongCount;
  final Duration levelTime;

  const LevelSettings({
    required this.correctCount,
    required this.wrongCount,
    required this.levelTime,
  });
}

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
    this.roundsToEvaluate = 1, // ajustar se necessário
  }) : level = level ?? user.gameLevel;

  /// Definições de parâmetros por nível
  static final Map<int, LevelSettings> _levelConfigs = {
    1: LevelSettings(
      correctCount: 4,
      wrongCount: 8,
      levelTime: Duration(seconds: 10),
    ),
    2: LevelSettings(
      correctCount: 5,
      wrongCount: 10,
      levelTime: Duration(seconds: 15),
    ),
    3: LevelSettings(
      correctCount: 6,
      wrongCount: 12,
      levelTime: Duration(seconds: 20),
    ),
  };

  LevelSettings get currentSettings => _levelConfigs[level]!;

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

    // Atualiza a precisão no utilizador
    user.updateAccuracy(level: level, accuracy: accuracy);
    await HiveService.updateUserByKey(userKey, user);

    bool subiuNivel = false;
    bool desceuNivel = false;

    // Lógica de progressão de nível
    if (totalRounds >= roundsToEvaluate * 2 &&
        accuracy >= 0.8 &&
        level < maxLevel) {
      level++;
      subiuNivel = true;
    } else if (totalRounds >= roundsToEvaluate &&
        accuracy < 0.5 &&
        level > minLevel) {
      level--;
      desceuNivel = true;
    }

    if (subiuNivel || desceuNivel) {
      // Salva novo nível
      user.gameLevel = level;
      await HiveService.updateUserByKey(userKey, user);

      // Mostra feedback de mudança de nível
      if (showLevelFeedback != null) {
        showLevelFeedback(level, subiuNivel);
      }

      // Reset de métricas
      totalRounds = 0;
      correctAnswers = 0;
    }

    // Aplica configurações e continua
    applySettings();
    onFinished();
  }
}
