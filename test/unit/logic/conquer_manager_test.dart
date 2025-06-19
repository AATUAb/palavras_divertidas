import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../../lib/widgets/conquest_manager.dart';
import '../../../lib/models/user_model.dart';

/// Dummy BuildContext para testes unitarios.
/// Evita dependencias de UI reais em testes unitarios.
class DummyBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Testes unitarios para a logica do ConquestManager (gestor de conquistas).
///
/// Objetivo:
/// Validar de forma independente e automatizada as principais regras de conquista
/// aplicadas ao progresso do utilizador:
/// - Incremento de conquistas por acertos consecutivos na primeira tentativa
/// - Incremento de conquistas por persistencia (tentativas nao primeira)
/// - Reset de contadores e estatisticas
/// - Sincronizacao dos contadores internos com o utilizador

void main() {
  group('ConquestManager', () {
    late ConquestManager manager;
    late UserModel user;

    setUp(() {
      manager = ConquestManager();
      user = UserModel(name: 'Teste', schoolLevel: '1 Ciclo');
    });

    test('Inicia com zero conquistas e contadores limpos', () {
      expect(manager.conquest, 0);
      expect(manager.streakFirstTry, 0);
      expect(manager.persistenceCount, 0);
      expect(manager.sessionFirstTryCount, 0);
      expect(manager.sessionOtherTryCount, 0);
      expect(manager.totalRounds, 0);
      expect(manager.hasNewConquest, false);
    });

    test(
      'Regista conquista por acertos consecutivos na primeira tentativa',
      () {
        for (var i = 0; i < 10; i++) {
          manager.registerRound(firstTry: true, user: user);
        }
        expect(manager.conquest, 1);
        expect(manager.hasNewConquest, true);
        expect(manager.streakFirstTry, 0); // Reset apos conquista
        expect(user.firstTryCorrectTotal, 10);
      },
    );

    test('Regista conquista por persistencia (nao-firstTry)', () {
      for (var i = 0; i < 15; i++) {
        manager.registerRound(firstTry: false, user: user);
      }
      expect(manager.conquest, 1);
      expect(manager.hasNewConquest, true);
      expect(manager.persistenceCount, 0); // Reset apos conquista
      expect(user.persistenceCountTotal, 15);
    });

    test('Primeira tentativa acumula corretamente o streak', () {
      manager.registerRound(firstTry: true, user: user);
      manager.registerRound(firstTry: true, user: user);
      expect(manager.streakFirstTry, 2);
      // Um erro (nao primeira tentativa) zera o streak
      manager.registerRound(firstTry: false, user: user);
      expect(manager.streakFirstTry, 0);
    });

    test('PersistenceCount acumula apenas em tentativas nao-firstTry', () {
      manager.registerRound(firstTry: false, user: user);
      expect(manager.persistenceCount, 1);
      manager.registerRound(firstTry: false, user: user);
      expect(manager.persistenceCount, 2);
      // Acerto na primeira tentativa nao zera persistenceCount
      manager.registerRound(firstTry: true, user: user);
      expect(manager.persistenceCount, 2); // Nao zera (so reseta em conquista)
    });
  });
}
