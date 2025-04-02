import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_page.dart';
import '../themes/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // Espera 3 segundos e navega para home_page
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyHomePage(title: 'Home Page')),
      );
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: SizedBox(
          width: 200.w,
          height: 200.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Lottie.asset(
                'assets/animations/loading.json',
                width: 200.w,
                height: 200.h,
                fit: BoxFit.contain,
              ),
              // Texto colado em baixo, dentro da animação
              Positioned(
                bottom: 4.h,
                left: 0.w,
                right: 0,
                child: Text(
                  'Mundo das Palavras a carregar...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                  ),
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
