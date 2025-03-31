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
    this.roundsToEvaluate = 7,
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
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(16.w),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Altura adaptada dinamicamente
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: GameAnimations.successProgressionTimed(
                        width: 350.w,
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FittedBox(
                      child: Text(
                        'Parabéns, subiste de nível!',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    }

    applySettings();
    onFinished();
  }
}
