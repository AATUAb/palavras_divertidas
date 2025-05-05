import 'package:hive/hive.dart';

part 'character_model.g.dart';

@HiveType(typeId: 1) // ◉ ID único para este modelo
class CharacterModel extends HiveObject {
  @HiveField(0) // ◉ índice 0
  final String character;

  @HiveField(1) // ◉ índice 1
  final String soundPath;

  @HiveField(2) // ◉ índice 2
  final String? imagePath; // Apenas números terão imagem

  CharacterModel({
    required this.character,
    required this.soundPath,
    this.imagePath,
  });
}

/// Preenche a box 'characters' se estiver vazia
Future<void> populateCharactersIfNeeded() async {
  final box = await Hive.openBox<CharacterModel>('characters');

  if (box.isEmpty) {
    final letters = 'ABCDEFGHIJLMNOPQRSTUVXZ'.split('');
    final numbers = '0123456789'.split('');
    final characters = [...letters, ...numbers];

    for (var char in characters) {
      final fileName = '$char.mp3';
      final soundPath = 'assets/characters_sounds/characters/$fileName';

      // Apenas números terão imagem associada
      final imagePath =
          RegExp(r'\d').hasMatch(char)
              ? 'assets/images/numbers/$char.png'
              : null;

      final model = CharacterModel(
        character: char,
        soundPath: soundPath,
        imagePath: imagePath,
      );

      await box.add(model);
    }
  }
}
