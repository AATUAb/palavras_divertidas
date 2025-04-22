import 'package:hive/hive.dart';

part 'character_model.g.dart';

@HiveType(typeId: 1)
class CharacterModel extends HiveObject {
  @HiveField(0)
  String character;

  @HiveField(1)
  String soundPath;

  @HiveField(2)
  String? imagePath; // Apenas para números

  CharacterModel({
    required this.character,
    required this.soundPath,
    this.imagePath,
  });
}

Future<void> populateCharactersIfNeeded() async {
  final box = await Hive.openBox<CharacterModel>('characters');

  if (box.isEmpty) {
    final letters = 'ABCDEFGHIJLMNOPQRSTUVXZ'.split('');
    final numbers = '0123456789'.split('');

    final characters = [...letters, ...numbers];

    for (var char in characters) {
      final fileName = '$char.mp3';
      final soundPath = 'assets/characters_sounds/characters/$fileName';

      // Apenas os números terão imagem
      final imagePath = RegExp(r'\d').hasMatch(char)
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
