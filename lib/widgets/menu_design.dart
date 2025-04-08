import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/colors.dart';

class MenuDesign extends StatefulWidget {
  final Widget child;

  const MenuDesign({super.key, required this.child});

  @override
  State<MenuDesign> createState() => _MenuDesignState();
}

class _MenuDesignState extends State<MenuDesign> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _muted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMuteStatus();
    });
  }

  Future<void> _loadMuteStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMuted = prefs.getBool('isMuted') ?? false;

      setState(() {
        _muted = isMuted;
      });

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      if (!_muted) {
        await _audioPlayer.play(AssetSource('sounds/intro_music.mp3'));
      }
    } catch (e) {
      debugPrint('Erro ao carregar estado de mute: $e');
    }
  }

  Future<void> _toggleMute() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _muted = !_muted;
    });
    await prefs.setBool('isMuted', _muted);

    if (_muted) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fundo branco
        Container(color: Colors.white),

        // Nuvem verde no topo
        const Positioned(top: 0, left: 0, right: 0, child: TopWave()),

        // Sol
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

        // Texto "Mundo das Palavras"
        Positioned(
          top: 15.h,
          right: 80.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Mundo das',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 1)],
                ),
              ),
              Text(
                'Palavras',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 1)],
                ),
              ),
            ],
          ),
        ),

        // Conteúdo principal
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: widget.child,
          ),
        ),

        // Botão de Fechar App
        Positioned(
          top: 10.h,
          right: 10.w,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: const BoxDecoration(
                border: Border.fromBorderSide(BorderSide(color: Colors.black)),
                shape: BoxShape.circle,
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

        // Botão de Informação
        Positioned(
          bottom: 10.h,
          left: 10.w,
          child: IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black, size: 28.sp),
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

        // Botão de Mute
        Positioned(
          bottom: 10.h,
          right: 10.w,
          child: IconButton(
            icon: Icon(
              _muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.black,
              size: 28.sp,
            ),
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
