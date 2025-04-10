import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';

class AddUserDialog extends StatefulWidget {
  final Function(String, String, List<String>) onUserAdded;
  final String? initialName;
  final String? initialSchoolLevel;
  final Function()? onDelete;

  const AddUserDialog({
    super.key,
    required this.onUserAdded,
    this.initialName,
    this.initialSchoolLevel,
    this.onDelete,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  late TextEditingController _nameController;
  late String _selectedSchoolLevel;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? "");
    _selectedSchoolLevel = widget.initialSchoolLevel ?? "Pré-Escolar";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600.w,
          maxHeight: 320.h,
        ),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    widget.initialName == null
                        ? "Vamos Conhecer-nos!"
                        : "Editar Perfil",
                    style: TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60.w),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: "Nome",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            Icons.person,
                            color: AppColors.green,
                            size: 20.w,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                              color: AppColors.green,
                              width: 2.w,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Nível de escolaridade:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLevelOption(
                            "Pré-Escolar",
                            Icons.child_care,
                            AppColors.green,
                          ),
                          SizedBox(width: 10.w),
                          _buildLevelOption(
                            "1º Ciclo",
                            Icons.school,
                            AppColors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.onDelete != null)
                        TextButton.icon(
                          onPressed: () {
                            widget.onDelete!();
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.delete, size: 16.sp),
                          label: Text("Eliminar", style: TextStyle(fontSize: 16.sp)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.red,
                          ),
                        ),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.cancel, size: 16.sp),
                        label: Text("Cancelar", style: TextStyle(fontSize: 16.sp)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.grey,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            widget.onUserAdded(
                              _nameController.text.trim(),
                              _selectedSchoolLevel,
                              [], // Letras vazias por agora
                            );
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(Icons.save, size: 16.sp),
                        label: Text("Salvar", style: TextStyle(fontSize: 16.sp)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelOption(String label, IconData icon, Color color) {
    final bool selected = _selectedSchoolLevel == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSchoolLevel = label),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color, width: 2.w),
          ),
          child: Column(
            children: [
              Icon(icon, size: 30.sp, color: selected ? Colors.white : color),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}