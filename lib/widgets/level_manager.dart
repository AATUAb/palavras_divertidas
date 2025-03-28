// Estrutura para gestão de níveis e feedback visual no jogo
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/games_animations.dart';

class LevelManager {
  int level;
  int totalRounds = 0;
  int firstTryCorrect = 0;

  final int maxLevel;
  final int minLevel;
  final int roundsToEvaluate;

  LevelManager({
    this.level = 1,
    this.maxLevel = 3,
    this.minLevel = 1,
    this.roundsToEvaluate = 4,
  });

  void registerRound({required bool firstTry}) {
    totalRounds++;
    if (firstTry) firstTryCorrect++;

    if (totalRounds >= roundsToEvaluate) {
      double accuracy = firstTryCorrect / totalRounds;

      if (accuracy >= 0.8 && level < maxLevel) {
        level++;
      } else if (accuracy < 0.5 && level > minLevel) {
        level--;
      }

      totalRounds = 0;
      firstTryCorrect = 0;
    }
  }

 Future<void> registerRoundWithOptionalFeedback({
  required BuildContext context,
  required bool firstTry,
  required VoidCallback applySettings,
  required VoidCallback onFinished,
}) async {
  final int oldLevel = level;

  registerRound(firstTry: firstTry);

  if (level > oldLevel) {
    print('DEBUG: A subir de nível. A mostrar animação...');

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
            GameAnimations.successProgressionTimed(),
            SizedBox(height: 30.h),
            Text(
              'Parabéns, subiste de nível!',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );  
  }

  applySettings();
  onFinished();
}
}