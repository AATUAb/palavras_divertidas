//Estrutura de progressão etre níveis de dificuldade, aplicável a todos os jogos

class LevelManager {
  int level;
  int totalRounds = 0;
  int firstTryCorrect = 0;

  final int maxLevel;
  final int minLevel;
  final int roundsToEvaluate;

  LevelManager({
    this.level = 1,
    this.maxLevel = 3,
    this.minLevel = 1,
    this.roundsToEvaluate = 4,
  });

  void registerRound({required bool firstTry}) {
    totalRounds++;
    if (firstTry) firstTryCorrect++;

    if (totalRounds >= roundsToEvaluate) {
      double accuracy = firstTryCorrect / totalRounds;

      if (accuracy >= 0.8 && level < maxLevel) level++;
      if (accuracy < 0.5 && level > minLevel) level--;

      totalRounds = 0;
      firstTryCorrect = 0;
    }
  }
}
