import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../widgets/games_animations.dart';

class LevelManager {
  int level;
  int totalRounds = 0;
  int correctAnswers = 0;
  final UserModel user;

  final int maxLevel;
  final int minLevel;
  final int roundsToEvaluate;

  LevelManager({
    required this.user,
    int? level,
    this.maxLevel = 3,
    this.minLevel = 1,
    this.roundsToEvaluate = 1, // ajusta para 4 na release
  }) : level = level ?? user.gameLevel;

  int get totalRoundsCount => totalRounds;
  int get evaluationRounds => roundsToEvaluate;

  void registerRound({required bool correct}) {
    totalRounds++;
    if (correct) correctAnswers++;

    double accuracy = correctAnswers / totalRounds;
    final int userKey = user.key as int;

    user.updateAccuracy(level: level, accuracy: accuracy);
    HiveService.updateUserByKey(userKey, user);

    if (totalRounds >= roundsToEvaluate * 2 &&
        accuracy >= 0.8 &&
        level < maxLevel) {
      level++;
      user.gameLevel = level;
      HiveService.updateUserByKey(userKey, user);
      totalRounds = 0;
      correctAnswers = 0;
    } else if (totalRounds >= roundsToEvaluate &&
        accuracy < 0.5 &&
        level > minLevel) {
      level--;
      user.gameLevel = level;
      HiveService.updateUserByKey(userKey, user);
      totalRounds = 0;
      correctAnswers = 0;
    }
  }

  Future<void> registerRoundWithOptionalFeedback({
    required BuildContext context,
    required bool correct,
    required VoidCallback applySettings,
    required VoidCallback onFinished,
  }) async {
    final int previousLevel = level;

    registerRound(correct: correct);

    final bool subiuNivel = level > previousLevel;
    final bool desceuNivel = level < previousLevel;

    if (subiuNivel || desceuNivel) {
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
                      child: GameAnimations.starByLevel(
                        level: level,
                        width: 350.w,
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FittedBox(
                      child: Text(
                        subiuNivel
                            ? 'Parabéns! Subiste para o nível $level!'
                            : 'Vamos treinar melhor o nível $level!',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: subiuNivel ? Colors.orange : Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      user.gameLevel = level;
      HiveService.updateUserByKey(user.key as int, user);
    }

    applySettings();
    onFinished();
  }
}
