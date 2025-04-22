import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'services/hive_service.dart';
import 'screens/loading_screen.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ► Bloqueio de orientação (mantido)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ► Inicialização única do Hive + seed de caracteres
  await HiveService.init(); // já faz initFlutter, regista adapters e corre o populateCharactersIfNeeded()

  // ⚠️  Durante desenvolvimento, se continuar a querer limpar a box "users", descomente:
  // await Hive.deleteBoxFromDisk('users');

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
            title: 'Mundo das Palavras',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const LoadingScreen(),
          ),
    );
  }
}
