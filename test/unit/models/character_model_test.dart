import 'package:flutter_test/flutter_test.dart';
import 'package:mundodaspalavras/models/character_model.dart';

/// Teste unitário para o modelo CharacterModel.
/// Objetivo: Garantir que o objeto CharacterModel é criado corretamente
/// e que os campos obrigatórios são atribuídos como esperado.
///
/// Para executar: flutter test test/models/character_model_test.dart
void main() {
  group('CharacterModel', () {
    test('Deve criar um caracter com os campos obrigatorios', () {
      // Arrange: Dados mínimos de teste conforme o modelo.
      final character = CharacterModel(
        character: 'A',
        soundPath: 'assets/sounds/characters/A.ogg',
        type: 'vowel',
      );

      // Assert: Verificar os campos obrigatórios.
      expect(character.character, equals('A'));
      expect(character.soundPath, equals('assets/sounds/characters/A.ogg'));
      expect(character.type, equals('vowel'));
    });
  });
}
