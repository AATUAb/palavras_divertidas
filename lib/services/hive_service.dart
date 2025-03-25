// Serviço de gestão de dados locais utilizando a base de dados Hive.

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

// Serviço que encapsula todas as interações com o Hive para o modelo UserModel
class HiveService {
  // Referência à box do Hive que armazena utilizadores
  static late Box<UserModel> _userBox;

  // Inicializa o Hive e abre a box de utilizadores
  static Future<void> init() async {
    // Registra o adaptador do modelo, se ainda não estiver registrado
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    try {
      // Tenta abrir a box de utilizadores
      _userBox = await Hive.openBox<UserModel>('users');
      print("Hive box 'users' opened successfully");
    } catch (e) {
      // Em caso de erro, tenta reabrir a box
      print("Error opening Hive box: $e");

      _userBox = await Hive.openBox<UserModel>('users');
      print("Hive box 'users' reopened after error");
    }
  }

  // Retorna todos os utilizadores armazenados na box
  static List<UserModel> getUsers() {
    try {
      if (!_userBox.isOpen) {
        print("Box is not open, trying to reopen...");
        Hive.openBox<UserModel>('users');
      }
      final users = _userBox.values.toList();
      print("Retrieved ${users.length} users from Hive");
      return users;
    } catch (e) {
      print("Error getting users: $e");
      return [];
    }
  }

  // Adiciona um novo utilizador à box
  static Future<void> addUser(UserModel user) async {
    try {
      if (!_userBox.isOpen) {
        print("Box is not open when adding user, trying to reopen...");
        await Hive.openBox<UserModel>('users');
      }
      await _userBox.add(user);
      print("User ${user.name} added successfully");
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  // Atualiza um utilizador existente com base no índice
  static Future<void> updateUser(int index, UserModel updatedUser) async {
    try {
      if (!_userBox.isOpen) {
        print("Box is not open when updating user, trying to reopen...");
        await Hive.openBox<UserModel>('users');
      }
      await _userBox.putAt(index, updatedUser);
      print("User at index $index updated successfully");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // Remove um utilizador com base no índice
  static Future<void> deleteUser(int index) async {
    try {
      if (!_userBox.isOpen) {
        print("Box is not open when deleting user, trying to reopen...");
        await Hive.openBox<UserModel>('users');
      }
      await _userBox.deleteAt(index);
      print("User at index $index deleted successfully");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
