import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  /// Nível escolar: "Pré-Escolar", "1º Ciclo", etc.
  @HiveField(1)
  String schoolLevel;

  @HiveField(2)
  List<String> knownLetters;

  /// Taxa de acerto por nível (ex: {1: 0.85, 2: 0.66})
  @HiveField(3)
  Map<int, double> accuracyByLevel = {};

  /// Taxa de acerto geral (0.0 a 1.0)
  @HiveField(4)
  double? overallAccuracy;

  /// Nível de jogo (1, 2, 3...)
  @HiveField(5)
  int gameLevel;

  /// Contagem de conquistas (autocolantes)
  @HiveField(6)
  int conquest;

  /// Contagem de acertos na primeira tentativa para a próxima conquista
  @HiveField(7)
  int firstTrySuccesses;

  /// Contagem de acertos (não na primeira tentativa) para a próxima conquista
  @HiveField(8)
  int otherSuccesses;

  /// Novo: Taxa de acerto por jogo, por nível (ex: {'identify_game': [0.8, 0.7, 0.9]})
  @HiveField(9)
  Map<String, List<double>> gamesAccuracy;

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
    this.gamesAccuracy = const {},
  }) : knownLetters = knownLetters ?? [];

  /// Atualiza a taxa de acerto por nível e a média geral
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

  /// Atualiza a lista de acertos por jogo
  void updateGameAccuracy({
    required String gameId,
    required int level,
    required double value,
  }) {
    final updatedList = [...(gamesAccuracy[gameId] ?? List.filled(3, 0))];
    if (level >= 1 && level <= updatedList.length) {
      updatedList[level - 1] = value;
      gamesAccuracy = {
        ...gamesAccuracy,
        gameId: updatedList.map((e) => e.toDouble()).toList(),
      };
    }
  }

  final Logger logger = Logger();

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
    Map<String, List<double>>? gamesAccuracy,
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
      gamesAccuracy: gamesAccuracy ?? this.gamesAccuracy,
    );
  }

  /// Salva o UserModel no Hive
  @override
  Future<void> save() async {
    await super.save();
  }
}
