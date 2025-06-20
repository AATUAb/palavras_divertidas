/*
  Teste de Integração Flow: CountSyllables
  Valida ciclo: Hive <-> lógica <-> SuperWidget <-> Jogo
  (SEM testar interações UI. Só integração e ciclo de vida!)
*/

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';

import '../../../lib/services/hive_service.dart';
import '../../../lib/models/user_model.dart';
import '../../../lib/games/count_syllables.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock do path_provider para Hive funcionar em testes
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  pathProviderChannel.setMockMethodCallHandler((call) async {
    if (call.method == 'getApplicationDocumentsDirectory') {
      return (await Directory.systemTemp.createTemp()).path;
    }
    return null;
  });

  setUp(() async {
    await setUpTestHive();
    await HiveService.init();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('Integracao Flow: ', () {
    test(
      'Hive (Base de dados) <-> SuperWidget <-> Jogo (CountSyllables)',
      () async {
        // 1. Cria e persiste utilizador em Hive
        final user = UserModel(
          name: "Tester",
          schoolLevel: "1 ciclo",
          knownLetters: [],
        );
        await HiveService.addUser(user);
        final users = HiveService.getUsers();
        expect(users.length, 1);

        // 2. Inicializa o jogo concreto (CountSyllablesGame)
        final gameWidget = CountSyllablesGame(user: users.first);

        // 3. Valida que o jogo inicializa (simulação de ciclo de vida)
        expect(gameWidget.user.name, "Tester");
        // Não testamos métodos UI, apenas integração de objetos/ciclo

        // 4. Simula progresso e persistência
        await HiveService.saveGameLevel(
          userKey: "0",
          gameName: "CountSyllables",
          level: 2,
        );
        final nivel = await HiveService.getGameLevel(
          userKey: "0",
          gameName: "CountSyllables",
        );
        expect(nivel, 2);

        // 5. (Opcional) Simula atualização de accuracy
        await HiveService.updateGameAccuracy(
          userKey: 0,
          gameName: "CountSyllables",
          accuracyPerLevel: [90, 0, 0],
          levelOverride: 1,
        );
        final updatedUser = HiveService.getUser(0);
        expect(updatedUser?.gamesAccuracy["CountSyllables"]?[0], 90);
      },
    );
  });
}
