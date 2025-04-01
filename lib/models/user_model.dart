import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  String level;

  @HiveField(2)
  List<String> knownLetters;

  /// Taxa de acerto por nível (ex: {1: 0.85, 2: 0.66})
  @HiveField(3)
  Map<int, double> accuracyByLevel = {};

  /// Taxa de acerto geral (0.0 a 1.0)
  @HiveField(4)
  double? overallAccuracy;

  UserModel({
    required this.name,
    required this.level,
    List<String>? knownLetters,
    this.accuracyByLevel = const {},
    this.overallAccuracy,
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
}
