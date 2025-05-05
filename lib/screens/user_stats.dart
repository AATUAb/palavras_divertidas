import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    Widget buildCustomRadarChart(int levelIndex, double size) {
      final n = allGames.length;
      final center = Offset(size / 2, size / 2);
      final radius = size / 2.3;
      final scores =
          allGames.map((game) {
            final values = user.gamesAccuracy[game] ?? [];
            return values.length >= levelIndex
                ? values[levelIndex - 1].toDouble()
                : 0.0;
          }).toList();

      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: RadarPainter(
                scores: scores,
                center: center,
                radius: radius,
                segments: 4,
                sides: n,
                color: AppColors.orange,
              ),
            ),
            for (var i = 0; i < n; i++)
              Positioned(
                left:
                    center.dx +
                    (radius + 12) * cos(2 * pi * i / n - pi / 2) -
                    10,
                top:
                    center.dy +
                    (radius + 12) * sin(2 * pi * i / n - pi / 2) -
                    10,
                child: Icon(
                  gameIcons[allGames[i]]!,
                  color: AppColors.orange,
                  size: 20.sp,
                ),
              ),
          ],
        ),
      );
    }

    return MenuDesign(
      titleText: 'Mundo das Palavras',
      showHomeButton: true,
      showSun: false,
      onHomePressed:
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GameMenu(user: user)),
          ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final spacing = 100.w;
          final availableWidth = maxWidth - 5 * spacing;
          final radarSize = availableWidth / 2.5;

          return Padding(
            padding: EdgeInsets.only(left: 10.w, top: 60.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Legenda
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      allGames.map((game) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            children: [
                              Icon(
                                gameIcons[game]!,
                                color: AppColors.orange,
                                size: 15.sp,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                game,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.orange,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(width: 0.w),
                // Radares
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (idx) {
                      final lvl = idx + 1;
                      return Column(
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
                          SizedBox(height: 20.h),
                          buildCustomRadarChart(lvl, radarSize),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🎯 CustomPainter para radar chart
class RadarPainter extends CustomPainter {
  final List<double> scores;
  final Offset center;
  final double radius;
  final int segments;
  final int sides;
  final Color color;

  RadarPainter({
    required this.scores,
    required this.center,
    required this.radius,
    required this.segments,
    required this.sides,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid =
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..style = PaintingStyle.stroke;

    final paintRadar =
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    final paintBorder =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw grid
    for (int s = 1; s <= segments; s++) {
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final angle = 2 * pi * i / sides - pi / 2;
        final point = Offset(
          center.dx + radius * s / segments * cos(angle),
          center.dy + radius * s / segments * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paintGrid);
    }

    // Draw radar area
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = 2 * pi * i / sides - pi / 2;
      final value = max(scores[i].clamp(0.0, 1.0), 0.05); // visibilidade mínima
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paintRadar);
    canvas.drawPath(path, paintBorder);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
