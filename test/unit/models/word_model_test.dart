// Testes unitários ao modelo WordModel
//
// Este ficheiro cobre as validações essenciais para o modelo de dados WordModel, nomeadamente:
// - Criação de instâncias válidas com todos os campos obrigatórios e opcionais.
// - Verificação do correto mapeamento dos atributos obrigatórios e opcionais.
// - Validação dos getters personalizados (audioPath, imagePath).
// - Garantia da integridade da estrutura das palavras no domínio da aplicação.

import 'package:flutter_test/flutter_test.dart';
import 'package:mundodaspalavras/models/word_model.dart';

void main() {
  group('WordModel', () {
    test(
      'Deve criar uma palavra com todos os campos obrigatorios e opcionais',
      () {
        // Arrange: Instanciação do modelo com todos os campos.
        final word = WordModel(
          text: 'pavão',
          newLetter: 'v',
          topic: 'animais',
          difficulty: 'baixa',
          syllables: ['pa', 'vão'],
          syllableCount: 2,
          audioFileName: 'pavao',
          imageFileName: 'pavao',
        );

        // Assert: Verificação dos campos obrigatórios.
        expect(word.text, equals('pavão'));
        expect(word.newLetter, equals('v'));
        expect(word.topic, equals('animais'));
        expect(word.difficulty, equals('baixa'));
        expect(word.syllables, equals(['pa', 'vão']));
        expect(word.syllableCount, equals(2));
        expect(word.audioFileName, equals('pavao'));
        expect(word.imageFileName, equals('pavao'));

        // Assert: Testar os getters personalizados.
        expect(word.audioPath, equals('pavao'));
        expect(word.imagePath, equals('assets/images/words/pavao.webp'));
      },
    );

    test('Deve criar uma palavra sem campos opcionais', () {
      // Arrange: Instanciação do modelo apenas com os obrigatórios.
      final word = WordModel(
        text: 'pia',
        newLetter: 'p',
        topic: 'animais',
        difficulty: 'baixa',
        syllables: ['pia'],
        syllableCount: 1,
      );

      // Assert: Verificação dos campos obrigatórios.
      expect(word.text, equals('pia'));
      expect(word.newLetter, equals('p'));
      expect(word.topic, equals('animais'));
      expect(word.difficulty, equals('baixa'));
      expect(word.syllables, equals(['pia']));
      expect(word.syllableCount, equals(1));
      expect(word.audioFileName, isNull);
      expect(word.imageFileName, isNull);

      // Assert: Getters usam valor por omissão.
      expect(word.audioPath, equals('pia'));
      expect(word.imagePath, equals('assets/images/words/pia.webp'));
    });
  });
}
