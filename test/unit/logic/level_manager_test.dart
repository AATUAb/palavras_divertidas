// Testes unitários à lógica do LevelManager
//
// Este ficheiro cobre todas as áreas críticas da lógica de progressão de nível da aplicação,
// nomeadamente:
// - Inicialização e sincronização do nível do utilizador.
// - Lógica de subida e descida de nível em função da performance.
// - Limites do sistema de níveis (máximo/mínimo).
// - Cálculo e precisão da percentagem de acertos.
// - Reset de progresso e reset do nível.
// - Sincronização manual do nível com o estado do utilizador.
//
// NOTA CORPORATIVA:
// Para isolamento total de dependências externas (ex: HiveService), recomenda-se a utilização de mocks.
// Pode recorrer a mockito ou mocktail para mockar interações com serviços externos, garantindo que só
// a lógica do LevelManager está sob teste. Ajuste os campos dos construtores dos modelos conforme necessário.

import 'package:flutter_test/flutter_test.dart';
import '../../../lib/widgets/level_manager.dart';
import '../../../lib/models/user_model.dart';

void main() {
  late UserModel user;

  // Pré-condição: cada teste começa com um utilizador de teste inicializado
  setUp(() {
    user = UserModel(
      name: 'Utilizador Teste',
      schoolLevel: '1º Ciclo',
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
    // Verifica que o gestor inicia com o nível definido no utilizador
    test('Deve iniciar com o nivel do utilizador', () {
      final manager = LevelManager(user: user, gameName: 'JogoTeste');
      expect(manager.level, equals(user.gameLevel));
    });

    // Simula respostas certas e confirma a lógica de subida de nível
    test('Deve incrementar nivel ao obter acertos suficientes', () async {
      final manager = LevelManager(user: user, gameName: 'JogoTeste');
      // Simula respostas certas, o dobro do roundsToEvaluate
      for (int i = 0; i < manager.roundsToEvaluate * 2; i++) {
        await manager.registerRoundForLevel(correct: true);
      }
      expect(manager.level, 2);
      expect(manager.levelChanged, true);
      expect(manager.levelIncreased, true);
    });

    // Simula respostas erradas e valida a descida de nível
    test('Deve descer de nivel apos erros consecutivos', () async {
      final manager = LevelManager(user: user, gameName: 'JogoTeste', level: 2);
      // Simula respostas erradas, igual ao roundsToEvaluate
      for (int i = 0; i < manager.roundsToEvaluate; i++) {
        await manager.registerRoundForLevel(correct: false);
      }
      expect(manager.level, 1);
      expect(manager.levelChanged, true);
      expect(manager.levelIncreased, false);
    });

    // Garante que o nível não excede o máximo configurado
    test('Nao deve ultrapassar o nivel maximo', () async {
      final manager = LevelManager(
        user: user,
        gameName: 'JogoTeste',
        level: 3, // maxLevel por default é 3
      );
      for (int i = 0; i < manager.roundsToEvaluate * 2; i++) {
        await manager.registerRoundForLevel(correct: true);
      }
      expect(manager.level, manager.maxLevel);
    });

    // Garante que o nível não desce abaixo do mínimo configurado
    test('Nao deve descer abaixo do nivel minimo', () async {
      final manager = LevelManager(
        user: user,
        gameName: 'JogoTeste',
        level: 1, // minLevel por default é 1
      );
      for (int i = 0; i < manager.roundsToEvaluate; i++) {
        await manager.registerRoundForLevel(correct: false);
      }
      expect(manager.level, manager.minLevel);
    });

    // Valida o cálculo da precisão do jogador (% de acerto)
    test('Deve calcular precisao corretamente', () async {
      final manager = LevelManager(user: user, gameName: 'JogoTeste');
      await manager.registerRoundForLevel(correct: true);
      await manager.registerRoundForLevel(correct: false);
      expect(manager.currentAccuracyPercent, 50);
    });

    // Testa o reset do progresso e do nível do jogador
    test('Reset ao progresso e nivel', () async {
      final manager = LevelManager(user: user, gameName: 'JogoTeste');
      await manager.registerRoundForLevel(correct: true);
      await manager.resetLevelToOne();
      expect(manager.level, 1);
      expect(manager.totalRounds, 0);
      expect(manager.correctAnswers, 0);
    });

    // Valida a sincronização manual do nível do gestor com o utilizador
    test('Sincroniza nivel com utilizador', () {
      final manager = LevelManager(user: user, gameName: 'JogoTeste', level: 2);
      user.gameLevel = 3;
      manager.syncLevelWithUser();
      expect(manager.level, 3);
    });
  });
}
