import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../themes/colors.dart';

/// Player global (não mexer aqui) …
final AudioPlayer globalMenuPlayer = AudioPlayer();
bool globalSoundStarted = false;
bool globalSoundPaused = false;
bool isMenuMuted = false;

Future<void> pauseMenuMusic() async {
  /* … */
}
Future<void> resumeMenuMusic() async {
  /* … */
}

class MenuDesign extends StatefulWidget {
  final Widget child;
  final String? headerText;
  final Widget? topLeftWidget;
  final bool showHomeButton;
  final VoidCallback? onHomePressed;
  final bool hideSun;

  /// permite receber um background “por baixo” da curva verde
  final Widget? background;

  const MenuDesign({
    Key? key,
    required this.child,
    this.headerText,
    this.topLeftWidget,
    this.showHomeButton = false,
    this.onHomePressed,
    this.hideSun = false,
    this.background,
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
        // 0️⃣ fundo branco
        Container(color: Colors.white),

        // 1️⃣ background opcional (ex: mapa-mundo)
        if (widget.background != null) widget.background!,

        // 2️⃣ a curva verde
        const Positioned(top: 0, left: 0, right: 0, child: TopWave()),

        // 3️⃣ Sol atrás do header
        if (!widget.hideSun)
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

        // Título principal e texto secundário
        Positioned(
          top: 8.h,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Mundo das Palavras',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 40.sp,
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 1)],
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

        // Top left widget (pode ser um ícone custom)
        if (widget.topLeftWidget != null)
          Positioned(top: 10.h, left: 10.w, child: widget.topLeftWidget!),

        // Botão home
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

        // 4️⃣ Conteúdo principal, abaixo da curva
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: widget.child,
          ),
        ),

        // Botão fechar app
        Positioned(
          top: 10.h,
          right: 10.w,
          child: IconButton(
            icon: Icon(Icons.close_rounded, color: AppColors.red, size: 30.sp),
            tooltip: 'Fechar App',
            onPressed: () => SystemNavigator.pop(),
          ),
        ),

        // Botão tutorial
        Positioned(
          bottom: 10.h,
          left: 10.w,
          child: IconButton(
            icon: Icon(Icons.info_outline, size: 25.sp),
            tooltip: 'Tutorial',
            onPressed:
                () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Tutorial em breve",
                      style: TextStyle(fontSize: 14.sp, color: AppColors.white),
                    ),
                    backgroundColor: AppColors.green,
                  ),
                ),
          ),
        ),

        // Botão mute
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
