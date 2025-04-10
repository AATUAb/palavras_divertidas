import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/colors.dart';

class MenuDesign extends StatefulWidget {
  final Widget child;
  final String? headerText;
  final Widget? topLeftWidget;

  const MenuDesign({
    super.key,
    required this.child,
    this.headerText,
    this.topLeftWidget,
  });

  @override
  State<MenuDesign> createState() => _MenuDesignState();
}

class _MenuDesignState extends State<MenuDesign> with WidgetsBindingObserver {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _soundStarted = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAudio();
  }

  Future<void> _initAudio() async {
    final prefs = await SharedPreferences.getInstance();
    final isMuted = prefs.getBool('isMuted') ?? false;

    setState(() => _muted = isMuted);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    if (!_muted && !_soundStarted) {
      await _audioPlayer.play(AssetSource('sounds/intro_music.mp3'));
      _soundStarted = true;
    }
  }

  Future<void> _toggleMute() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _muted = !_muted);
    await prefs.setBool('isMuted', _muted);

    _muted ? await _audioPlayer.pause() : await _audioPlayer.resume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed && !_muted) {
      _audioPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      final isMuted = prefs.getBool('isMuted') ?? false;
      if (isMuted != _muted) {
        setState(() => _muted = isMuted);
      }
    });

    return Stack(
      children: [
        Container(color: Colors.white),
        const Positioned(top: 0, left: 0, right: 0, child: TopWave()),

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

        // Título e header
        Positioned(
          top: 8.h,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Mundo das Palavras',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
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
                    style: TextStyle(
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

        // Novo: ícones superiores (ex: só usados no GameMenu)
        if (widget.topLeftWidget != null)
          Positioned(top: 10.h, left: 10.w, child: widget.topLeftWidget!),

        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: widget.child,
          ),
        ),

        Positioned(
          top: 10.h,
          right: 10.w,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: 30.sp,
              height: 30.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.red,
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Fechar App',
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ),
          ),
        ),

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
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),

        Positioned(
          bottom: 10.h,
          right: 10.w,
          child: IconButton(
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, size: 30.sp),
            tooltip: _muted ? 'Ativar som' : 'Silenciar',
            onPressed: _toggleMute,
          ),
        ),
      ],
    );
  }
}

class TopWave extends StatelessWidget {
  const TopWave({super.key});

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
