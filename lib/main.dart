import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/hive_service.dart';
import 'screens/loading_screen.dart';
import 'themes/app_theme.dart';

// 1️⃣ Importa o modelo (que inclui o adapter gerado)
import 'models/character_model.dart';
import 'models/user_model.dart';
import 'models/word_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ► Bloqueio de orientação
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ► Fullscreen total
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ► Inicialização básica do Hive
  await Hive.initFlutter();

  // ─────────── Registo de Adapters ───────────
  Hive.registerAdapter(CharacterModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(WordModelAdapter());
  // ──────────────────────────────────────────────

  // ► Agora inicializa com adapters e seed
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(960, 540),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (_, __) => MaterialApp(
            title: 'Palavras Divertidas',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const LoadingScreen(),
          ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/hive_service.dart';
import 'screens/loading_screen.dart';
import 'themes/app_theme.dart';

// 1️⃣ Importa o modelo (que inclui o adapter gerado)
import 'models/character_model.dart';
import 'models/user_model.dart';
import 'models/word_model.dart';

import 'package:video_player/video_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ► Bloqueio de orientação
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

    // ► Fullscreen total
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ► Inicialização básica do Hive
  await Hive.initFlutter();

  // ─────────── Registro de Adapters ───────────
  Hive.registerAdapter(CharacterModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(WordModelAdapter()); 
  // ──────────────────────────────────────────────

  // ► Agora inicializa com adapters e seed
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(960, 540),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (_, __) => MaterialApp(
            title: 'Palavras Divertidas',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const VideoTestScreen(),
          ),
    );
  }
}

class VideoTestScreen extends StatefulWidget {
  const VideoTestScreen({super.key});

  @override
  State<VideoTestScreen> createState() => _VideoTestScreenState();
}

class _VideoTestScreenState extends State<VideoTestScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/tutorials/count_syllables_fixed.mp4');
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.play();
      _controller.setLooping(false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}*/
