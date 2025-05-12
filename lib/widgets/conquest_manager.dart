/*import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class ConquestManager {
  int conquest;
  int totalRounds = 0;
  int streakFirstTry = 0; // Acertos consecutivos na primeira tentativa
  int correctButNotFirstTry = 0; // Acertos não consecutivos

  ConquestManager({this.conquest = 0});

  bool hasNewConquest = false; // Flag que indica se uma nova conquista foi alcançada

  // Função que registra as conquistas com base nas tentativas
  void registerRound({required bool firstTry}) {
    hasNewConquest = false; // Reset antes da verificação

    // Se o acerto foi na primeira tentativa
    if (firstTry) {
      streakFirstTry++;
      if (streakFirstTry >= 5) { // Condição de 5 acertos na primeira tentativa
        conquest++;  // Incrementa o número de conquistas
        hasNewConquest = true;
        streakFirstTry = 0; // Reset após a conquista
      }
    } else {
      streakFirstTry = 0; // Reset de streak de primeira tentativa
      correctButNotFirstTry++;
      if (correctButNotFirstTry >= 10) { // Condição de 10 acertos fora da primeira tentativa
        conquest++;  // Incrementa o número de conquistas
        hasNewConquest = true;
        correctButNotFirstTry = 0; // Reset após a conquista
      }
    }

    totalRounds++; // Incrementa a contagem de rodadas
  }

  // Função que registra uma rodada e verifica se uma nova conquista foi alcançada
  Future<bool> registerRoundForConquest({
    required BuildContext context,
    required bool firstTry,
    required VoidCallback applySettings,
    required int userKey,
  }) async {
    final int oldConquest = conquest;

  // Registra a rodada e verifica as conquistas
  registerRound(firstTry: firstTry);

  // Atualiza as estatísticas no Hive
  await HiveService.incrementTryStats(
    userKey: userKey,
    firstTry: firstTry,
  );

  // Se a conquista foi atualizada, salva no Hive
  if (conquest > oldConquest) {
    await HiveService.incrementConquests(userKey); // Incrementa o contador de conquistas no Hive
    return true;  // Nova conquista foi feita
  } else {
    applySettings(); // Se não houve nova conquista, aplica configurações
    return false;  // Nenhuma conquista nova
  }
}
}*/

import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';

class ConquestManager {
  int conquest;
  int totalRounds = 0;
  int streakFirstTry = 0; // Acertos consecutivos na primeira tentativa
  int correctButNotFirstTry = 0; // Acertos não consecutivos

  ConquestManager({this.conquest = 0});

  bool hasNewConquest = false; // Flag que indica se uma nova conquista foi alcançada

  // Função que registra as conquistas com base nas tentativas
  void registerRound({required bool firstTry, required UserModel user}) {
    hasNewConquest = false; // Reset antes da verificação

    if (firstTry) {
      streakFirstTry++;
      if (streakFirstTry >= 5) {
        conquest++;
        hasNewConquest = true;
        streakFirstTry = 0;
      }
    } else {
      streakFirstTry = 0;
      correctButNotFirstTry++;
      if (correctButNotFirstTry >= 10) {
        conquest++;
        hasNewConquest = true;
        correctButNotFirstTry = 0;
      }
    }
    HiveService.logger.i(
      "📊 Primeira tentativas ➤ ${user.firstTryCorrectTotal + (firstTry ? 1 : 0)}; "
      "Outras tentativas ➤ ${correctButNotFirstTry + (firstTry ? 0 : 1)}"
    );


    totalRounds++;

    // Atualiza diretamente no modelo
    if (firstTry) {
      user.firstTryCorrectTotal++;
    } else {
      user.correctButNotFirstTryTotal++;
    }
  }

  // Registra uma rodada e verifica se uma nova conquista foi alcançada
  Future<bool> registerRoundForConquest({
    required BuildContext context,
    required bool firstTry,
    required Future<void> Function() applySettings,
    required UserModel user,
  }) async {
    final int oldConquest = conquest;

    registerRound(firstTry: firstTry, user: user);

  if (conquest > oldConquest) {
      user.incrementConquest();
      HiveService.logger.i("🏅 Conquista atribuída ➤ valor anterior: $oldConquest ➤ atual: ${user.conquest}");
      await applySettings();
      return true;
    } else {
      await applySettings();
      return false;
    }
  }
}
