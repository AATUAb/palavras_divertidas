//Estrutura principal para a página inicial da APP. 

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';             // Modelo do utilizador
import '../services/hive_service.dart';         // Serviço de armazenamento com Hive
import '../themes/colors.dart';                 // Arquivo de cores do tema
import '../themes/text_styles.dart';            // Estilos de texto do tema
import 'add_user_dialog.dart';                 // Diálogo para adicionar/editar utilizador
import 'game_menu.dart';                        // Tela de menu do jogo

// Classe principal que representa a página inicial do app
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title; // Título da tela

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Estado da página (com lógica e dados dinamicos)
class _MyHomePageState extends State<MyHomePage> {
  List<UserModel> users = []; // Lista de utilizadores carregados do Hive

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Carrega os utilizadores ao iniciar a tela
  }

  // Função para carregar os utilizadores do Hive e atualizar a interface
  void _loadUsers() {
    setState(() {
      users = HiveService.getUsers();
    });
  }

  // Função para exibir o diálogo de adicionar utilizador
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddUserDialog(
          onUserAdded: (name, level, letters) async {
            final newUser = UserModel(
              name: name,
              level: level,
              knownLetters: letters,
            );
            await HiveService.addUser(newUser); // Salva o utilizador no Hive
            _loadUsers(); // Atualiza a lista após adicionar
          },
        );
      },
    );
  }

  // Função para exibir o diálogo de edição de um utilizador existente
  void _showEditUserDialog(int index, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AddUserDialog(
          initialName: user.name,
          initialLevel: user.level,
          initialLetters: user.knownLetters,
          onUserAdded: (name, level, letters) async {
            final updatedUser = UserModel(
              name: name,
              level: level,
              knownLetters: letters,
            );
            await HiveService.updateUser(index, updatedUser); // Atualiza no Hive
            _loadUsers(); // Atualiza a interface
          },
          onDelete: () async {
            await HiveService.deleteUser(index); // apaga o utilizador
            _loadUsers(); // Atualiza a interface
          },
        );
      },
    );
  }

  // Método que constrói a interface da página
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.title,
          style: AppTextStyles.title.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColors.lightBlue),
        child: Column(
          children: [
            // Cabeçalho com ícone e pergunta
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Icon(Icons.people, color: AppColors.orange, size: 30.sp),
                  SizedBox(width: 10.w),
                  Text(
                    "Quem vai jogar hoje?",
                    style: AppTextStyles.subtitle.copyWith(fontSize: 18.sp),
                  ),
                ],
              ),
            ),

            // Corpo principal que exibe os utilizadors ou botão de adicionar
            Expanded(
              child: Center(
                child: users.isEmpty
                    ? SizedBox.expand(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildAddUserButton()], // Apenas botão se lista vazia
                        ),
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: users.length + 1, // Adiciona botão no fim
                          itemBuilder: (context, index) {
                            if (index == users.length) {
                              return _buildAddUserButton(); // Último item é botão de adicionar
                            }
                            return _buildUserCard(index); // Cartão do utilizador
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função que cria o cartão visual de cada utilizador
  Widget _buildUserCard(int index) {
    final Color cardColor =
        users[index].level == "Pré-Escolar" ? AppColors.green : AppColors.orange;

    return Card(
      color: cardColor.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 5,
      child: InkWell(
        onTap: () {
          // Abre a tela de menu do jogo com o utilizador selecionado
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameMenu(user: users[index]),
            ),
          ).then((_) => _loadUsers()); // Atualiza após retornar
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar com ícone dependendo do nível
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      users[index].level == "Pré-Escolar"
                          ? Icons.child_care
                          : Icons.school,
                      size: 50.sp,
                      color: cardColor,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Nome do utilizador
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      users[index].name,
                      style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.white, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Nível do utilizador
                  Text(
                    users[index].level,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Botão de edição no canto superior direito
            Positioned(
              top: 5.h,
              right: 5.w,
              child: IconButton(
                onPressed: () => _showEditUserDialog(index, users[index]),
                icon: Icon(Icons.edit, color: AppColors.white, size: 20.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função que cria o botão de "Adicionar Utilizador"
  Widget _buildAddUserButton() {
    return SizedBox(
      width: 200.w,
      height: 200.h,
      child: Card(
        color: AppColors.lightGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: AppColors.grey, width: 2.w),
        ),
        elevation: 3,
        child: InkWell(
          onTap: _showAddUserDialog,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, size: 60.sp, color: AppColors.green),
                SizedBox(height: 10.h),
                Text(
                  "Adicionar\nUtilizador",
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.green,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
