import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameAnimations {
  /// Animação de sucesso, exibida durante 3 segundos
  static Widget successCoffetiesTimed({
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
  /// Animação de progressão de nível, exibida por 3 segundos
  static Widget successProgressionTimed({
    double? width,
    double? height,
    VoidCallback? onFinished,
  }) {
    return _TimedAnimationWidget(
      animationPath: 'assets/animations/progression_stars.json',
      duration: const Duration(seconds: 3),
      width: width ?? 684.w,
      height: height ?? 250.h,
      onFinished: onFinished,
    );
  }

  /// Animação de conquistas acumuladas, exibida durante 5 segundos
  static Widget successConquestTimed({
    double? width,
    double? height,
    VoidCallback? onFinished,
  }) {
    return _TimedAnimationWidget(
      animationPath: 'assets/animations/conquist.json',
      duration: const Duration(seconds: 5),
      width: width ?? 684.w,
      height: height ?? 250.h,
      onFinished: onFinished,
    );
  }

}


//widget para continar a exibir a todas as animações, por um determinado tempo
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
        // Adiciona esta linha para fechar o diálogo
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
