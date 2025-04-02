import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../widgets/games_animations.dart';

// Declaração da classe LevelManager
class LevelManager {
  int level;
  int totalRounds = 0;
  int correctAnswers = 0;
  final UserModel user;

  final int maxLevel;
  final int minLevel;
  final int roundsToEvaluate;

  /// Constructor do LevelManager
  // Se receber informação de nível, usa essa informação, senão usa o nível 1
  LevelManager({
    required this.user,
    int? level,
    this.maxLevel = 3,
    this.minLevel = 1,
    this.roundsToEvaluate = 7,
  }) : level = level ?? int.tryParse(user.level) ?? 1;

  // Getters para obter informações sobre o nível e o número de rodadas
  int get totalRoundsCount => totalRounds;
  int get evaluationRounds => roundsToEvaluate;

  // Regista se uma rodada foi correta ou não e atualiza o número total de rodadas e respostas corretas no Hive
  // Se o número total de rodadas for maior ou igual ao número de rodadas para avaliar, verifica a precisão e atualiza o nível do utilizador
  // Se a precisão for maior ou igual a 0.8 e o nível for menor que o nível máximo, aumenta o nível do utilizador
  // Se a precisão for menor que 0.5 e o nível for maior que o nível mínimo, diminui o nível do utilizador
  // Reinicia o número total de rodadas e respostas corretas para 0 e continua a avaliar outras rodadas
  void registerRound({required bool correct}) {
    totalRounds++;
    if (correct) correctAnswers++;

    double accuracy = correctAnswers / totalRounds;

    final int userKey = user.key as int;

    user.updateAccuracy(level: level, accuracy: accuracy);
    HiveService.updateUserByKey(userKey, user);

    // Verifica se deve subir de nível
    if (totalRounds >= roundsToEvaluate * 2 &&
        accuracy >= 0.8 &&
        level < maxLevel) {
      level++;
      user.level = level.toString();
      HiveService.updateUser(userKey, user);
      totalRounds = 0;
      correctAnswers = 0;
    }
    // Verifica se deve descer de nível
    else if (totalRounds >= roundsToEvaluate &&
        accuracy < 0.5 &&
        level > minLevel) {
      level--;
      user.level = level.toString();
      HiveService.updateUser(userKey, user);
      totalRounds = 0;
      correctAnswers = 0;
    }
  }

  // Método para registar uma rodada com feedback visual ao subir ou descer de nível
  // Mostra animação com 1, 2 ou 3 estrelas, consoante o novo nível
  Future<void> registerRoundWithOptionalFeedback({
    required BuildContext context,
    required bool correct,
    required VoidCallback applySettings,
    required VoidCallback onFinished,
  }) async {
    final int previousLevel = level;

    registerRound(correct: correct);

    final int userKey = user.key as int;
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

      user.level = level.toString();
      HiveService.updateUser(userKey, user);
    }

    applySettings();
    onFinished();
  }
}
