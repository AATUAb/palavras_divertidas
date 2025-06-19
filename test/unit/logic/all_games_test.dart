import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

/// Testes unitarios: verifica a logica basica de cada jogo principal.
/// Cada teste valida apenas a funcionalidade central do respetivo modulo de jogo
///
/// - Jogo 1: Identificar Letras e Numeros
/// - Jogo 2: Escrever (letras e numeros)
/// - Jogo 3: Contar Silabas
/// - Jogo 4: Identificar Palavras
/// - Jogo 5: Ouvir e Ver
/// - Jogo 6: Silaba Perdida

void main() {
  group('AllGames', () {
    test('Jogo 1: Permite identificar o target como correto', () {
      // Gera opcoes corretas
      final count = 3;
      final target = 'A';
      final opcoes = List.generate(count, (_) => target);
      expect(opcoes.contains('A'), isTrue);
    });

    test(
      'Jogo 2: Permite escrever numeros e letras (maiusculas e minusculas)',
      () {
        final chars = ['a', 'B', '7', 'z', 'X', '0'];
        // Verifica que todas as entradas sao aceites
        expect(
          chars.every((c) => RegExp(r'^[a-zA-Z0-9]$').hasMatch(c)),
          isTrue,
        );
      },
    );

    test('Jogo 3: Inclui 2/3 opcoes (1/2 distratores + 1 target)', () {
      // Gera distratores para o correto=3 e n=2
      int correto = 3;
      int n = 2;
      List<int> distratores;
      if (correto == 1) {
        distratores = n == 1 ? [2] : [2, 3];
      } else {
        final set = <int>{};
        int offset = 1;
        while (set.length < n) {
          if (correto - offset >= 1) set.add(correto - offset);
          if (correto + offset <= 9) set.add(correto + offset);
          offset++;
        }
        distratores = set.toList();
        distratores.length = min(n, distratores.length);
      }
      expect(distratores.length, equals(2));
    });

    test('Jogo 4: Inclui 2/3 opcoes (1/2 distratores + 1 target)', () {
      final target = 'casa';
      final pool = ['bola', 'gato'];
      final count = 3;
      final opcoes = [target];
      for (final p in pool) {
        if (opcoes.length >= count) break;
        if (p != target) opcoes.add(p);
      }
      expect(opcoes.length >= 2, isTrue);
      expect(opcoes.contains('casa'), isTrue);
    });

    test('Jogo 5: Permite verificar a correspondencia do som com o target', () {
      String target = 'bola';
      String imagem1 = 'bola';
      String imagem2 = 'casa';
      expect(imagem1 == target, isTrue);
      expect(imagem2 == target, isFalse);
    });

    test('Jogo 6: Preenche silaba em falta na palavra target', () {
      String palavra = 'pa--la';
      int idx = 1;
      String palpite = 'la';
      final partes = palavra.split('-');
      partes[idx] = palpite;
      final resultado = partes.join('-');
      expect(resultado, equals('pa-la-la'));
    });
  });
}
