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

//funcão para incrementar as conquistas do utilizador
static Future<void> incrementConquests(int userKey) async {
  try {
    final user = _userBox.get(userKey);
    if (user != null) {
      logger.i("Before increment: ${user.conquest}");
      user.incrementConquest(); // Incrementa as conquistas
      await updateUserByKey(userKey, user); // Atualiza o usuário no Hive
      logger.i("After increment: ${user.conquest}");
    } else {
      logger.e("❌ User not found with key $userKey");
    }
  } catch (e) {
    logger.e("❌ Error updating user's conquest: $e");
  }
}

// Função para recuperar o usuário a partir da chave
static UserModel? getUser(int userKey) {
  try {
    // Recupera o usuário do Hive usando o userKey
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
    // Itera sobre os usuários para encontrar o usuário com o nome especificado
    final user = _userBox.values.firstWhere(
      (user) => user.key == userID,
      orElse: () => throw Exception('User not found')
    );

    // Retorna a chave do usuário
    return user.key as int;
  } catch (e) {
    logger.e("❌ Error retrieving user key for $userID: $e");
    return -1;  // Retorna um valor inválido se não conseguir encontrar o usuário
  }
}

// --- Métodos para contadores específicos de conquistas ---

static Future<void> incrementFirstTrySuccesses(int userKey) async {
  try {
    final user = _userBox.get(userKey);
    if (user != null) {
      user.firstTrySuccesses++;
      await updateUserByKey(userKey, user);
      logger.i("✅ Incremented firstTrySuccesses for user $userKey. New count: ${user.firstTrySuccesses}");
    } else {
      logger.w("⚠️ User not found with key $userKey for incrementing firstTrySuccesses");
    }
  } catch (e) {
    logger.e("❌ Error incrementing firstTrySuccesses for user $userKey: $e");
  }
}

static Future<void> incrementOtherSuccesses(int userKey) async {
  try {
    final user = _userBox.get(userKey);
    if (user != null) {
      user.otherSuccesses++;
      await updateUserByKey(userKey, user);
      logger.i("✅ Incremented otherSuccesses for user $userKey. New count: ${user.otherSuccesses}");
    } else {
      logger.w("⚠️ User not found with key $userKey for incrementing otherSuccesses");
    }
  } catch (e) {
    logger.e("❌ Error incrementing otherSuccesses for user $userKey: $e");
  }
}

static Future<void> resetFirstTrySuccesses(int userKey) async {
  try {
    final user = _userBox.get(userKey);
    if (user != null) {
      user.firstTrySuccesses = 0;
      await updateUserByKey(userKey, user);
      logger.i("✅ Reset firstTrySuccesses for user $userKey.");
    } else {
      logger.w("⚠️ User not found with key $userKey for resetting firstTrySuccesses");
    }
  } catch (e) {
    logger.e("❌ Error resetting firstTrySuccesses for user $userKey: $e");
  }
}

static Future<void> resetOtherSuccesses(int userKey) async {
  try {
    final user = _userBox.get(userKey);
    if (user != null) {
      user.otherSuccesses = 0;
      await updateUserByKey(userKey, user);
      logger.i("✅ Reset otherSuccesses for user $userKey.");
    } else {
      logger.w("⚠️ User not found with key $userKey for resetting otherSuccesses");
    }
  } catch (e) {
    logger.e("❌ Error resetting otherSuccesses for user $userKey: $e");
  }
}
}
