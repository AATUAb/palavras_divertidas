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

// Função para incrementar a quantidade de conquistas de um usuário.
static Future<void> incrementConquests(int userKey) async {
  try {
    final user = _userBox.get(userKey);
    if (user != null) {
      user.incrementConquest(); // Incrementa as conquistas
      await _userBox.put(userKey, user); // Atualiza o usuário no Hive
      logger.i("✅ User's conquest updated successfully");
    }
  } catch (e) {
    logger.e("❌ Error updating user's conquest: $e");
  }
}

  // Função para obter a chave do usuário
static int getUserKey() {
  try {
    // A chave pode ser uma chave numérica ou única que é usada ao acessar o usuário
    final userKey = _userBox.keyAt(0); // Pega a chave do primeiro usuário (ou modifique conforme necessário)
    return userKey as int;
  } catch (e) {
    logger.e("❌ Error retrieving user key: $e");
    return -1;  // Retorna um valor inválido se não conseguir pegar a chave
  }
}
}