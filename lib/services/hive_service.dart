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
<<<<<<< HEAD
        "🔍 Recuperado ${users.length} usuários do Hive",
      ); // Usando logger para log de sucesso
      return users;
    } catch (e) {
      logger.e("❌ Erro ao obter usuários: $e"); // Usando logger para erro
=======
        "🔍 Retrieved ${users.length} users from Hive",
      ); // Usando logger para log de sucesso
      return users;
    } catch (e) {
      logger.e("❌ Error getting users: $e"); // Usando logger para erro
>>>>>>> d5d6dd8 (Corrigidos erros de depreciação com 'withOpacity' e atualizações no código)
      return [];
    }
  }

  static Future<void> addUser(UserModel user) async {
    try {
      await _userBox.add(user);
      logger.i(
<<<<<<< HEAD
        "Usuário ${user.name} adicionado com sucesso",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Erro ao adicionar usuário: $e"); // Usando logger para erro
=======
        "User ${user.name} added successfully",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Error adding user: $e"); // Usando logger para erro
>>>>>>> d5d6dd8 (Corrigidos erros de depreciação com 'withOpacity' e atualizações no código)
    }
  }

  static Future<void> updateUser(int index, UserModel updatedUser) async {
    try {
      await _userBox.putAt(index, updatedUser);
      logger.i(
<<<<<<< HEAD
        "Usuário no índice $index atualizado com sucesso",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Erro ao atualizar usuário: $e"); // Usando logger para erro
=======
        "User at index $index updated successfully",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Error updating user: $e"); // Usando logger para erro
>>>>>>> d5d6dd8 (Corrigidos erros de depreciação com 'withOpacity' e atualizações no código)
    }
  }

  static Future<void> deleteUser(int index) async {
    try {
      await _userBox.deleteAt(index);
      logger.i(
<<<<<<< HEAD
        "Usuário no índice $index excluído com sucesso",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Erro ao excluir usuário: $e"); // Usando logger para erro
=======
        "User at index $index deleted successfully",
      ); // Usando logger para sucesso
    } catch (e) {
      logger.e("Error deleting user: $e"); // Usando logger para erro
>>>>>>> d5d6dd8 (Corrigidos erros de depreciação com 'withOpacity' e atualizações no código)
    }
  }
}
