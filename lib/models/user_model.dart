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
  int persistenceCountTotal;

  @HiveField(12)
  Map<String, List<int>> gamesAccuracy;

  @HiveField(13)
  Map<String, int> totalCorrectPerGame;

  @HiveField(14)
  Map<String, int> totalAttemptsPerGame;

  @HiveField(15)
  int lastSeenConquests; // ← novo campo

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
    this.persistenceCountTotal = 0,
    this.gamesAccuracy = const {},
    Map<String, int>? totalCorrectPerGame,
    Map<String, int>? totalAttemptsPerGame,
    this.lastSeenConquests = 0, // valor inicial
  }) : knownLetters = knownLetters ?? [],
       totalCorrectPerGame = Map.from(totalCorrectPerGame ?? {}),
       totalAttemptsPerGame = Map.from(totalAttemptsPerGame ?? {});

  void updateAccuracy({required int level, required double accuracy}) {
    accuracyByLevel = {...accuracyByLevel, level: accuracy};
    if (accuracyByLevel.isNotEmpty) {
      overallAccuracy =
          accuracyByLevel.values.reduce((a, b) => a + b) /
          accuracyByLevel.length;
    } else {
      overallAccuracy = null;
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

  void incrementConquest() {
    logger.i("Incrementing conquest. Current value: $conquest");
    conquest++;
    logger.i("New conquest value: $conquest");
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
    int? persistenceCountTotal,
    Map<String, List<int>>? gamesAccuracy,
    Map<String, int>? totalCorrectPerGame,
    Map<String, int>? totalAttemptsPerGame,
    int? lastSeenConquests, // ← incluído no copyWith
  }) {
    return UserModel(
      name: name ?? this.name,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      knownLetters: knownLetters ?? this.knownLetters,
      accuracyByLevel: accuracyByLevel ?? this.accuracyByLevel,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
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
    );
  }

  @override
  Future<void> save() async {
    await super.save();
  }
}
