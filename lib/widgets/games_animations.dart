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

  return _TimedAnimationWidget(
    animationPath: path,
    duration: const Duration(seconds: 3),
    width: width ?? 350.w,
    height: height ?? 200.h,
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


// widget para continuar a exibir todas as animações, por um determinado tempo
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
        // Fecha o diálogo automaticamente após a animação
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
