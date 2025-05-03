import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';
import 'game_menu.dart';

class UserStats extends StatelessWidget {
  final UserModel user;
  const UserStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isFirstCycle = user.schoolLevel == '1º Ciclo';
    final allGames =
        isFirstCycle
            ? [
              'Detetive de letras e números',
              'Escrever',
              'Contar sílabas',
              'Ouvir e procurar',
              'Detetive de palavras',
              'Sílabas perdidas',
            ]
            : [
              'Detetive de letras e números',
              'Escrever',
              'Contar sílabas',
              'Ouvir e procurar',
            ];

    // 1) Mapa de ícones por jogo
    final gameIcons = <String, IconData>{
      'Detetive de letras e números': Icons.search,
      'Escrever': Icons.edit,
      'Contar sílabas': Icons.format_list_numbered,
      'Ouvir e procurar': Icons.hearing,
      'Detetive de palavras': Icons.find_in_page,
      'Sílabas perdidas': Icons.extension,
    };

    // 2) Percentagens [0..100] vindas de gamesAccuracy (o primeiro valor da lista)
    final percents = <String, double>{
      for (var game in allGames)
        game: (user.gamesAccuracy[game]?.first ?? 0.0) * 100,
    };

    // 3) Entradas para o radar
    final radarEntries =
        percents.values
            .map((v) => RadarEntry(value: v.clamp(0.0, 100.0)))
            .toList();
    final gameNames = percents.keys.toList();

    return MenuDesign(
      titleText: 'Mundo das Palavras',
      headerText: 'Estatísticas',
      showHomeButton: true,
      showSun: true,
      onHomePressed:
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameMenu(user: user)),
          ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            SizedBox(height: 50.h), // para descer abaixo do cabeçalho

            Expanded(
              child: AspectRatio(
                aspectRatio: 1.1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    final center = Offset(size.width / 2, size.height / 2);
                    final xRadius = size.width * 0.45;
                    final yRadius = size.height * 0.45;
                    final n = gameNames.length;
                    final angleOffset = -pi / 2;

                    return Stack(
                      children: [
                        // A) RadarChart sem labels nem pontos internos
                        RadarChart(
                          RadarChartData(
                            radarShape: RadarShape.polygon,
                            getTitle: (_, __) => RadarChartTitle(text: ''),
                            dataSets: [
                              RadarDataSet(
                                dataEntries: radarEntries,
                                borderColor: AppColors.orange,
                                fillColor: AppColors.orange.withOpacity(0.3),
                                entryRadius: 0,
                                borderWidth: 2,
                              ),
                            ],
                            tickCount: 3,
                            ticksTextStyle: const TextStyle(
                              color: Colors.transparent,
                              fontSize: 0,
                            ),
                            tickBorderData: BorderSide(color: AppColors.grey),
                            gridBorderData: BorderSide(
                              color: AppColors.grey.withOpacity(0.4),
                            ),
                          ),
                        ),

                        // B) Círculo no ponto proporcional à percentagem
                        for (var i = 0; i < n; i++)
                          Positioned(
                            left:
                                center.dx +
                                xRadius *
                                    cos(2 * pi * i / n + angleOffset) *
                                    (percents[gameNames[i]]! / 100) -
                                6.sp,
                            top:
                                center.dy +
                                yRadius *
                                    sin(2 * pi * i / n + angleOffset) *
                                    (percents[gameNames[i]]! / 100) -
                                6.sp,
                            child: Container(
                              width: 12.sp,
                              height: 12.sp,
                              decoration: const BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                        // C) Ícone fixo no vértice (100%)
                        for (var i = 0; i < n; i++)
                          Positioned(
                            left:
                                center.dx +
                                xRadius * cos(2 * pi * i / n + angleOffset) -
                                12.sp,
                            top:
                                center.dy +
                                yRadius * sin(2 * pi * i / n + angleOffset) -
                                12.sp,
                            child: Icon(
                              gameIcons[gameNames[i]] ?? Icons.help_outline,
                              size: 24.sp,
                              color: AppColors.orange,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
