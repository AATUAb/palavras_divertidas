import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

// classe para animações e sons do jogo
class GameAnimations {
  static Future<void> playAnswerFeedback({required bool isCorrect}) async {
    final sound = isCorrect ? 'correct.wav' : 'wrong.wav';
    await _playSound(sound);
  }

// animação de sucesso
  static Widget showSuccessAnimation({
    VoidCallback? onFinished,
  }) {
    return _TimedAnimationWidget(
      animationPath: 'assets/animations/coffeties.json',
      duration: const Duration(seconds: 2),
      width: 690.w,
      height: 690.h,
      onFinished: onFinished,
    );
  }

// animação de nível, com animação, som e mensasagem ajustada a subida ou descida de nível
static Future<void> showLevelChangeDialog(
  BuildContext context, {
  required int level,
  required bool increased,
  VoidCallback? onFinished,
}) async {
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
  final message = levelMessage(level: level, increased: increased);
  final color = increased ? Colors.orange : Colors.red;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimedAnimationWidget(
            animationPath: path,
            duration: const Duration(seconds: 3),
            width: 300.w,
            height: 100.h,
            sound: 'level_up.wav',
            onFinished: onFinished,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
  static String levelMessage({required int level, required bool increased}) {
    if (increased) {
      return 'Parabéns! Subiste para o nível $level!';
    } else {
      return 'Vamos particar melhor o nível $level!';
    }
  }

// animação de conquista, com animação, som e mensasagem
static Future<void> showConquestDialog(
  BuildContext context, {
  VoidCallback? onFinished,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TimedAnimationWidget(
              animationPath: 'assets/animations/conquest.json',
              duration: const Duration(seconds: 3),
              width: 200.w,
              height: 120.h,
              sound: 'conquest.wav',
              onFinished: onFinished,
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Uau! Ganhaste uma conquista para a caderneta!',
                style: TextStyle(
                  fontSize: 25.sp,
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

// animação de tempo esgotado, com barra ingerior com mensagem
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

  // animação para tocar som de resposta correta ou errada
  static Future<void> _playSound(String fileName) async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/animations/$fileName'));
  }

  // animação de ícone de resposta correta ou errada
  static Widget correctAnswerIcon() =>
      const Icon(Icons.check, color: Colors.green, size: 30);
  static Widget wrongAnswerIcon() =>
      const Icon(Icons.close, color: Colors.red, size: 30);
}

// classe para animação temporizada
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
          fit: BoxFit.contain,
          repeat: false,
        )
        : const SizedBox.shrink();
  }
}

// classe para animação de resposta correta ou errada
class AnimatedAnswerItem extends StatefulWidget {
  final Widget child;
  final bool isCorrect;
  final VoidCallback? onRemoved;

  const AnimatedAnswerItem({
    super.key,
    required this.child,
    required this.isCorrect,
    this.onRemoved,
  });

  @override
  State<AnimatedAnswerItem> createState() => _AnimatedAnswerItemState();
}

// classe para animação de resposta correta ou errada
class _AnimatedAnswerItemState extends State<AnimatedAnswerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  bool _showCheckIcon = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.isCorrect) {
      GameAnimations._playSound('correct.wav');
      setState(() => _showCheckIcon = true);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (widget.onRemoved != null) widget.onRemoved!();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.isCorrect ? 0 : _offsetAnimation.value, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!_showCheckIcon) widget.child,
              if (_showCheckIcon)
                Icon(Icons.check_circle, color: Colors.green, size: 32.sp),
            ],
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedAnswerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCorrect && !_showCheckIcon) {
      setState(() => _showCheckIcon = true);
    }
  }
}
