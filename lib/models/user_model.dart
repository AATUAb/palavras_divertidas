// Modelo de dados para representar um utilizador da aplicação.

import 'package:hive/hive.dart';

// Indica que este arquivo terá um código gerado pelo Hive
part 'user_model.g.dart';

// Define a classe que será armazenada na base de dados local Hive
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String level;

  @HiveField(2)
  List<String> knownLetters;

  @HiveField(3)
  Map<int, double> accuracyByLevel = {};

  @HiveField(4)
  double? overallAccuracy;

  UserModel({
    required this.name,
    required this.level,
    List<String>? knownLetters,
    this.accuracyByLevel = const {},
    this.overallAccuracy,
  }) : knownLetters = knownLetters ?? [];
}
