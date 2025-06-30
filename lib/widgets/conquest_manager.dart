import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';

class ConquestManager {
  int conquest;
  int totalRounds = 0;

  // Acertos consecutivos na primeira tentativa
  int streakFirstTry = 0;

  // Todas as tentativas além da primeira com acerto ou erro e reinicia a cada conquista
  int persistenceCount = 0;

  // estatísticas de sessão…
  int sessionFirstTryCount = 0;
  int sessionOtherTryCount = 0;

  ConquestManager({this.conquest = 0});

  bool hasNewConquest = false;

  void reset() {
    totalRounds = 0;
    streakFirstTry = 0;
    persistenceCount = 0;
    sessionFirstTryCount = 0;
    sessionOtherTryCount = 0;
    hasNewConquest = false;
  }

  void registerRound({required bool firstTry, required UserModel user}) {
    hasNewConquest = false;
    totalRounds++;

    // Sessão: contadores “por jogo”
    if (firstTry) {
      sessionFirstTryCount++;
    } else {
      sessionOtherTryCount++;
    }

    // 1) Incrementa o contador correto
    if (firstTry) {
      streakFirstTry++;
      user.firstTryCorrectTotal++;
    } else {
      streakFirstTry = 0;
      persistenceCount++;
      user.persistenceCountTotal++;
    }

    if (firstTry && streakFirstTry == 10) {
      conquest++;
      hasNewConquest = true;
    }

    if (!firstTry && persistenceCount == 15) {
      conquest++;
      hasNewConquest = true;
    }

    // 3) Se conquistou, reseta ambos os contadores
    if (hasNewConquest) {
      streakFirstTry = 0;
      persistenceCount = 0;
      user.incrementConquest();
    }

    HiveService.logger.i(
      "📊 Sessão: 1ªTentativas=$sessionFirstTryCount; "
      "outrasTentativas=$sessionOtherTryCount | "
      "streakFirstTry=$streakFirstTry; "
      "persistenceCount=$persistenceCount",
    );
  }

  Future<bool> registerRoundForConquest({
    required BuildContext context,
    required bool firstTry,
    required Future<void> Function() applySettings,
    required UserModel user,
  }) async {
    final oldConquest = conquest;
    registerRound(firstTry: firstTry, user: user);
    await applySettings();
    // devolve se houve conquista nesta chamada
    return conquest > oldConquest;
  }
}
