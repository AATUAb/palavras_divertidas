import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../themes/colors.dart';
import 'add_user_dialog.dart';
import 'game_menu.dart';
import '../widgets/menu_design.dart';
import 'letters_selection.dart';

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
          onUserAdded: (name, schoolLevel, letters) async {
            final newUser = UserModel(
              name: name,
              schoolLevel: schoolLevel,
              knownLetters: letters,
              gameLevel: 1,
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
          initialSchoolLevel: user.schoolLevel,
          onUserAdded: (name, schoolLevel, letters) async {
            final updatedUser = user.copyWith(
              name: name,
              schoolLevel: schoolLevel,
              knownLetters: letters,
              gameLevel: user.gameLevel,
              accuracyByLevel: user.accuracyByLevel,
              overallAccuracy: user.overallAccuracy,
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
    return Scaffold(
      body: MenuDesign(
        titleText: "Mundo das Palavras",
        showHomeButton: false,
        headerText: "Quem vai jogar hoje?",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50.h),
            SizedBox(height: 50.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child:
                    users.length <= 3
                        ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: _buildAddUserButton(),
                              ),
                              ...List.generate(
                                users.length,
                                (i) => Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: _buildUserCard(i),
                                ),
                              ),
                            ],
                          ),
                        )
                        : Scrollbar(
                          thumbVisibility: true,
                          thickness: 8,
                          radius: Radius.circular(10),
                          child: GridView.builder(
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount: users.length + 1,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 15.w,
                                  mainAxisSpacing: 15.h,
                                  childAspectRatio: 1.9,
                                ),
                            itemBuilder: (context, index) {
                              if (index == 0) return _buildAddUserButton();
                              return _buildUserCard(index - 1);
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

  Widget _buildUserCard(int index) {
    final user = users[index];
    final Color cardColor =
        user.schoolLevel == "Pré-Escolar" ? AppColors.green : AppColors.orange;

    return SizedBox(
      width: 200.w,
      height: 120.h,
      child: Card(
        color: cardColor.withAlpha((255 * 0.8).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 3,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GameMenu(user: user)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor: AppColors.white,
                          child: Icon(
                            user.schoolLevel == "Pré-Escolar"
                                ? Icons.child_care
                                : Icons.school,
                            size: 30.sp,
                            color: cardColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user.schoolLevel == "1º Ciclo")
                              ElevatedButton(
                                onPressed: () async {
                                  await pauseMenuMusic();
                                  await showLettersDialog(
                                    context: context,
                                    user: user,
                                    initialSelection: user.knownLetters,
                                    onSaved: (selectedLetters) {
                                      final updatedUser = user.copyWith(
                                        knownLetters: selectedLetters,
                                      );
                                      HiveService.updateUser(
                                        index,
                                        updatedUser,
                                      );
                                      _loadUsers();
                                    },
                                  );
                                  await resumeMenuMusic();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size.zero,
                                ),
                                child: Text(
                                  "Letras Novas?",
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              ),
                            Text(
                              user.schoolLevel,
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: AppColors.white.withAlpha(
                                  (255 * 0.9).toInt(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -5.h,
                right: 5.w,
                child: IconButton(
                  onPressed: () => _showEditUserDialog(index, user),
                  icon: Icon(Icons.edit, color: AppColors.white, size: 20.sp),
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
      width: 200.w,
      height: 120.h,
      child: Card(
        color: AppColors.lightGrey.withAlpha((255 * 0.8).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 3,
        child: InkWell(
          onTap: _showAddUserDialog,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, size: 60.sp, color: AppColors.green),
                SizedBox(height: 6.h),
                Text(
                  "Adiciona Utilizador",
                  style: TextStyle(
                    fontSize: 20.sp,
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