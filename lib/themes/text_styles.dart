// Estilos de texto reutilizáveis na interface da aplicação

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Fonte principal: Comic Sans MS
  static const String fontFamily = 'Comic Sans MS';
  
  // Estilos de texto para títulos
  static TextStyle title = GoogleFonts.comicNeue(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  
  static TextStyle subtitle = GoogleFonts.comicNeue(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  
  // Estilos para texto de corpo
  static TextStyle body = GoogleFonts.comicNeue(
    fontSize: 16,
    color: AppColors.black,
  );
  
  static TextStyle bodyBold = GoogleFonts.comicNeue(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  
  // Estilos para botões
  static TextStyle button = GoogleFonts.comicNeue(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  
  // Estilos para labels
  static TextStyle label = GoogleFonts.comicNeue(
    fontSize: 14,
    color: AppColors.black,
  );
  
  // Estilos para texto pequeno
  static TextStyle small = GoogleFonts.comicNeue(
    fontSize: 12,
    color: AppColors.grey,
  );
  
  // Estilos coloridos
  static TextStyle greenText = GoogleFonts.comicNeue(
    fontSize: 16,
    color: AppColors.green,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle orangeText = GoogleFonts.comicNeue(
    fontSize: 16,
    color: AppColors.orange,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle yellowText = GoogleFonts.comicNeue(
    fontSize: 16,
    color: AppColors.yellow,
    fontWeight: FontWeight.w600,
  );
}
