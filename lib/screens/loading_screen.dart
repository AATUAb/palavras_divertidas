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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/loading.json',
              width: 180.w,
              height: 180.h,
              repeat: true,
            ),
              SizedBox(height: 20.h),
              Text('Mundo das Palavras a carregar...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
