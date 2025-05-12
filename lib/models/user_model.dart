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

  @HiveField(4)
  double? overallAccuracy;

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
  Map<String, List<int>> gamesAccuracy;

  @HiveField(12)
  Map<String, int> totalCorrectPerGame;

  @HiveField(13)
  Map<String, int> totalAttemptsPerGame;

  final Logger logger = Logger();

  UserModel({
    required this.name,
    required this.schoolLevel,
    List<String>? knownLetters,
    this.accuracyByLevel = const {},
    this.overallAccuracy,
    this.gameLevel = 1,
    this.conquest = 0,
    this.firstTrySuccesses = 0,
    this.otherSuccesses = 0,
    this.firstTryCorrectTotal = 0,
    this.correctButNotFirstTryTotal = 0,
    this.gamesAccuracy = const {},
    Map<String, int>? totalCorrectPerGame,
    Map<String, int>? totalAttemptsPerGame,
  })  : knownLetters = knownLetters ?? [],
        totalCorrectPerGame = Map.from(totalCorrectPerGame ?? {}),
        totalAttemptsPerGame = Map.from(totalAttemptsPerGame ?? {});

  /// Atualiza a precisão por nível e calcula a média geral
  void updateAccuracy({
    required int level,
    required double accuracy,
    String? gameName,
  }) {
    accuracyByLevel = {...accuracyByLevel, level: accuracy};

    if (accuracyByLevel.isNotEmpty) {
      overallAccuracy = accuracyByLevel.values.reduce((a, b) => a + b) /
          accuracyByLevel.length;
    } else {
      overallAccuracy = null;
    }

    // Atualiza também o mapa geral do jogo se fornecido
    if (gameName != null) {
      final updatedList = [...(gamesAccuracy[gameName] ?? List.filled(3, 0))];
      if (level >= 1 && level <= updatedList.length) {
        updatedList[level - 1] = (accuracy * 100).round();
        gamesAccuracy = {...gamesAccuracy, gameName: updatedList};
      }
    }
  }

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

  /*void incrementConquest() {
    logger.i("Incrementing conquest. Current value: $conquest");
    conquest++;
    logger.i("New conquest value: $conquest");
  }*/

  void incrementConquest() {
    conquest++;
  }

  UserModel copyWith({
    String? name,
    String? schoolLevel,
    List<String>? knownLetters,
    int? gameLevel,
    Map<int, double>? accuracyByLevel,
    double? overallAccuracy,
    int? conquest,
    int? firstTrySuccesses,
    int? otherSuccesses,
    int? firstTryCorrectTotal,
    int? correctButNotFirstTryTotal,
    Map<String, List<int>>? gamesAccuracy,
    Map<String, int>? totalCorrectPerGame,
    Map<String, int>? totalAttemptsPerGame,
  }) {
    return UserModel(
      name: name ?? this.name,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      knownLetters: knownLetters ?? this.knownLetters,
      gameLevel: gameLevel ?? this.gameLevel,
      accuracyByLevel: accuracyByLevel ?? this.accuracyByLevel,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      conquest: conquest ?? this.conquest,
      firstTrySuccesses: firstTrySuccesses ?? this.firstTrySuccesses,
      otherSuccesses: otherSuccesses ?? this.otherSuccesses,
      firstTryCorrectTotal: firstTryCorrectTotal ?? this.firstTryCorrectTotal,
      correctButNotFirstTryTotal:
          correctButNotFirstTryTotal ?? this.correctButNotFirstTryTotal,
      gamesAccuracy: gamesAccuracy ?? this.gamesAccuracy,
      totalCorrectPerGame: totalCorrectPerGame ?? this.totalCorrectPerGame,
      totalAttemptsPerGame: totalAttemptsPerGame ?? this.totalAttemptsPerGame,
    );
  }

  @override
  Future<void> save() async {
    await super.save();
  }
}
