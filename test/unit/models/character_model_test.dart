// Testes unitários ao modelo CharacterModel
//
// Este ficheiro cobre as validações essenciais para o modelo de dados CharacterModel, nomeadamente:
// - Criação de instâncias válidas com todos os campos obrigatórios.
// - Verificação do correto mapeamento dos atributos obrigatórios (character, soundPath, type).

import 'package:flutter_test/flutter_test.dart';
import 'package:mundodaspalavras/models/character_model.dart';

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
