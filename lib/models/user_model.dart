// Modelo de dados para representar um utilizador da aplicação.

import 'package:hive/hive.dart';

// Indica que este arquivo terá um código gerado pelo Hive
part 'user_model.g.dart';

// Define a classe que será armazenada na base de dados local Hive
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  // Nome do utilizador
  @HiveField(0)
  final String name;

  // Nível atual do utilizador (pode ser usado para lógica de progressão)
  @HiveField(1)
  final String level;

  // Lista de letras que o utilizador já aprendeu ou completou
  @HiveField(2)
  List<String> knownLetters;

  // Construtor da classe UserModel
  UserModel({
    required this.name,
    required this.level,
    List<String>? knownLetters, // Parametro opcional
  }) : knownLetters =
           knownLetters ?? []; // Se nao fornecido, inicializa como lista vazia
}
