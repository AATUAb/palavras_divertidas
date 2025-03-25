// Cartão visual para apresentar cada jogo no menu.

import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../themes/text_styles.dart';

/// Widget visual que representa um card de jogo no menu
class GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const GameCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone circular
              Material(
                elevation: 4,
                shape: CircleBorder(),
                color: backgroundColor ?? AppColors.orange,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    icon,
                    size: 36,
                    color: iconColor ?? AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Título do jogo
              Text(
                title,
                style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para exibir uma grade de jogos
class GamesGrid extends StatelessWidget {
  final List<GameCardData> games;
  final int crossAxisCount;
  final double spacing;

  const GamesGrid({
    super.key,
    required this.games,
    this.crossAxisCount = 3,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.8,
      ),
      itemCount: games.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          title: game.title,
          icon: game.icon,
          onTap: game.onTap,
          backgroundColor: game.backgroundColor,
          iconColor: game.iconColor,
        );
      },
    );
  }
}

// Classe para armazenar dados do jogo
class GameCardData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  GameCardData({
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });
}
