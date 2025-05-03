import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/user_model.dart';
import '../themes/colors.dart';
import '../widgets/menu_design.dart';

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

    // Calcula percentagens (0 se nunca jogado)
    final percents = <String, double>{
      for (var game in allGames)
        game: () {
          final attempts = user.totalAttemptsPerGame[game] ?? 0;
          final correct = user.totalCorrectPerGame[game] ?? 0;
          return attempts > 0 ? (correct / attempts) * 100 : 0.0;
        }(),
    };

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
      onHomePressed: () => Navigator.pop(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            // Indicadores globais
            Wrap(
              spacing: 30.w,
              runSpacing: 16.h,
              alignment: WrapAlignment.center,
              children: [
                _buildStatCard(
                  'Taxa Global',
                  '${(user.overallAccuracy ?? 0).toStringAsFixed(1)}%',
                ),
                _buildStatCard('Conquistas', '${user.conquest}'),
                _buildStatCard('1ª Tentativa', '${user.firstTryCorrectTotal}'),
                _buildStatCard(
                  'Outras Tentativas',
                  '${user.correctButNotFirstTryTotal}',
                ),
              ],
            ),
            SizedBox(height: 40.h),

            // RadarChart + ícones sobrepostos
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    final center = Offset(size.width / 2, size.height / 2);
                    // Raios independentes para X e Y
                    final xRadius = size.width * 0.45;
                    final yRadius = size.height * 0.45;
                    final n = gameNames.length;
                    final angleOffset = -pi / 2; // iniciar no topo

                    return Stack(
                      children: [
                        // 1) O RadarChart sem títulos internos
                        RadarChart(
                          RadarChartData(
                            radarShape: RadarShape.polygon,
                            getTitle: (_, __) => RadarChartTitle(text: ''),
                            dataSets: [
                              RadarDataSet(
                                dataEntries: radarEntries,
                                borderColor: AppColors.orange,
                                fillColor: AppColors.orange.withOpacity(0.3),
                                entryRadius: 3.sp,
                                borderWidth: 2,
                              ),
                            ],
                            tickCount: 4,
                            ticksTextStyle: TextStyle(
                              color: AppColors.grey,
                              fontSize: 10.sp,
                            ),
                            tickBorderData: BorderSide(color: AppColors.grey),
                            gridBorderData: BorderSide(
                              color: AppColors.grey.withOpacity(0.4),
                            ),
                          ),
                        ),

                        // 2) Ícones posicionados nos vértices com xRadius/yRadius
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

  Widget _buildStatCard(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.orange,
          ),
        ),
        SizedBox(height: 4.h),
        Text(title, style: TextStyle(fontSize: 14.sp, color: AppColors.grey)),
      ],
    );
  }
}
