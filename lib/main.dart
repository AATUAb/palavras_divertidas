import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'models/user_model.dart';
import 'services/hive_service.dart';
import 'screens/home_page.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Força a orientação para horizontal
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Inicializa o Hive
  await Hive.initFlutter();

  // Regista o adapter do modelo
  Hive.registerAdapter(UserModelAdapter());

  // Abre a box e inicializa o serviço
  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(960, 540), // Define o tamanho base em landscape, focado em smartphones e tablets Android
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Mundo das Palavras',
          theme: AppTheme.lightTheme,
          home: const MyHomePage(title: 'Mundo das Palavras'),
          debugShowCheckedModeBanner: false,
               );
      },
    );
  }
}
