// Menu para a acição e edição de utilizadores do jogo
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';

class AddUserDialog extends StatefulWidget {
  final Function(String, String, List<String>) onUserAdded;
  final String? initialName;
  final String? initialLevel;
  final List<String>? initialLetters;
  final Function()? onDelete;

  const AddUserDialog({
    super.key,
    required this.onUserAdded,
    this.initialName,
    this.initialLevel,
    this.initialLetters,
    this.onDelete,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  late TextEditingController _nameController;
  late String _selectedLevel;

  final List<String> _letters = [
    "I", "U", "O", "A", "E", "P", "T", "L", "D", "M", "V", "C", "Q", "N", "R", "B",
    "G", "J", "F", "S", "Z", "H", "X", "CH", "LH", "NH",
    "BR, CR, DR, FR, GR, PR, TR, VR",
    "BL, CL, FL, GL, PL, TL",
  ];

  late Map<String, bool> _lettersSelected;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? "");
    _selectedLevel = widget.initialLevel ?? "Pré-Escolar";
    _lettersSelected = {for (var letter in _letters) letter: false};

    if (widget.initialLetters != null) {
      for (var letter in widget.initialLetters!) {
        if (_lettersSelected.containsKey(letter)) {
          _lettersSelected[letter] = true;
        }
      }
    }

    _selectAll = _lettersSelected.values.every((e) => e);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600.w,
          maxHeight: (_selectedLevel == "1º Ciclo" ? 450.h : 320.h),
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
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
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
                          fontSize: 14.sp,
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
                      SizedBox(height: 10.h),

                      if (_selectedLevel == "1º Ciclo")
                        Column(
                          children: [
                            Text(
                              "Quais as letras que já aprendeste?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            CheckboxListTile(
                              title: Text(
                                "Todas",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                ),
                              ),
                              value: _selectAll,
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectAll = value ?? false;
                                  _lettersSelected.updateAll(
                                    (key, _) => _selectAll,
                                  );
                                });
                              },
                            ),
                            SizedBox(
                              height: 150.h,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _letters.map((letter) {
                                    return CheckboxListTile(
                                      title: Text(
                                        letter,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      value: _lettersSelected[letter],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _lettersSelected[letter] = value ?? false;
                                          _selectAll = _lettersSelected.values.every((e) => e);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

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
                          icon: Icon(Icons.delete, size: 30.sp),
                          label: Text(
                            "Eliminar",
                            style: TextStyle(
                              fontSize: 30.sp,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.red,
                          ),
                        ),

                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.cancel, size: 30.sp),
                        label: Text(
                          "Cancelar",
                          style: TextStyle(
                            fontSize: 30.sp,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.grey,
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            final selected = _lettersSelected.entries
                                .where((e) => e.value)
                                .map((e) => e.key)
                                .toList();
                            widget.onUserAdded(
                              _nameController.text,
                              _selectedLevel,
                              selected,
                            );
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(Icons.save, size: 30.sp),
                        label: Text(
                          "Salvar",
                          style: TextStyle(
                            fontSize: 30.sp,
                          ),
                        ),
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
    final bool selected = _selectedLevel == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedLevel = label),
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
