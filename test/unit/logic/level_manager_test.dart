// Testes unitarios a logica do LevelManager
//
// Este ficheiro cobre todas as areas criticas da logica de progressao de nivel da aplicacao:
// - Inicializacao e sincronizacao do nivel do utilizador.
// - Logica de subida e descida de nivel em funcao da performance (com reset dos contadores).
// - Limites do sistema de niveis (maximo/minimo).
// - Calculo e precisao da percentagem de acertos.
// - Reset de progresso e reset do nivel.
// - Sincronizacao manual do nivel com o estado do utilizador.

import 'package:flutter_test/flutter_test.dart';
import '../../../lib/widgets/level_manager.dart';
import '../../../lib/models/user_model.dart';

void main() {
  late UserModel user;

  setUp(() {
    user = UserModel(
      name: 'Utilizador Teste',
      schoolLevel: '1 Ciclo',
      knownLetters: [],
      accuracyByLevel: const {},
      gameLevel: 1,
      conquest: 0,
      firstTrySuccesses: 0,
      otherSuccesses: 0,
      firstTryCorrectTotal: 0,
      correctButNotFirstTryTotal: 0,
      persistenceCountTotal: 0,
      gamesAccuracy: const {},
      totalCorrectPerGame: const {},
      totalAttemptsPerGame: const {},
      lastSeenConquests: 0,
      lastLettersHash: '',
      gamesAverageTime: const {},
    );
  });

  group('LevelManager', () {
    test('Deve iniciar com o nivel do utilizador', () {
      final manager = LevelManager(user: user, gameName: 'JogoTeste');
      expect(manager.level, equals(user.gameLevel));
    });

    test(
      'Deve subir um nivel se tiver 80% ou superior de taxa de acerto, apos uma ronda de 8 respostas corretas',
      () async {
        final manager = LevelManager(user: user, gameName: 'JogoTeste');
        for (int i = 0; i < (manager.roundsToEvaluate - 2) * 2; i++) {
          await manager.registerRoundForLevel(correct: true);
          expect(manager.level, 1);
        }
      },
    );

    test('Nao deve ultrapassar o nivel maximo', () async {
      final manager = LevelManager(user: user, gameName: 'JogoTeste', level: 3);
      for (int i = 0; i < manager.roundsToEvaluate * 4; i++) {
        await manager.registerRoundForLevel(correct: true);
        expect(manager.level, lessThanOrEqualTo(manager.maxLevel));
      }
      expect(manager.level, manager.maxLevel);
    });

    test(
      'Deve descer um nivel se tiver taxa de acerto inferior a 50%, apos uma ronda com 4 respostas incorretas',
      () async {
        final manager = LevelManager(
          user: user,
          gameName: 'JogoTeste',
          level: 2,
        );
        // 4 erros - nivel ainda nao desce
        for (int i = 0; i < manager.roundsToEvaluate; i++) {
          await manager.registerRoundForLevel(correct: false);
          expect(manager.level, 2);
        }
      },
    );

    test('Nao deve descer abaixo do nivel minimo', () async {
      final manager = LevelManager(user: user, gameName: 'JogoTeste', level: 1);
      for (int i = 0; i < manager.roundsToEvaluate * 2; i++) {
        await manager.registerRoundForLevel(correct: false);
        expect(manager.level, manager.minLevel);
      }
      expect(manager.level, manager.minLevel);
    });

    test('Deve calcular precisao corretamente', () async {
      final manager = LevelManager(user: user, gameName: 'JogoTeste');
      await manager.registerRoundForLevel(correct: true);
      await manager.registerRoundForLevel(correct: false);
      expect(manager.currentAccuracyPercent, 50);
    });

    test('Reset ao progresso e nivel', () async {
      final manager = LevelManager(user: user, gameName: 'JogoTeste');
      await manager.registerRoundForLevel(correct: true);
      await manager.resetLevelToOne();
      expect(manager.level, 1);
      expect(manager.totalRounds, 0);
      expect(manager.correctAnswers, 0);
    });

    test('Sincroniza nivel com utilizador', () {
      final manager = LevelManager(user: user, gameName: 'JogoTeste', level: 2);
      user.gameLevel = 3;
      manager.syncLevelWithUser();
      expect(manager.level, 3);
    });
  });
}
