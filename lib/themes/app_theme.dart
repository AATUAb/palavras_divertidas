// Tema visual geral da aplicação (cores, fontes, etc).
import 'package:flutter/material.dart';
import 'colors.dart'; // Arquivo com as cores definidas para o app

// Classe estática que define o tema da aplicação
class AppTheme {
  // Getter para retornar o tema claro (light theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Usa o Material 3
      // Define o esquema de cores baseado em uma cor "seed"
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.green,
        secondary: AppColors.orange,
        tertiary: AppColors.yellow,
        surface: AppColors.lightBlue, // Substituindo 'background' por 'surface'
      ),

      scaffoldBackgroundColor: AppColors.lightBlue,
      fontFamily: 'ComicNeue', // Fonte padrão da app

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.white,
          textStyle: TextStyle(
            fontFamily: 'ComicNeue',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkBlue,
          textStyle: TextStyle(
            fontFamily: 'ComicNeue',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.orange, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkBlue,
        ),
        hintStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: AppColors.grey,
        ),
      ),

      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      iconTheme: IconThemeData(color: AppColors.orange, size: 24),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightBlue,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBlue,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }
}
