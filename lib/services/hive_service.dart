import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../models/character_model.dart';
import '../models/word_model.dart' show WordModel, WordModelAdapter, populateWordsIfNeeded, words;


class HiveService {
  // Boxes principais
  static late Box<UserModel> _userBox;
  static late Box<CharacterModel> _characterBox;
  static late Box<WordModel> _wordBox;

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

  logger.i('✅ Hive inicializado com sucesso.');
} catch (e) {
  logger.e('❌ Erro ao abrir boxes Hive: $e');
  rethrow;
}
    await populateCharactersIfNeeded();
    await populateWordsIfNeeded(words); 
}

  // Função para eliminar utilizadores da box
  static Future<void> deleteUsersBox() async {
    if (Hive.isBoxOpen('users')) {
      await _userBox.clear();
    }
    await Hive.deleteBoxFromDisk('users');
    logger.w("⚠️ Box 'users' foi eliminada do disco.");
  }

  // Função para eliminar os caracteres da box
  static Future<void> deleteCharactersBox() async {
    if (Hive.isBoxOpen('characters')) {
      await _characterBox.clear();
    }
    await Hive.deleteBoxFromDisk('characters');
    logger.w("⚠️ Box 'characters' foi eliminada do disco.");
  }

  // Função para receber os utilizadores da box
  static List<UserModel> getUsers() {
    try {
      if (!Hive.isBoxOpen('users')) {
        throw Exception('Hive box "users" not opened!');
      }
      final users = _userBox.values.toList();
      logger.i("🔍 Retrieved ${users.length} users from Hive");
      return users;
    } catch (e) {
      logger.e("❌ Error retrieving users: $e");
      return [];
    }
  }

  // Função para adicionar utilizadores à box
  static Future<void> addUser(UserModel user) async {
    try {
      await _userBox.add(user);
      logger.i("✅ User ${user.name} added successfully");
    } catch (e) {
      logger.e("❌ Error adding user: $e");
    }
  }

  // Função para atualizar utilizadores na box
  static Future<void> updateUser(int index, UserModel updatedUser) async {
    try {
      await _userBox.put(index, updatedUser);
      logger.i("🔄 User at index $index updated successfully");
    } catch (e) {
      logger.e("❌ Error updating user at index: $e");
    }
  }

  // Função para atualizar utilizadores na box por chave
  static Future<void> updateUserByKey(int key, UserModel updatedUser) async {
    try {
      await _userBox.put(key, updatedUser);
      logger.i("✅ User with key $key updated successfully");
    } catch (e) {
      logger.e("❌ Error updating user by key: $e");
    }
  }

  // Função para eliminar utilizadores da box
  static Future<void> deleteUser(int index) async {
    try {
      await _userBox.deleteAt(index);
      logger.i("🗑️ User at index $index deleted successfully");
    } catch (e) {
      logger.e("❌ Error deleting user: $e");
    }
  }

  // Função para receber um utilizador específico da box
  static UserModel? getUser(int userKey) {
    try {
      final user = _userBox.get(userKey);
      if (user == null) {
        logger.e("❌ No user found with key $userKey");
      }
      return user;
    } catch (e) {
      logger.e("❌ Error retrieving user by key: $e");
      return null;
    }
  }

   // Função para ler o nível de um jogo específico
  static Future<int> getGameLevel({
    required String userKey,
    required String gameName,
  }) async {
    final box = await Hive.openBox('userBox');
    final levelKey = '${userKey}_${gameName}_level';
    return box.get(levelKey, defaultValue: 1);
  }
 
  // Função para salvar o nível de um jogo específico e garantir a sua persistência entre sessões de jogo
  static Future<void> saveGameLevel({
    required String userKey,
    required String gameName,
    required int level,
  }) async {
    final box = await Hive.openBox('userBox');
    final levelKey = '${userKey}_${gameName}_level';
    await box.put(levelKey, level);
  }

  // Função para atualizar a precisão do jogo
  static Future<void> updateGameAccuracy({
    required int userKey,
    required String gameName,
    required List<int> accuracyPerLevel,
    int? levelOverride,
  }) async {
    final user = _userBox.get(userKey);
    if (user != null) {
      final levelToStore = levelOverride ?? user.gameLevel;

    // Atualiza o mapa de acurácia
    final mutableMap = Map<String, List<int>>.from(user.gamesAccuracy);
    mutableMap[gameName] = accuracyPerLevel;
    user.gamesAccuracy = mutableMap;

    await updateUserByKey(userKey, user);

    final accuracy = accuracyPerLevel.isNotEmpty ? accuracyPerLevel.first : 0;
    logger.i(
      "🎯 Updated accuracy for $gameName, nível $levelToStore: $accuracy%",
    );
  } else {
    logger.w("⚠️ User not found with key $userKey for updating accuracy");
  }
}
}