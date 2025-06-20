/// Testes de integração - HiveService
///
/// Valida integração dos métodos principais da camada HiveService:
///   - CRUD de utilizadores
///   - Persistência de nível de jogo
///   - Recuperação de utilizador inexistente
///
/// Cada teste corre sobre base de dados limpa (hive_test).

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import '../../../lib/services/hive_service.dart';
import '../../../lib/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock do path_provider
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

  group('HiveService Integration', () {
    test('Adiciona e le utilizador', () async {
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

    test('Atualiza utilizador existente por chave', () async {
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

    test('Elimina utilizador existente', () async {
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

    test('Persiste e le nivel de jogo por utilizador', () async {
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
      final user = HiveService.getUser(12345);
      expect(user, isNull);
    });
  });
}
