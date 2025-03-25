import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../themes/colors.dart';
import '../themes/text_styles.dart';
import 'add_user_dialog.dart';
import 'game_menu.dart';

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
        decoration: const BoxDecoration(color: AppColors.lightBlue),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
            Expanded(
              child: Center(
                child:
                    users.isEmpty
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_buildAddUserButton()],
                        )
                        : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width > 600
                                          ? 3
                                          : 2,
                                  crossAxisSpacing: 10.w,
                                  mainAxisSpacing: 10.h,
                                  childAspectRatio: 1.2,
                                ),
                            itemCount: users.length + 1,
                            itemBuilder: (context, index) {
                              if (index == users.length) {
                                return _buildAddUserButton();
                              }
                              return _buildUserCard(index);
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
    final Color cardColor =
        users[index].level == "Pré-Escolar"
            ? AppColors.green
            : AppColors.orange;

    return Card(
      color: cardColor.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 5,
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      users[index].name,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.white,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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

  Widget _buildAddUserButton() {
    return SizedBox(
      width: 250.w,
      height: 100.h,
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
