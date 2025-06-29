import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'sound_manager.dart';
import '../themes/colors.dart';
import '../screens/game_menu.dart';
import '../models/user_model.dart';

class GameAnimations {
  static Future<void> playAnswerFeedback({required bool isCorrect}) async {
    final sound = isCorrect ? 'correct.ogg' : 'wrong.ogg';
    await SoundManager.playAnimationSound(sound);
  }

  static Widget showSuccessAnimation({VoidCallback? onFinished}) {
    return _TimedAnimationWidget(
      animationPath: 'assets/animations/coffeties.json',
      duration: const Duration(seconds: 2),
      width: 690.w,
      height: 690.h,
      onFinished: onFinished,
    );
  }

  static Future<void> showLevelChangeDialog(
    BuildContext context, {
    required int level,
    required bool increased,
    VoidCallback? onFinished,
  }) async {
    String animationPath;
    switch (level) {
      case 1:
        animationPath = 'assets/animations/one_star.json';
        break;
      case 2:
        animationPath = 'assets/animations/two_star.json';
        break;
      case 3:
      default:
        animationPath = 'assets/animations/tree_star.json';
    }

    final message = levelMessage(level: level, increased: increased);
    final color = increased ? Colors.orange : Colors.red;

    String? voiceMessage;
    if (increased) {
      if (level == 2) voiceMessage = 'level_up_message_2.ogg';
      if (level == 3) voiceMessage = 'level_up_message_3.ogg';
    } else {
      if (level == 1) voiceMessage = 'level_down_message_1.ogg';
      if (level == 2) voiceMessage = 'level_down_message_2.ogg';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TimedAnimationWidget(
                  animationPath: animationPath,
                  duration: const Duration(seconds: 4),
                  width: 300.w,
                  height: 100.h,
                  sound: voiceMessage,
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
    return increased
        ? 'Parabéns! Subiste para o nível $level.'
        : 'Vamos praticar o nível $level';
  }

  static Future<void> showConquestDialog(
    BuildContext context, {
    VoidCallback? onFinished,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TimedAnimationWidget(
                  animationPath: 'assets/animations/conquest.json',
                  duration: const Duration(seconds: 5),
                  width: 200.w,
                  height: 120.h,
                  sound: 'conquest_message.ogg',
                  onFinished: onFinished,
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'Espetáculo! Ganhaste uma conquista para a caderneta.',
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
    );
  }

  static Future<void> showTimeoutSnackbar(BuildContext context) async {
    await SoundManager.playAnimationSound('time_out.ogg');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⏰ Vamos tentar outro desafio',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Widget correctAnswerIcon() =>
      const Icon(Icons.check, color: Colors.green, size: 30);

  static Widget wrongAnswerIcon() =>
      const Icon(Icons.close, color: Colors.red, size: 30);

  static Future<void> showEndOfGameDialog({
    required BuildContext context,
    required VoidCallback onRestart,
    required UserModel user,
  }) async {
    if (!context.mounted) return;
    await SoundManager.playAnimationSound('end_game_message.ogg');

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            content: SizedBox(
              width: 400,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parabéns, chegaste ao fim do jogo!',
                          style: TextStyle(
                            // color
                            color: Colors.orange,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Queres jogar novamente?',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.normal,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GameMenu(user: user),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: const Text('Não'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onRestart();
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: const Text('Sim'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            //SizedBox(width: 12.w),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 150,
                      maxHeight: 150,
                    ),
                    child: Image.asset(
                      'assets/images/games/end_game.webp',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static Future<OverlayEntry?> showIntro({
    required BuildContext context,
    required String imagePath,
    required String audioFile,
    required VoidCallback onFinished,
    required TextStyle introTextStyle,
  }) async {
    await SoundManager.playIntroGames(audioFile);

    // Insere o OverlayEntry que vai exibir a imagem com animação de rotação+fade
    final overlay = Overlay.of(context);
    if (!context.mounted) return null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder:
          (_) => _IntroAnimationOverlay(
            imagePath: imagePath,
            introTextStyle: introTextStyle,
            onFinished: () {
              if (entry.mounted) entry.remove();
              onFinished();
            },
          ),
    );

    overlay.insert(entry);
    return entry;
  }

  static String getVideoFileName(String fileName) {
    switch (fileName) {
      case 'Contar sílabas':
        return 'count_syllables';
      case 'Identificar letras e números':
        return 'identify_letters_numbers';
      case 'Ouvir e Procurar Imagem':
        return 'listen_look';
      case 'Ouvir e Procurar Palavra':
        return 'identify_words';
      case 'Sílaba perdida':
        return 'lost_syllable';
      case 'Escrever':
        return 'writing_game';
      case 'home_page':
        return 'home_page';
      case 'game_menu_pre':
        return 'game_menu_pre';
      case 'game_menu_first':
        return 'game_menu_first';
      case 'sticker_book':
        return 'sticker_book';
      case 'user_stats':
        return 'user_stats';
      default:
        return 'default_video';
    }
  }

  static Future<OverlayEntry> showTutorialVideo({
    required BuildContext context,
    required String fileName,
    required VoidCallback onFinished,
  }) async {
    SoundManager.stopAll();

    final videoFileName = getVideoFileName(fileName);

    late OverlayEntry overlay;
    overlay = OverlayEntry(
      builder:
          (_) => _TutorialVideoScreen(
            videoPath: 'assets/tutorials/$videoFileName.mp4',
            onFinished: () {
              overlay.remove();
              onFinished();
            },
          ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
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
      SoundManager.playAnimationSound(widget.sound!);
    }
    Timer(widget.duration, () {
      if (mounted) {
        setState(() => _visible = false);
        widget.onFinished?.call();
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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

class _IntroAnimationOverlay extends StatefulWidget {
  final String imagePath;
  final VoidCallback onFinished;
  final TextStyle introTextStyle;

  const _IntroAnimationOverlay({
    required this.imagePath,
    required this.introTextStyle,
    required this.onFinished,
  });

  @override
  State<_IntroAnimationOverlay> createState() => _IntroAnimationOverlayState();
}

class _IntroAnimationOverlayState extends State<_IntroAnimationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;
  bool _animationStarted = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    // Configura o controller para rotação + fade
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Após 3 segundos, inicia a animação de fade+rotate e, ao terminar, dispara onFinished
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _finished) return;
      _animationStarted = true;
      _controller.forward().then((_) {
        if (mounted && !_finished) {
          _finished = true;
          widget.onFinished();
        }
      });
    });
  }

  @override
  void dispose() {
    // Se o usuário sair antes de completar os 3s + 800ms, garante remoção
    if (!_finished) {
      _finished = true;
      widget.onFinished();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Ignorar toques para permitir que o usuário clique nos botões imediatamente
      ignoring: true,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Opacity(
              opacity:
                  _animationStarted
                      ? _fadeAnimation.value
                      : 1.0, 
              child: RotationTransition(
                turns: _rotationAnimation,
                child: child,
              ),
            );
          },
          child: Image.asset(
            widget.imagePath,
            width: 250.w,
            height: 180.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}


class _TutorialVideoScreen extends StatefulWidget {
  final String videoPath;
  final VoidCallback onFinished;

  const _TutorialVideoScreen({
    required this.videoPath,
    required this.onFinished,
  });

  @override
  State<_TutorialVideoScreen> createState() => _TutorialVideoScreenState();
}

class _TutorialVideoScreenState extends State<_TutorialVideoScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _finished = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  _fadeAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  _controller.forward();

  _videoController = VideoPlayerController.asset(widget.videoPath)
    ..initialize().then((_) {
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _videoController.play();
    });

  // 🔁 Detecta fim do vídeo e chama _finishTutorial()
  _videoController.addListener(() {
    final position = _videoController.value.position;
    final duration = _videoController.value.duration;
    final isEnded = position >= duration &&
                    !_videoController.value.isPlaying;

    if (isEnded && !_finished) {
      _finishTutorial();
    }
  });
}

  void _finishTutorial() async {
  if (_finished) return;
  _finished = true;

  await _controller.reverse(); 
  widget.onFinished();
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Material(
    color: Colors.black.withOpacity(0.85),
    child: FadeTransition(
  opacity: _fadeAnimation,
  child: ScaleTransition(
    scale: _scaleAnimation,
    child: SizedBox.expand( 
      child: Stack(
        alignment: Alignment.center,
        children: [
          // vídeo centralizado
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _isInitialized
                  ? VideoPlayer(_videoController)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
            // botão OK visível no canto
              Positioned(
                bottom: 30,
                right: 30,
                child: ElevatedButton(
                  onPressed: () {
                  _videoController.pause();
                    widget.onFinished();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green, 
                    foregroundColor: Colors.white,    
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Ok'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );  
}     
}
