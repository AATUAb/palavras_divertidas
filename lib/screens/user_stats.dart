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

    final gameIcons = <String, IconData>{
      'Detetive de letras e números': Icons.search,
      'Escrever': Icons.edit,
      'Contar sílabas': Icons.format_list_numbered,
      'Ouvir e procurar': Icons.hearing,
      'Detetive de palavras': Icons.find_in_page,
      'Sílabas perdidas': Icons.extension,
    };

    Widget buildRadarForLevel(int levelIndex) {
      final n = allGames.length;
      final angleOffset = -pi / 2;

      final entries =
          allGames.map((game) {
            final scores = user.gamesAccuracy[game] ?? [];
            final rawScore =
                scores.length >= levelIndex
                    ? scores[levelIndex - 1] * 100
                    : 0.0;
            return RadarEntry(value: rawScore.clamp(0, 100).toDouble());
          }).toList();

      return SizedBox(
        width: 150.w,
        height: 150.h,
        child: Stack(
          children: [
            RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                isMinValueAtCenter: true,
                tickCount: 3,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                tickBorderData: BorderSide(
                  color: AppColors.grey.withOpacity(0.5),
                ),
                gridBorderData: BorderSide(
                  color: AppColors.grey.withOpacity(0.5),
                ),
                borderData: FlBorderData(show: false),
                getTitle: (_, __) => const RadarChartTitle(text: ''),
                dataSets: [
                  RadarDataSet(
                    dataEntries: entries,
                    borderColor: AppColors.orange,
                    fillColor: AppColors.orange.withOpacity(0.2),
                    entryRadius: 2.sp,
                    borderWidth: 1.5,
                  ),
                ],
              ),
            ),
            // ícones nos vértices
            for (var i = 0; i < n; i++)
              Positioned(
                left:
                    70.w +
                    140.w / 2 * cos(2 * pi * i / n + angleOffset) -
                    10.sp,
                top:
                    70.h +
                    140.h / 2 * sin(2 * pi * i / n + angleOffset) -
                    10.sp,
                child: Icon(
                  gameIcons[allGames[i]]!,
                  size: 20.sp,
                  color: AppColors.orange,
                ),
              ),
          ],
        ),
      );
    }

    return MenuDesign(
      titleText: 'Mundo das Palavras',
      headerText: 'Estatísticas',
      showHomeButton: true,
      showSun: false,
      onHomePressed:
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameMenu(user: user)),
          ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (idx) {
            final lvl = idx + 1;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 80.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nível $lvl',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  buildRadarForLevel(lvl),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
