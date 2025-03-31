import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';

class HiveService {
  static late Box<UserModel> _userBox;
  static var logger = Logger(); // Criação de uma instância do Logger

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    try {
      _userBox = await Hive.openBox<UserModel>('users');
      logger.i(
        "✅ Box 'users' aberta com sucesso",
      ); // Usando logger em vez de print
    } catch (e) {
      logger.e("❌ Erro ao abrir a box: $e"); // Usando logger para erro
      rethrow;
    }
  }

  static List<UserModel> getUsers() {
    try {
      if (!Hive.isBoxOpen('users')) {
        throw Exception('Hive box "users" not opened!');
      }

      final users = _userBox.values.toList();
      logger.i(
        "🔍 Retrieved ${users.length} users from Hive",
      ); // Usando logger para log de sucesso
      return users;
    } catch (e) {
      logger.e("❌ Error getting users: $e"); // Usando logger para erro
      return [];
    }
  }

  static Future<void> addUser(UserModel user) async {
    try {
      await _userBox.add(user);
      logger.i(
        "User ${user.name} added successfully",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Error adding user: $e"); // Usando logger para erro
    }
  }

  static Future<void> updateUser(int index, UserModel updatedUser) async {
    try {
      await _userBox.putAt(index, updatedUser);
      logger.i(
        "User at index $index updated successfully",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Error updating user: $e"); // Usando logger para erro
    }
  }

  static Future<void> deleteUser(int index) async {
    try {
      await _userBox.deleteAt(index);
      logger.i(
        "User at index $index deleted successfully",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Error deleting user: $e"); // Usando logger para erro
    }
  }
}
