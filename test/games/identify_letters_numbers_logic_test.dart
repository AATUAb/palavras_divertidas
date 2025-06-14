import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

/// Testes unitários para a lógica central do jogo "Identificar Letras e Números".
///
/// Objetivo:
/// Validar a geração e verificação de opções corretas e erradas, e a lógica de reutilização de caracteres,
/// assegurando robustez e previsibilidade no core do jogo.
///
/// Abrangência:
/// - Geração de opções corretas (case-insensitive)
/// - Geração de opções erradas (excluindo o target)
/// - Verificação de repetição de caracteres
/// - Suporte a mistura de letras e números
///
/// NOTA: Este ficheiro NÃO testa o widget UI, apenas funções puras.
///
///// Para executar: flutter test test/games/identify_letters_numbers_logic_test.dart

// Simulação de CharacterModel simplificado.
class CharacterModel {
  final String character;
  CharacterModel({required this.character});
}

// Função para gerar opções corretas.
List<String> generateCorrectOptions({
  required int count,
  required String target,
}) {
  final rand = Random();
  return List.generate(
    count,
    (_) => rand.nextBool() ? target.toUpperCase() : target.toLowerCase(),
  );
}

// Função para gerar opções erradas.
List<String> generateWrongOptions({
  required int count,
  required List<CharacterModel> pool,
  required String target,
}) {
  final bad = <String>{};
  final rand = Random();

  while (bad.length < count) {
    final c = pool[rand.nextInt(pool.length)].character;
    final opt = rand.nextBool() ? c.toUpperCase() : c.toLowerCase();
    if (opt.toLowerCase() != target.toLowerCase()) {
      bad.add(opt);
    }
  }
  return bad.toList();
}

// Função para verificar se um carácter já foi usado.
bool retryIsUsed(List<String> used, String value) => used.contains(value);

void main() {
  group('Logica do IdentifyLettersNumbers', () {
    test(
      'Gera opcoes corretas - deve gerar o numero correto de elementos, todos iguais ao target, podendo variar em maiusculas/minusculas',
      () {
        // Arrange & Act
        final target = 'A';
        final corrects = generateCorrectOptions(count: 5, target: target);

        // Assert
        expect(corrects.length, equals(5));
        for (var c in corrects) {
          expect(c.toUpperCase(), equals(target));
        }
      },
    );

    test('Gera opcoes erradas - nunca deve conter o target', () {
      // Arrange
      final pool = [
        CharacterModel(character: 'A'),
        CharacterModel(character: 'B'),
        CharacterModel(character: 'C'),
      ];

      // Act
      final wrongs = generateWrongOptions(count: 2, pool: pool, target: 'A');

      // Assert
      expect(wrongs, isNot(contains('A')));
      expect(wrongs, isNot(contains('a')));
    });

    test(
      'retryIsUsed deve retornar true apenas se o caracter ja estiver utilizado',
      () {
        // Arrange
        final usados = ['A', 'B', 'C'];

        // Assert
        expect(retryIsUsed(usados, 'B'), isTrue);
        expect(retryIsUsed(usados, 'D'), isFalse);
      },
    );

    test('Geracao de errados deve suportar mistura de letras e numeros', () {
      // Arrange
      final pool = [
        CharacterModel(character: 'A'),
        CharacterModel(character: '2'),
        CharacterModel(character: 'B'),
        CharacterModel(character: '3'),
      ];

      // Act
      final wrongs = generateWrongOptions(count: 3, pool: pool, target: 'A');

      // Assert
      expect(wrongs.length, equals(3));
      expect(wrongs, isNot(contains('A')));
      expect(wrongs.any((e) => e == '2' || e == '3'), isTrue);
    });
  });
}
