import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../widgets/games_animations.dart';

class LevelManager {
  int level;
  int totalRounds = 0;
  int firstTryCorrect = 0;
  final UserModel user;

  final int maxLevel;
  final int minLevel;
  final int roundsToEvaluate;

  LevelManager({
    required this.user,
    this.level = 1,
    this.maxLevel = 3,
    this.minLevel = 1,
    this.roundsToEvaluate = 7,
  });

  void registerRound({required bool firstTry}) {
    totalRounds++;
    if (firstTry) firstTryCorrect++;

    // Calcula a taxa de acerto atual (com qualquer número de rondas)
    double accuracy = firstTryCorrect / totalRounds;

    // Grava sempre a taxa de acerto no nível atual
    user.updateAccuracy(level: level, accuracy: accuracy);
    HiveService.updateUser(user.key as int, user);

    // Só muda de nível se tiver rondas suficientes
    if (totalRounds >= roundsToEvaluate) {
      if (accuracy >= 0.8 && level < maxLevel) {
        level++;
      } else if (accuracy < 0.5 && level > minLevel) {
        level--;
      }

      // Reinicia a contagem após avaliação
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
