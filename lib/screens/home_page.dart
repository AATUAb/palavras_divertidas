// ecrã inicia da aplicação, onde são apresentados os utilizadores e onde se pode adicionar novos utilizadores
// é possível editar ou remover utilizadores existentes
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../themes/colors.dart';
import 'add_user_dialog.dart';
import 'game_menu.dart';
import '../widgets/menu_design.dart'; 

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      users = HiveService.getUsers();
    });
  }

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
            await HiveService.addUser(newUser);
            _loadUsers();
          },
        );
      },
    );
  }

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
            await HiveService.updateUser(index, updatedUser);
            _loadUsers();
          },
          onDelete: () async {
            await HiveService.deleteUser(index);
            _loadUsers();
          },
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  double cardWidth = (1.sw - 16.w * 2 - 10.w * 2) / 3;
  return Scaffold(
    body: MenuDesign(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0.h, bottom: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, color: AppColors.orange, size: 35.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Quem vai jogar hoje?",
                    style: TextStyle(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                alignment: WrapAlignment.center,
                children: [
                  ...users.asMap().entries.map(
                        (entry) => SizedBox(
                          width: cardWidth,
                          child: _buildUserCard(entry.key),
                        ),
                      ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildAddUserButton(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h), 
          ],
        ),
      ),
    ),
  );
}



  Widget _buildUserCard(int index) {
  final Color cardColor = users[index].level == "Pré-Escolar"
      ? AppColors.green
      : AppColors.orange;

  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: 200.w,
      // maxHeight: 80.h, // Removed fixed height
    ),
    child: Card(
      color: cardColor.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameMenu(user: users[index]),
            ),
          ).then((_) => _loadUsers());
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      users[index].level == "Pré-Escolar"
                          ? Icons.child_care
                          : Icons.school,
                      size: 40.sp,
                      color: cardColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w), 
                    child: Text(
                      users[index].name,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    users[index].level,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 5.h,
              right: 5.w,
              child: IconButton(
                onPressed: () => _showEditUserDialog(index, users[index]),
                icon: Icon(Icons.edit, color: AppColors.white, size: 18.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildAddUserButton() {
    return SizedBox(
      width: 160.w,
      // height: 80.h, // Removed fixed height
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
                  "Adiciona Utilizador",
                    style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
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
