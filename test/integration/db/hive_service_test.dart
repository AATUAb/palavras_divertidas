/*
  Testes de Integracao - HiveService

  Este conjunto de testes valida a correta integracao da camada de servico HiveService,
  garantindo persistencia, atualizacao, leitura e eliminacao de dados em boxes Hive.
  Foco em robustez, regressao e consistencia dos principais metodos.

  Abrangencia:
    - CRUD de utilizadores
    - Persistencia e leitura de niveis de jogo
    - Consistencia dos dados entre sessoes

  Pre-requisitos:
    - Execucao isolada via hive_test
    - Adapters registados/importados
    - Dependencias: hive_test, flutter_test, hive_flutter

  Notas:
    - Cada teste comeca com base de dados limpa
    - Testes orientados para robustez
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import '../../../lib/services/hive_service.dart';
import '../../../lib/models/user_model.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    await HiveService.init();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('HiveService Integration', () {
    test('Adiciona e le utilizadores', () async {
      final user = UserModel(
        name: "Alice",
        schoolLevel: "1 ciclo",
        knownLetters: [],
      );
      await HiveService.addUser(user);

      final users = HiveService.getUsers();
      expect(users.length, 1);
      expect(users.first.name, "Alice");
    });

    test('Atualiza utilizador por chave', () async {
      final user = UserModel(
        name: "Bob",
        schoolLevel: "1 ciclo",
        knownLetters: [],
      );
      await HiveService.addUser(user);

      final updated = UserModel(
        name: "Roberto",
        schoolLevel: "2 ciclo",
        knownLetters: [],
      );
      await HiveService.updateUserByKey(0, updated);

      final users = HiveService.getUsers();
      expect(users.length, 1);
      expect(users.first.name, "Roberto");
      expect(users.first.schoolLevel, "2 ciclo");
    });

    test('Elimina utilizador', () async {
      final user = UserModel(
        name: "ToRemove",
        schoolLevel: "1 ciclo",
        knownLetters: [],
      );
      await HiveService.addUser(user);

      await HiveService.deleteUser(0);

      final users = HiveService.getUsers();
      expect(users.isEmpty, true);
    });

    test('Persiste e le nivel do jogo', () async {
      await HiveService.saveGameLevel(
        userKey: "user1",
        gameName: "jogoA",
        level: 3,
      );
      final level = await HiveService.getGameLevel(
        userKey: "user1",
        gameName: "jogoA",
      );
      expect(level, 3);
    });

    test('Recupera utilizador inexistente devolve null', () {
      final user = HiveService.getUser(12345); // Key que nao existe
      expect(user, isNull);
    });
  });
}
