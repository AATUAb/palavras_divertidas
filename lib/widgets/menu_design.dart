import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../themes/colors.dart';

final AudioPlayer globalMenuPlayer = AudioPlayer();
bool globalSoundStarted = false;
bool globalSoundPaused = false;
bool isMenuMuted = false;

Future<void> pauseMenuMusic() async {
  await globalMenuPlayer.pause();
  globalSoundPaused = true;
}

Future<void> resumeMenuMusic() async {
  if (!isMenuMuted && globalSoundPaused) {
    await globalMenuPlayer.resume();
    globalSoundPaused = false;
  }
}

class MenuDesign extends StatefulWidget {
  final Widget child; // Conteúdo principal do ecrã
  final String? headerText; // Texto adicional abaixo do título principal
  final String? titleText; // Texto principal (ex: Mundo das Palavras)
  final Widget? topLeftWidget; // Widget customizado no topo esquerdo
  final bool showHomeButton; // Mostra botão de voltar ao menu de jogos
  final VoidCallback? onHomePressed; // Callback ao clicar no botão home
  final bool showSun; // Oculta o sol decorativo do cabeçalho
  final bool showTopWave; // Mostra ou oculta a curva verde
  final Widget? background; // Fundo opcional (imagem, gradiente, etc.)
  final bool showCloseButton; // Mostra botão de fechar a app
  final bool showTutorial; // Mostra botão de tutorial
  final bool showMuteButton; // Mostra botão de som
  final bool showWhiteBackground; // Mostra fundo branco por trás de tudo

  const MenuDesign({
    Key? key,
    required this.child,
    this.headerText,
    this.titleText,
    this.topLeftWidget,
    this.onHomePressed,
    this.background,
    this.showHomeButton = true,
    this.showSun = true,
    this.showTopWave = true,
    this.showCloseButton = true,
    this.showTutorial = true,
    this.showMuteButton = true,
    this.showWhiteBackground = true,
  }) : super(key: key);

  @override
  State<MenuDesign> createState() => _MenuDesignState();
}

class _MenuDesignState extends State<MenuDesign> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAudio();
  }

  Future<void> _initAudio() async {
    await globalMenuPlayer.setReleaseMode(ReleaseMode.loop);
    if (!isMenuMuted && !globalSoundStarted) {
      await globalMenuPlayer.play(AssetSource('sounds/intro_music.mp3'));
      globalSoundStarted = true;
      globalSoundPaused = false;
    }
  }

  Future<void> _toggleMute() async {
    setState(() => isMenuMuted = !isMenuMuted);
    if (isMenuMuted) {
      await globalMenuPlayer.pause();
      globalSoundPaused = true;
    } else {
      await globalMenuPlayer.resume();
      globalSoundPaused = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      globalMenuPlayer.pause();
    } else if (state == AppLifecycleState.resumed && !isMenuMuted) {
      globalMenuPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.showWhiteBackground)
          Positioned.fill(child: Container(color: Colors.white)),

        if (widget.background != null) widget.background!,

        if (widget.showTopWave)
          const Positioned(top: 0, left: 0, right: 0, child: TopWave()),

        if (widget.showSun)
          Positioned(
            top: -50.h,
            left: 12.w,
            child: Image.asset(
              'assets/images/sun.png',
              width: 300.w,
              height: 300.h,
              fit: BoxFit.contain,
            ),
          ),

        if (widget.titleText != null)
          Positioned(
            top: 8.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  widget.titleText!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 40.sp,
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(offset: Offset(1, 1), blurRadius: 1),
                    ],
                  ),
                ),
                if (widget.headerText != null) ...[
                  SizedBox(height: 45.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      widget.headerText!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

        if (widget.topLeftWidget != null)
          Positioned(top: 10.h, left: 10.w, child: widget.topLeftWidget!),

        if (widget.showHomeButton)
          Positioned(
            top: 10.h,
            left: 10.w,
            child: IconButton(
              icon: Icon(Icons.home, size: 30.sp),
              tooltip: 'Voltar ao Menu de Jogos',
              onPressed: widget.onHomePressed,
            ),
          ),

        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: widget.child,
          ),
        ),

        if (widget.showCloseButton)
          Positioned(
            top: 10.h,
            right: 10.w,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.red,
                size: 30.sp,
              ),
              tooltip: 'Fechar App',
              onPressed: () => SystemNavigator.pop(),
            ),
          ),

        if (widget.showTutorial)
          Positioned(
            bottom: 10.h,
            left: 10.w,
            child: IconButton(
              icon: Icon(Icons.info_outline, size: 25.sp),
              tooltip: 'Tutorial',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Tutorial em breve",
                      style: TextStyle(fontSize: 14.sp, color: AppColors.white),
                    ),
                    backgroundColor: AppColors.green,
                  ),
                );
              },
            ),
          ),

        if (widget.showMuteButton)
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: IconButton(
              icon: Icon(
                isMenuMuted ? Icons.volume_off : Icons.volume_up,
                size: 30.sp,
              ),
              tooltip: isMenuMuted ? 'Ativar som' : 'Silenciar',
              onPressed: _toggleMute,
            ),
          ),
      ],
    );
  }
}

class TopWave extends StatelessWidget {
  const TopWave({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      width: double.infinity,
      child: CustomPaint(painter: CloudPainter()),
    );
  }
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;
    final path = Path();

    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height,
      size.width * 0.25,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height,
      size.width * 0.75,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
