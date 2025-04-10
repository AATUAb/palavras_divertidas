// Estrutura para gestão da caderneta de conquistas e feedback visual no decurso dos jogos
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/games_animations.dart';
import '../services/hive_service.dart';

class Conquest {
  int conquest;
  int totalRounds = 0;
  int firstTryCorrect = 0;
  int correctButNotFirstTry = 0;

  Conquest({
    this.conquest = 0,
  });

  void registerRound({required bool firstTry}) {
    totalRounds++;

    if (firstTry) {
      firstTryCorrect++;

      // Entrega 1 autocolante a cada 5 acertos à primeira tentativa
      if (firstTryCorrect >= 5) {
        conquest++;
        firstTryCorrect = 0;
      }
    } else {
      correctButNotFirstTry++;

      // Entrega 1 autocolante a cada 10 acertos que não foram à primeira tentativa
      if (correctButNotFirstTry >= 10) {
        conquest++;
        correctButNotFirstTry = 0;
      }
    }
  }

  Future<void> registerRoundForConquest({
    required BuildContext context,
    required bool firstTry,
    required VoidCallback applySettings,
    required VoidCallback onFinished,
    required int userKey, // Passa o userKey aqui
  }) async {
    final int oldConquest = conquest;

    registerRound(firstTry: firstTry);

    if (conquest > oldConquest) {
      // Exibe animação de conquista
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameAnimations.conquestTimed(),
              SizedBox(height: 30.h),
              Text(
                'Uau! Ganhaste um autocolante para a caderneta',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Atualiza o número de conquistas no modelo do usuário
      HiveService.incrementConquests(userKey); // Agora passando userKey corretamente
    }

    onFinished();
  }
}
