import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveService {
  static late Box<UserModel> _userBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    try {
      _userBox = await Hive.openBox<UserModel>('users');
      print("✅ Box 'users' aberta com sucesso");
    } catch (e) {
      print("❌ Erro ao abrir a box: $e");
      rethrow;
    }
  }

  static List<UserModel> getUsers() {
    try {
      if (!Hive.isBoxOpen('users')) {
        throw Exception('Hive box "users" not opened!');
      }

      final users = _userBox.values.toList();
      print("🔍 Retrieved ${users.length} users from Hive");
      return users;
    } catch (e) {
      print("❌ Error getting users: $e");
      return [];
    }
  }

  static Future<void> addUser(UserModel user) async {
    try {
      await _userBox.add(user);
      print("User ${user.name} added successfully");
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  static Future<void> updateUser(int index, UserModel updatedUser) async {
    try {
      await _userBox.putAt(index, updatedUser);
      print("User at index $index updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  static Future<void> deleteUser(int index) async {
    try {
      await _userBox.deleteAt(index);
      print("User at index $index deleted successfully");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
