import 'dart:async';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

final logger = Logger();

// Classe para gerir o nível do jogo
class LevelManager {
  final UserModel user;
  final String gameName;

  int level;
  int totalRounds = 0;
  int correctAnswers = 0;
  int recentRounds = 0;
  int recentCorrect = 0;

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

  // Retorna a precisão atual do jogo, em percentagem
  int get currentAccuracyPercent {
    final accuracy = totalRounds == 0 ? 0.0 : correctAnswers / totalRounds;
    return (accuracy * 100).round();
  }

  // Carrega o nível do jogo especifico em Hive
  Future<void> loadLevel() async {
    if (user.key == null) return;
    level = await HiveService.getGameLevel(
      userKey: user.key!.toString(),
      gameName: gameName,
    );
    logger.i('📥 Nível carregado para ${user.name} no jogo $gameName: $level');
  }

  // Regista uma ronda nova do jogo e atualiza o nível
  Future<bool> registerRoundForLevel({required bool correct}) async {
    // Incrementa contadores globais
    totalRounds++;
    if (correct) correctAnswers++;

    // Incrementa contadores para avaliação de nível
    recentRounds++;
    if (correct) recentCorrect++;

    final userKey = user.key?.toString();
    if (userKey == null) return false;

    bool levelUp = false;
    bool levelDown = false;

    final int levelAtThisRound = level;
    final double accuracy =
        recentRounds == 0 ? 0.0 : recentCorrect / recentRounds;
    final int accuracyPercent = (accuracy * 100).round();

    // Verifica se deve subir ou descer de nível
    if (recentRounds >= roundsToEvaluate * 2 &&
        accuracy >= 0.8 &&
        level < maxLevel) {
      level++;
      levelUp = true;
    } else if (recentRounds >= roundsToEvaluate &&
        accuracy <= 0.5 &&
        level > minLevel) {
      level--;
      levelDown = true;
    }

    levelChanged = levelUp || levelDown;
    levelIncreased = levelUp;

    // Inicia gravações em Hive em segundo plano
    unawaited(
      HiveService.updateGameAccuracy(
        userKey: int.parse(userKey),
        gameName: gameName,
        accuracyPerLevel: [accuracyPercent],
        levelOverride: levelAtThisRound,
      ),
    );

    if (levelChanged) {
      recentRounds = 0;
      recentCorrect = 0;
    }

    // Só grava o nível novo se houver mudança
    unawaited(
      HiveService.saveGameLevel(
        userKey: userKey,
        gameName: gameName,
        level: level,
      ),
    );

    user.updateAccuracy(level: levelAtThisRound, accuracy: accuracy);
    unawaited(HiveService.updateUserByKey(int.parse(userKey), user));

    return levelChanged;
  }

  // Função para fazer o reset do progreso atual, aplicável quando há letras novas conhecidas
  Future<void> resetLevelToOne() async {
    level = 1;
    resetProgress();
    final userKey = user.key?.toString();
    if (userKey != null) {
      await HiveService.saveGameLevel(
        userKey: userKey,
        gameName: gameName,
        level: level,
      );
      user.updateAccuracy(level: 1, accuracy: 0);
      await HiveService.updateUserByKey(int.parse(userKey), user);
    }
  }

  // Função para sincronizar o nível do utilizador
  void syncLevelWithUser() {
    level = user.gameLevel;
  }

  // Função para fazer o reset do progreso
  void resetProgress() {
    totalRounds = 0;
    correctAnswers = 0;
    recentRounds = 0;
    recentCorrect = 0;
  }
}
