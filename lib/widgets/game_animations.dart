import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class GameAnimations {
  /// Mostra som + ícone de resposta certa ou errada
  static Future<void> playAnswerFeedback({required bool isCorrect}) async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/${isCorrect ? 'correct' : 'wrong'}.wav'));
    // Adicionando um pequeno atraso para garantir que o som seja reproduzido
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  /// Toca o som de resposta correta
  static Future<void> playCorrectSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/correct.wav'));
  }
  
  /// Toca o som de resposta errada
  static Future<void> playWrongSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/wrong.wav'));
  }

  static Widget correctAnswerIcon() => const Icon(Icons.check, color: Colors.green, size: 30);
  static Widget wrongAnswerIcon() => const Icon(Icons.close, color: Colors.red, size: 30);

  /// Animação de sucesso com confetes
  static Widget coffetiesTimed({VoidCallback? onFinished}) {
    return _TimedAnimationWidget(
      animationPath: 'assets/animations/coffeties.json',
      duration: const Duration(seconds: 2),
      width: 640.w,
      height: 640.h,
      onFinished: onFinished,
    );
  }

  /// Animação de estrela por nível
  static Widget starByLevel({
    required int level,
    VoidCallback? onFinished,
  }) {
    String path;
    switch (level) {
      case 1:
        path = 'assets/animations/one_star.json';
        break;
      case 2:
        path = 'assets/animations/two_star.json';
        break;
      case 3:
      default:
        path = 'assets/animations/tree_star.json';
    }

    return _TimedAnimationWidget(
      animationPath: path,
      duration: const Duration(seconds: 3),
      width: 350.w,
      height: 200.h,
      sound: 'level_up.wav',
      onFinished: onFinished,
    );
  }

  /// Mensagem personalizada por subida ou descida de nível
  static String levelMessage({required int level, required bool increased}) {
    return increased
        ? 'Parabéns! Subiste de nível'
        : 'Vamos praticar melhor o nível $level';
        
  }

  /// Animação de conquista com som e frase
  static Future<void> showConquestDialog(
    BuildContext context, {
    VoidCallback? onFinished,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TimedAnimationWidget(
              animationPath: 'assets/animations/conquest.json',
              duration: const Duration(seconds: 3),
              width: 684.w,
              height: 250.h,
              sound: 'conquest.wav',
              onFinished: onFinished,
            ),
            Text(
              'Boa! Ganhaste um autocolante para a caderneta!',
              style: TextStyle(
                fontSize: 20.sp,
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

  /// Mostra snackbar de tempo esgotado
  static void showTimeoutSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tempo esgotado! ⏰',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Info de topo com barra de progresso e texto
  static Widget buildTopInfo({
    required double progressValue,
    required int level,
    required int currentRound,
    required int totalRounds,
    required Widget topTextWidget,
  }) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: topTextWidget,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8.h,
                    backgroundColor: Colors.grey[300],
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 20.h,
          right: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Nível $level',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'Ronda $currentRound de $totalRounds',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Método genérico para ser usado pelo SuperWidget
  static Future<void> _playSound(String fileName) async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/$fileName'));
  }
}

class _TimedAnimationWidget extends StatefulWidget {
  final String animationPath;
  final Duration duration;
  final double width;
  final double height;
  final String? sound;
  final VoidCallback? onFinished;

  const _TimedAnimationWidget({
    required this.animationPath,
    required this.duration,
    required this.width,
    required this.height,
    this.sound,
    this.onFinished,
  });

  @override
  State<_TimedAnimationWidget> createState() => _TimedAnimationWidgetState();
}

class _TimedAnimationWidgetState extends State<_TimedAnimationWidget> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    if (widget.sound != null) {
      final player = AudioPlayer();
      player.play(AssetSource('sounds/${widget.sound!}'));
    }
    Timer(widget.duration, () {
      if (mounted) {
        setState(() => _visible = false);
        widget.onFinished?.call();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _visible
        ? Lottie.asset(
            widget.animationPath,
            width: widget.width,
            height: widget.height,
            repeat: false,
          )
        : const SizedBox.shrink();
  }
}
