import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../models/character_model.dart';
import '../models/word_model.dart'
    show WordModel, WordModelAdapter, populateWordsIfNeeded, words;

class HiveService {
  // Boxes principais
  static late Box<UserModel> _userBox;
  static late Box<CharacterModel> _characterBox;
  static late Box<WordModel> _wordBox;
  static late Box<dynamic> _progressBox;

  static final Logger logger = Logger();

  /// Inicializa Hive, regista adapters e abre as boxes necessárias.
  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CharacterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WordModelAdapter());
    }

    try {
      _userBox = await Hive.openBox<UserModel>('users');
      logger.i("✅ Box 'users' opened successfully");

      _characterBox = await Hive.openBox<CharacterModel>('characters');
      logger.i("✅ Box 'characters' opened successfully");

      _wordBox = await Hive.openBox<WordModel>('words');
      logger.i("✅ Box 'words' opened successfully");

      // Abre a box de níveis/progresso só uma vez
      _progressBox = await Hive.openBox('userBox');
      logger.i("✅ Box 'userBox' opened successfully");

      logger.i('✅ Hive inicializado com sucesso.');
    } catch (e) {
      logger.e('❌ Erro ao abrir boxes Hive: $e');
      rethrow;
    }

    await populateCharactersIfNeeded();
    await populateWordsIfNeeded(words);
  }

  /// Lê todos os utilizadores
  static List<UserModel> getUsers() {
    if (!Hive.isBoxOpen('users')) {
      logger.e('❌ Hive box "users" not opened!');
      return [];
    }
    final users = _userBox.values.toList();
    logger.i("🔍 Retrieved ${users.length} users from Hive");
    return users;
  }

  /// Adiciona um novo utilizador
  static Future<void> addUser(UserModel user) async {
    await _userBox.add(user);
    logger.i("✅ User ${user.name} added successfully");
  }

  /// Atualiza utilizador por chave
  static Future<void> updateUserByKey(int key, UserModel updatedUser) async {
    await _userBox.put(key, updatedUser);
    logger.i("✅ User with key $key updated successfully");
  }

  /// Elimina utilizador por posição
  static Future<void> deleteUser(int index) async {
    await _userBox.deleteAt(index);
    logger.i("🗑️ User at index $index deleted successfully");
  }

  /// Obtém um utilizador específico
  static UserModel? getUser(int userKey) {
    final user = _userBox.get(userKey);
    if (user == null) {
      logger.e("❌ No user found with key $userKey");
    }
    return user;
  }

  /// Lê o nível de um jogo específico (usa a box já aberta)
  static Future<int> getGameLevel({
    required String userKey,
    required String gameName,
  }) async {
    final levelKey = '${userKey}_${gameName}_level';
    return (_progressBox.get(levelKey, defaultValue: 1) as int);
  }

  /// Salva o nível de um jogo específico (usa a box já aberta)
  static Future<void> saveGameLevel({
    required String userKey,
    required String gameName,
    required int level,
  }) async {
    final levelKey = '${userKey}_${gameName}_level';
    await _progressBox.put(levelKey, level);
    logger.i("💾 Saved level $level for $gameName");
  }

  /// Atualiza a precisão do jogo, fundindo no array existente
  static Future<void> updateGameAccuracy({
    required int userKey,
    required String gameName,
    required List<int> accuracyPerLevel,
    int? levelOverride,
  }) async {
    final user = _userBox.get(userKey);
    if (user == null) {
      logger.w("⚠️ User not found with key $userKey for updating accuracy");
      return;
    }

    final idx = (levelOverride ?? user.gameLevel) - 1;
    if (idx < 0 || idx > 2) {
      logger.w("⚠️ Nível inválido ${idx + 1} para gameName=$gameName");
      return;
    }

    // Clona o array atual ou cria novo
    final existing = List<int>.from(user.gamesAccuracy[gameName] ?? [0, 0, 0]);
    existing[idx] = accuracyPerLevel.isNotEmpty ? accuracyPerLevel.first : 0;

    final mutableMap = Map<String, List<int>>.from(user.gamesAccuracy)
      ..[gameName] = existing;
    user.gamesAccuracy = mutableMap;

    await updateUserByKey(userKey, user);

    logger.i(
      "🎯 Updated accuracy for $gameName, nível ${idx + 1}: ${existing[idx]}%",
    );
  }
}
