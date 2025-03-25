// Menu lateral personalizado usado na navegação da aplicação.

import 'package:flutter/material.dart';
import '../themes/colors.dart';        // Arquivo com as cores do tema
import '../themes/text_styles.dart';  // Estilos de texto utilizados

// Widget estático que representa um Drawer personalizado
class CustomDrawer extends StatelessWidget {
  // Informações recebidas por parâmetro: nome, nível e funções para ações
  final String userName;
  final String userLevel;
  final VoidCallback onManageUsers;     // Ação ao tocar em "Utilizadores"
  final VoidCallback onAchievements;    // Ação ao tocar em "Conquistas"
  final VoidCallback onDashboard;       // Ação ao tocar em "Dashboard"

  // Construtor com parametros obrigatórios
  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userLevel,
    required this.onManageUsers,
    required this.onAchievements,
    required this.onDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.lightGrey, // Cor de fundo do Drawer
      child: Column(
        children: [
          // 🔹 Cabeçalho do Drawer (com nome e nível do utilizador)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: const BoxDecoration(color: AppColors.green),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_circle, // Ícone de perfil
                  size: 60,
                  color: AppColors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  userName, // Nome do utilizador
                  style: AppTextStyles.title.copyWith(color: AppColors.white),
                ),
                Text(
                  userLevel, // Nível do utilizador (ex: Pré-Escolar)
                  style: AppTextStyles.body.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20), // Espaçamento após o cabeçalho

          // 🔹 Opções do menu
          _buildTile(
            icon: Icons.group,
            label: "Utilizadores",
            onTap: onManageUsers,
          ),
          _buildTile(
            icon: Icons.emoji_events,
            label: "Conquistas",
            onTap: onAchievements,
          ),
          _buildTile(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: onDashboard,
          ),
        ],
      ),
    );
  }

  // Função auxiliar para construir os itens do menu
  Widget _buildTile({
    required IconData icon,         // Ícone do item
    required String label,          // Texto exibido
    required VoidCallback onTap,    // Função ao clicar
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey), // Ícone lateral
      title: Text(label, style: AppTextStyles.bodyBold), // Texto do item
      onTap: onTap, // Função que será executada ao clicar
      contentPadding: const EdgeInsets.symmetric(horizontal: 20), // Margem interna
      horizontalTitleGap: 16, // Espaço entre ícone e texto
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Cantos arredondados
      ),
      hoverColor: AppColors.lightBlue.withOpacity(0.2), // Cor ao passar o rato (Web/Desktop)
    );
  }
}
