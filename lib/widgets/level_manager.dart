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
    this.roundsToEvaluate = 1,
  }) : level = level ?? user.gameLevel;

  int get totalRoundsCount => totalRounds;
  int get evaluationRounds => roundsToEvaluate;

  void registerRound({required bool correct}) {
    totalRounds++;
    if (correct) correctAnswers++;
  }

List<int> get currentAccuracy {
  final accuracy = correctAnswers / (totalRounds == 0 ? 1 : totalRounds);
  final percent = (accuracy * 100).round();
  return [percent];
}

Future<bool> registerRoundForLevel({
  required bool correct,
}) async {
  registerRound(correct: correct);

  final userKey = user.key;
  if (userKey == null) return false;

  bool levelUp = false;
  bool levelDown = false;

  final int levelAtThisRound = level; 
  final double accuracy = correctAnswers / totalRounds;
  final int accuracyPercent = (accuracy * 100).round();

  // Verifica se o nível do utilizador deve ser atualizado
  if (totalRounds >= roundsToEvaluate * 2 &&
      accuracy >= 0.8 &&
      level < maxLevel) {
    level++;
    levelUp = true;
  } else if (totalRounds >= roundsToEvaluate &&
      accuracy <= 0.5 &&
      level > minLevel) {
    level--;
    levelDown = true;
  }

  levelChanged = levelUp || levelDown;
  levelIncreased = levelUp;

  // Atualiza a precisão do jogo no Hive, de acordo com o nível atual
  await HiveService.updateGameAccuracy(
    userKey: userKey,
    gameName: gameName,
    accuracyPerLevel: [accuracyPercent],
    levelOverride: levelAtThisRound,
  );

  if (levelChanged) {
    totalRounds = 0;
    correctAnswers = 0;
  }

  // Atualiza o nível do utilizador e a precisão
  user.gameLevel = level;
  user.updateAccuracy(level: levelAtThisRound, accuracy: accuracy);
  await HiveService.updateUserByKey(userKey, user);

  return levelChanged;
}
}
