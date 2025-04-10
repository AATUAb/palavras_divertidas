// Estrutura para gestão da caderneta de conquistas e feedback visual no decurso dos jogos
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/games_animations.dart';
import '../services/hive_service.dart';

class ConquestManager {
  int conquest;
  int totalRounds = 0;
  int firstTryCorrect = 0;
  int correctButNotFirstTry = 0;

  ConquestManager({this.conquest = 0});

  void registerRound({required bool firstTry}) {
    totalRounds++;

    if (firstTry) {
      firstTryCorrect++;
      if (firstTryCorrect >= 5) {
        conquest++;
        firstTryCorrect = 0;
      }
    } else {
      correctButNotFirstTry++;
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
  required int userKey,
}) async {
  final int oldConquest = conquest;

  registerRound(firstTry: firstTry);

  if (conquest > oldConquest) {
    await HiveService.incrementConquests(userKey);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
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
                child: GameAnimations.conquestTimed(),
              ),
              SizedBox(height: 20.h),
              FittedBox(
                child: Text(
                  'Uau! Ganhaste uma conquista para a caderneta!',
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
