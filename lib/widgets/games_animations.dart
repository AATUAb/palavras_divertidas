import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class GameAnimations {
  /// Animação de coffeties, exibida durante 3 segundos, apenas em jogos com várias rodadas antes do acerto final
  /// Toca o som de resposta correta
  static Future<void> playCorrectSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/correct.wav'));
  }

  /// Icone de resposta individual correcta
  static Widget correctAnswerIcon() {
    return const Icon(Icons.check, color: Colors.green, size: 30);
  }

  /// Toca o som de resposta errada
  static Future<void> playWrongSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/wrong.wav'));
  }

  /// Icone de resposta individual errada
  static Widget wrongAnswerIcon() {
    return const Icon(Icons.close, color: Colors.red, size: 30);
  }

  /// Toca o som de conquista
  static Future<void> playConquestSound() async {
    await _playSound('conquest.wav');
  }

  /// Informação de tempo esgotado, exibida durante 400 milissegundos
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

  /// Mostra a barra de progresso + nível e ronda
  static Widget buildTopInfo({
    required double progressValue,
    required int level,
    required int currentRound,
    required int totalRounds,
  }) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 0.h),
            child: Column(
              children: [
                Padding(
                  // posição da barra de tempo
                  padding: EdgeInsets.only(
                    top: 275.w,
                    right: 20.w,
                    left: 850.w,
                  ),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 5.h,
                    backgroundColor: Colors.grey[300],
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Animação de coffeties, exibida durante 3 segundos, apenas em jogos com vários itens para selecionar
  // aprenta a animação ao selecinar todos os itens corretos da jogada
  static Widget coffetiesTimed({
    double? width,
    double? height,
    VoidCallback? onFinished,
  }) {
    return _TimedAnimationWidget(
      animationPath: 'assets/animations/coffeties.json',
      duration: const Duration(seconds: 3),
      width: width ?? 640.w,
      height: height ?? 640.h,
      onFinished: onFinished,
    );
  }

  // Animação de estrelas, para mostrar ajustes de níveis,exibida durante 3 segundos, com som de level up
  static Widget starByLevel({
    required int level,
    double? width,
    double? height,
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
    _playSound('level_up.wav');
    return _TimedAnimationWidget(
      animationPath: path,
      duration: const Duration(seconds: 3),
      width: width ?? 350.w,
      height: height ?? 200.h,
      onFinished: onFinished,
    );
  }

  // Animação de conquistas acumuladas, exibida durante 3 segundos
  static Widget conquestTimed({
    double? width,
    double? height,
    VoidCallback? onFinished,
  }) {
    _playSound('conquest.wav');
    return _TimedAnimationWidget(
      animationPath: 'assets/animations/conquest.json',
      duration: const Duration(seconds: 3),
      width: width ?? 684.w,
      height: height ?? 250.h,
      onFinished: onFinished,
    );
  }

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
  final VoidCallback? onFinished;

  const _TimedAnimationWidget({
    required this.animationPath,
    required this.duration,
    required this.width,
    required this.height,
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

/// Widget para animar a resposta dada num jogo (correta ou errada)
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

    _offsetAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_controller);

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
