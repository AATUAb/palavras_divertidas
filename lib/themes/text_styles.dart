// Estilos de texto reutilizáveis na interface da aplicação

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class AppTextStyles {
  // Fonte principal usada na aplicação
  static const String fontFamily = 'ComicNeue';

  // Estilos de texto para títulos
  static final title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static final subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // Estilos para texto de corpo
  static final body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    color: AppColors.black,
  );

  static final bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  // Estilos para botões
  static final button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Estilos para labels
  static final label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    color: AppColors.black,
  );

  // Estilos para texto pequeno
  static final small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    color: AppColors.grey,
  );

  // Estilos coloridos
  static final greenText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    color: AppColors.green,
    fontWeight: FontWeight.w600,
  );

  static final orangeText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    color: AppColors.orange,
    fontWeight: FontWeight.w600,
  );

  static final yellowText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    color: AppColors.yellow,
    fontWeight: FontWeight.w600,
  );
}
