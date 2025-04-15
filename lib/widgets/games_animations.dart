import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class GameAnimations {
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
      sound: 'correct.wav',
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
    final message = level > 1 ? 'Parabéns! Subiste de nível!' : 'Vamos praticar melhor o nível $level!';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TimedAnimationWidget(
          animationPath: path,
          duration: const Duration(seconds: 3),
          width: width ?? 350.w,
          height: height ?? 200.h,
          sound: 'level_up.wav',
          onFinished: onFinished,
        ),
        SizedBox(height: 16.h),
        Text(
          message,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: level > 1 ? Colors.orange : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

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
            SizedBox(height: 16.h),
            Text(
              'Uau! Ganhaste uma conquista para a caderneta!',
              style: TextStyle(
                fontSize: 22.sp,
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

  static Future<void> _playSound(String fileName) async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/$fileName'));
  }

  static Widget correctAnswerIcon() => const Icon(Icons.check, color: Colors.green, size: 30);
  static Widget wrongAnswerIcon() => const Icon(Icons.close, color: Colors.red, size: 30);
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
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32.sp,
                ),
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