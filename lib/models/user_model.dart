import 'package:hive/hive.dart';
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

  UserModel({
    required this.name,
    required this.schoolLevel,
    List<String>? knownLetters,
    this.accuracyByLevel = const {},
    this.overallAccuracy,
    this.gameLevel = 1,
    this.conquest = 0,
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

  /// Incrementa o número de conquistas
  void incrementConquest() {
    conquest++;
  }

  /// Método de cópia para atualização do modelo
  UserModel copyWith({
  String? name,
  String? schoolLevel,
  List<String>? knownLetters,
  int? gameLevel,
  Map<int, double>? accuracyByLevel,
  double? overallAccuracy,
  int? conquest,
}) {
  return UserModel(
    name: name ?? this.name,
    schoolLevel: schoolLevel ?? this.schoolLevel,
    knownLetters: knownLetters ?? this.knownLetters,
    gameLevel: gameLevel ?? this.gameLevel,
    accuracyByLevel: accuracyByLevel ?? this.accuracyByLevel,
    overallAccuracy: overallAccuracy ?? this.overallAccuracy,
    conquest: conquest ?? this.conquest,
  );
}
}
