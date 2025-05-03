import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/hive_service.dart';
import 'screens/loading_screen.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ► Bloqueio de orientação
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ► Inicialização básica do Hive
  await Hive.initFlutter();

  // ⚠️ Apagar box antes de qualquer abertura (durante desenvolvimento)
  // await Hive.deleteBoxFromDisk('users');

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
            title: 'Mundo das Palavras',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const LoadingScreen(),
          ),
    );
  }
}
