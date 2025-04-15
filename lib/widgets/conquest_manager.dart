// Estrutura para gestão da caderneta de conquistas e feedback visual no decurso dos jogos
import 'package:flutter/material.dart';
import 'game_animations.dart';
import '../services/hive_service.dart';

class ConquestManager {
  int conquest;
  int totalRounds = 0;
  int streakFirstTry = 0;
  int correctButNotFirstTry = 0;

  ConquestManager({this.conquest = 0});

  bool hasNewConquest = false;

  void registerRound({required bool firstTry}) {
    hasNewConquest = false; // reset antes da verificação

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

    totalRounds++;
  }

  Future<bool> registerRoundForConquest({
    required BuildContext context,
    required bool firstTry,
    required VoidCallback applySettings,
    required int userKey,
  }) async {
    final int oldConquest = conquest;

    registerRound(firstTry: firstTry);

    await HiveService.incrementTryStats(
      userKey: userKey,
      firstTry: firstTry,
    );

    if (conquest > oldConquest) {
      await HiveService.incrementConquests(userKey);

      await GameAnimations.showConquestDialog(
        context,
        onFinished: () {},
      );

      return true;
    } else {
      applySettings();
      return false;
    }
  }
}
