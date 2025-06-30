import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String schoolLevel;

  @HiveField(2)
  List<String> knownLetters;

  @HiveField(3)
  Map<int, double> accuracyByLevel;

  @HiveField(5)
  int gameLevel;

  @HiveField(6)
  int conquest;

  @HiveField(7)
  int firstTrySuccesses;

  @HiveField(8)
  int otherSuccesses;

  @HiveField(9)
  int firstTryCorrectTotal;

  @HiveField(10)
  int correctButNotFirstTryTotal;

  @HiveField(11)
  int persistenceCountTotal;

  @HiveField(12)
  Map<String, List<int>> gamesAccuracy;

  @HiveField(13)
  Map<String, int> totalCorrectPerGame;

  @HiveField(14)
  Map<String, int> totalAttemptsPerGame;

  @HiveField(15)
  int lastSeenConquests;

  @HiveField(16)
  String? lastLettersHash;

  @HiveField(17)
  Map<String, double> gamesAverageTime;

  @HiveField(18)
  Map<String, Map<int, double>> gamesAverageTimeByLevel = {};

  @HiveField(19)
  Map<String, Map<int, int>> gamesCorrectCountByLevel = {};

  final Logger logger = Logger();

  UserModel({
    required this.name,
    required this.schoolLevel,
    List<String>? knownLetters,
    this.accuracyByLevel = const {},
    //this.overallAccuracy,
    this.gameLevel = 1,
    this.conquest = 0,
    this.firstTrySuccesses = 0,
    this.otherSuccesses = 0,
    this.firstTryCorrectTotal = 0,
    this.correctButNotFirstTryTotal = 0,
    this.persistenceCountTotal = 0,
    this.gamesAccuracy = const {},
    Map<String, int>? totalCorrectPerGame,
    Map<String, int>? totalAttemptsPerGame,
    this.lastLettersHash,
    this.lastSeenConquests = 0,
    this.gamesAverageTime = const {},
  }) : knownLetters = knownLetters ?? [],
       totalCorrectPerGame = Map.from(totalCorrectPerGame ?? {}),
       totalAttemptsPerGame = Map.from(totalAttemptsPerGame ?? {});

  void updateGameAccuracy({
    required String gameId,
    required int level,
    required int value,
  }) {
    final updatedList = [...(gamesAccuracy[gameId] ?? List.filled(3, 0))];
    if (level >= 1 && level <= updatedList.length) {
      updatedList[level - 1] = value;
      gamesAccuracy = {...gamesAccuracy, gameId: updatedList};
    }
  }

  void incrementConquest() {
    logger.i("Incrementing conquest. Current value: $conquest");
    conquest++;
    logger.i("New conquest value: $conquest");
  }

  // Atualiza o tempo médio de resposta para o jogo
  void updateGameTime(String gameName, double responseTime) {
    if (gamesAverageTime.containsKey(gameName)) {
      int n = (totalCorrectPerGame[gameName] ?? 0);
      double oldAvg = gamesAverageTime[gameName] ?? 0;
      double newAvg = ((oldAvg * n) + responseTime) / (n + 1);
      gamesAverageTime = {...gamesAverageTime, gameName: newAvg};
      totalCorrectPerGame[gameName] = n + 1;
    } else {
      gamesAverageTime = {...gamesAverageTime, gameName: responseTime};
      totalCorrectPerGame[gameName] = 1;
    }
  }

  // Atualiza o tempo médio de resposta por nível para o jogo
  void updateGameTimeByLevel(String gameName, int level, double responseTime) {
    final timeByLevel = Map<int, double>.from(
      gamesAverageTimeByLevel[gameName] ?? {},
    );
    final countByLevel = Map<int, int>.from(
      gamesCorrectCountByLevel[gameName] ?? {},
    );

    int n = countByLevel[level] ?? 0;
    double oldAvg = timeByLevel[level] ?? 0.0;
    double newAvg = ((oldAvg * n) + responseTime) / (n + 1);

    timeByLevel[level] = newAvg;
    countByLevel[level] = n + 1;

    gamesAverageTimeByLevel = {
      ...gamesAverageTimeByLevel,
      gameName: timeByLevel,
    };
    gamesCorrectCountByLevel = {
      ...gamesCorrectCountByLevel,
      gameName: countByLevel,
    };
  }

  UserModel copyWith({
    String? name,
    String? schoolLevel,
    List<String>? knownLetters,
    int? gameLevel,
    Map<int, double>? accuracyByLevel,
    //double? overallAccuracy,
    int? conquest,
    int? firstTrySuccesses,
    int? otherSuccesses,
    int? firstTryCorrectTotal,
    int? correctButNotFirstTryTotal,
    int? persistenceCountTotal,
    Map<String, List<int>>? gamesAccuracy,
    Map<String, int>? totalCorrectPerGame,
    Map<String, int>? totalAttemptsPerGame,
    int? lastSeenConquests,
    String? lastLettersHash,
    Map<String, double>? gamesAverageTime,
  }) {
    return UserModel(
      name: name ?? this.name,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      knownLetters: knownLetters ?? this.knownLetters,
      accuracyByLevel: accuracyByLevel ?? this.accuracyByLevel,
      //overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      gameLevel: gameLevel ?? this.gameLevel,
      conquest: conquest ?? this.conquest,
      firstTrySuccesses: firstTrySuccesses ?? this.firstTrySuccesses,
      otherSuccesses: otherSuccesses ?? this.otherSuccesses,
      firstTryCorrectTotal: firstTryCorrectTotal ?? this.firstTryCorrectTotal,
      correctButNotFirstTryTotal:
          correctButNotFirstTryTotal ?? this.correctButNotFirstTryTotal,
      persistenceCountTotal:
          persistenceCountTotal ?? this.persistenceCountTotal,
      gamesAccuracy: gamesAccuracy ?? this.gamesAccuracy,
      totalCorrectPerGame: totalCorrectPerGame ?? this.totalCorrectPerGame,
      totalAttemptsPerGame: totalAttemptsPerGame ?? this.totalAttemptsPerGame,
      lastSeenConquests: lastSeenConquests ?? this.lastSeenConquests,
      lastLettersHash: lastLettersHash ?? this.lastLettersHash,
      gamesAverageTime: gamesAverageTime ?? this.gamesAverageTime, // <-- E isto
    );
  }

  @override
  Future<void> save() async {
    await super.save();
  }
}
