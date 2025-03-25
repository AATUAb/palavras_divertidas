// Tema visual geral da aplicação (cores, fontes, etc).


import 'package:flutter/material.dart';
import 'colors.dart';            // Arquivo com as cores definidas para o app
import 'text_styles.dart';      // Arquivo com os estilos de texto do app

// Classe estática que define o tema da aplicação
class AppTheme {
  // Getter para retornar o tema claro (light theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Usa o Material 3 (nova versão de design do Flutter)

      // Define o esquema de cores baseado em uma cor "seed"
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,       // Cor base para gerar o esquema
        primary: AppColors.green,         // Cor primária
        secondary: AppColors.orange,      // Cor secundária
        tertiary: AppColors.yellow,       // Cor terciária
        background: AppColors.lightBlue,  // Cor de fundo
      ),

      // Cor de fundo padrão dos scaffolds (telas)
      scaffoldBackgroundColor: AppColors.lightBlue,

      // Define a fonte padrão para o app
      fontFamily: AppTextStyles.fontFamily,

      // Estilo padrão para AppBars (barra superior das telas)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.green, // Cor de fundo
        foregroundColor: AppColors.white, // Cor dos ícones/texto
        centerTitle: true,                // Centraliza o título
        titleTextStyle: AppTextStyles.title.copyWith(color: AppColors.white),
        elevation: 0,                     // Sem sombra
      ),

      // Estilo padrão para ElevatedButtons (botões elevados)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,         // Cor de fundo
          foregroundColor: AppColors.white,          // Cor do texto
          textStyle: AppTextStyles.button,           // Estilo do texto
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),          // Espaçamento interno
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Cantos arredondados
          ),
        ),
      ),

      // Estilo padrão para TextButtons (botões de texto)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkBlue,       // Cor do texto
          textStyle: AppTextStyles.button,           // Estilo do texto
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),           // Espaçamento
        ),
      ),

      // Estilo padrão para InputFields (campos de texto)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,                  // Cor de fundo do campo
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey), // Borda padrão
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.green), // Quando habilitado
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.orange, width: 2), // Quando focado
        ),
        labelStyle: AppTextStyles.label,              // Estilo da label
        hintStyle: AppTextStyles.label.copyWith(color: AppColors.grey), // Estilo do placeholder
      ),

      // Estilo padrão para Cards
      cardTheme: CardTheme(
        color: AppColors.white,                       // Cor de fundo do card
        elevation: 3,                                 // Sombra
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),    // Cantos arredondados
        ),
      ),

      // Estilo padrão para ícones
      iconTheme: IconThemeData(
        color: AppColors.orange, // Cor padrão dos ícones
        size: 24,                // Tamanho padrão
      ),

      // Estilo padrão para diálogos (popups)
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightBlue, // Cor de fundo
        elevation: 5,                         // Sombra
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Cantos arredondados
        ),
        titleTextStyle: AppTextStyles.subtitle, // Estilo do título
        contentTextStyle: AppTextStyles.body,   // Estilo do conteúdo
      ),
    );
  }
}
