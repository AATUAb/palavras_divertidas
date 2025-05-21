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
              'Identificar letras e números',
              'Escrever',
              'Contar sílabas',
              'Ouvir e Procurar Imagem',
              'Detetive de palavras',
              'Sílabas perdidas',
            ]
            : [
              'Identificar letras e números',
              'Escrever',
              'Contar sílabas',
              'Ouvir e Procurar Imagem',
            ];

    final gameIcons = <String, IconData>{
      'Identificar letras e números': Icons.search,
      'Escrever': Icons.edit,
      'Contar sílabas': Icons.format_list_numbered,
      'Ouvir e Procurar Imagem': Icons.hearing,
      'Detetive de palavras': Icons.find_in_page,
      'Sílabas perdidas': Icons.extension,
    };

    Widget buildCustomRadarChart(int levelIndex, double size) {
      final n = allGames.length;
      final center = Offset(size / 2, size / 2);
      final radius = size / 2.3;

      final scores =
          allGames.map((game) {
            // obtém lista real ou vazia
            final raw = user.gamesAccuracy[game] ?? <int>[];
            // converte para percentagens 0.0–1.0
            final percents = raw.map((i) => i / 100).toList();
            // se não existir aquele nível, usa 0.0
            return levelIndex <= percents.length
                ? percents[levelIndex - 1]
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
                // Legenda com percentagens reais
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      allGames.map((game) {
                        // lista real ou vazia
                        final raw = user.gamesAccuracy[game] ?? <int>[];
                        // garante sempre 3 valores
                        final ints = <int>[
                          raw.isNotEmpty ? raw[0] : 0,
                          raw.length > 1 ? raw[1] : 0,
                          raw.length > 2 ? raw[2] : 0,
                        ];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              SizedBox(height: 3.h),
                              Padding(
                                padding: EdgeInsets.only(left: 25.w),
                                child: Text(
                                  'Nível 1: ${ints[0]}%; '
                                  'Nível 2: ${ints[1]}%; '
                                  'Nível 3: ${ints[2]}%',
                                  style: TextStyle(
                                    fontSize: 6.sp,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),

                SizedBox(width: 0.w),

                // Radares para cada nível
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

/// Desenha o radar — ficou igual à tua implementação original
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
    final textStyle = TextStyle(color: Colors.grey[600], fontSize: 5);

    // grade
    for (int s = 1; s <= segments; s++) {
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final angle = 2 * pi * i / sides - pi / 2;
        final point = Offset(
          center.dx + radius * s / segments * cos(angle),
          center.dy + radius * s / segments * sin(angle),
        );
        if (i == 0)
          path.moveTo(point.dx, point.dy);
        else
          path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, paintGrid);

      // rótulo
      final labelOffset = Offset(
        center.dx - 12,
        center.dy - radius * s / segments - 3,
      );
      final tp = TextPainter(
        text: TextSpan(text: '${s * 25}%', style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, labelOffset);
    }

    // área
    final path = Path();
    final points = <Offset>[];
    for (int i = 0; i < sides; i++) {
      final angle = 2 * pi * i / sides - pi / 2;
      final value = max(scores[i].clamp(0.0, 1.0), 0.05);
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );
      if (i == 0)
        path.moveTo(point.dx, point.dy);
      else
        path.lineTo(point.dx, point.dy);
      points.add(point);
    }
    path.close();
    canvas.drawPath(path, paintRadar);
    canvas.drawPath(path, paintBorder);

    // círculos
    final centerCircle =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, centerCircle);
    for (final p in points) canvas.drawCircle(p, 2, centerCircle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
