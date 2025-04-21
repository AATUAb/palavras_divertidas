import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';

class HiveService {
  static late Box<UserModel> _userBox;
  static var logger = Logger();

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    try {
      _userBox = await Hive.openBox<UserModel>('users');
      logger.i("✅ Box 'users' opened successfully");
    } catch (e) {
      logger.e("❌ Error opening box: $e");
      rethrow;
    }
  }

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

  static Future<void> addUser(UserModel user) async {
    try {
      await _userBox.add(user);
      logger.i("✅ User ${user.name} added successfully");
    } catch (e) {
      logger.e("❌ Error adding user: $e");
    }
  }

  static Future<void> updateUser(int index, UserModel updatedUser) async {
    try {
      await _userBox.putAt(index, updatedUser);
      logger.i("🔄 User at index $index updated successfully");
    } catch (e) {
      logger.e("❌ Error updating user at index: $e");
    }
  }

  static Future<void> updateUserByKey(int key, UserModel updatedUser) async {
    try {
      await _userBox.put(key, updatedUser);
      logger.i("✅ User with key $key updated successfully");
    } catch (e) {
      logger.e("❌ Error updating user by key: $e");
    }
  }

  static Future<void> deleteUser(int index) async {
    try {
      await _userBox.deleteAt(index);
      logger.i("🗑️ User at index $index deleted successfully");
    } catch (e) {
      logger.e("❌ Error deleting user: $e");
    }
  }

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

  static int getUserKey(int userID) {
    try {
      final user = _userBox.values.firstWhere(
        (user) => user.key == userID,
        orElse: () => throw Exception('User not found'),
      );
      return user.key as int;
    } catch (e) {
      logger.e("❌ Error retrieving user key for $userID: $e");
      return -1;
    }
  }

  // Conquistas
  static Future<void> incrementConquests(int userKey) async {
    try {
      final user = _userBox.get(userKey);
      if (user != null) {
        user.incrementConquest();
        await updateUserByKey(userKey, user);
        logger.i("After increment: ${user.conquest}");
      } else {
        logger.e("❌ User not found with key $userKey");
      }
    } catch (e) {
      logger.e("❌ Error updating user's conquest: $e");
    }
  }

  static Future<void> incrementTryStats({
    required int userKey,
    required bool firstTry,
  }) async {
    try {
      final user = _userBox.get(userKey);
      if (user != null) {
        if (firstTry) {
          user.firstTryCorrectTotal++;
        } else {
          user.correctButNotFirstTryTotal++;
        }

        await updateUserByKey(userKey, user);

        logger.i(
          "📊 Atualizado stats para user $userKey ➤ "
          "Primeira tentativa: ${user.firstTryCorrectTotal}, "
          "Outras tentativas: ${user.correctButNotFirstTryTotal}",
        );
      } else {
        logger.w(
          "⚠️ Utilizador com chave $userKey não encontrado para atualizar estatísticas de tentativa.",
        );
      }
    } catch (e) {
      logger.e(
        "❌ Erro ao atualizar estatísticas de tentativa para user $userKey: $e",
      );
    }
  }

  // Taxa de acerto por jogo (corrigido!)
  static Future<void> updateGameAccuracy({
    required int userKey,
    required String gameName,
    required List<double> accuracyPerLevel,
  }) async {
    final user = _userBox.get(userKey);
    if (user != null) {
      final mutableMap = Map<String, List<double>>.from(user.gamesAccuracy);
      mutableMap[gameName] = accuracyPerLevel;
      user.gamesAccuracy = mutableMap;

      await updateUserByKey(userKey, user);

      final accuracy =
          accuracyPerLevel.isNotEmpty ? accuracyPerLevel.first : 0.0;
      logger.i(
        "🎯 Updated accuracy for $gameName, nível ${user.gameLevel}: ${(accuracy * 100).toStringAsFixed(1)}%",
      );
    } else {
      logger.w("⚠️ User not found with key $userKey for updating accuracy");
    }
  }
}
