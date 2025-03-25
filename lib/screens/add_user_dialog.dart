// Adicionar um novo utilizador ao sistema.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/colors.dart';
import '../themes/text_styles.dart';

// Tela de diálogo para adicionar ou editar um utilizador
class AddUserDialog extends StatefulWidget {
  // Função callback chamada ao salvar um novo utilizador
  final Function(String, String, List<String>) onUserAdded;

  // Valores iniciais usados ao editar um utilizador existente
  final String? initialName;
  final String? initialLevel;
  final List<String>? initialLetters;

  // Callback opcional para apagar o utilizador
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

  // Lista de letras que podem ser marcadas como "aprendidas"
  final List<String> _letters = [
    "I",
    "U",
    "O",
    "A",
    "E",
    "P",
    "T",
    "L",
    "D",
    "M",
    "V",
    "C",
    "Q",
    "N",
    "R",
    "B",
    "G",
    "J",
    "F",
    "S",
    "Z",
    "H",
    "X",
    "CH",
    "LH",
    "NH",
    "BR, CR, DR, FR, GR, PR, TR, VR",
    "BL, CL, FL, GL, PL, TL",
  ];

  // Mapa que indica quais letras estão selecionadas
  late Map<String, bool> _lettersSelected;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // Inicia o controlador de texto com nome pré-definido (se houver)
    _nameController = TextEditingController(text: widget.initialName ?? "");

    // Nível inicial (ou padrão)
    _selectedLevel = widget.initialLevel ?? "Pré-Escolar";

    // Inicia o mapa com todas as letras desmarcadas
    _lettersSelected = {for (var letter in _letters) letter: false};

    // Marca como selecionadas as letras já conhecidas (caso esteja editando)
    if (widget.initialLetters != null) {
      for (var letter in widget.initialLetters!) {
        if (_lettersSelected.containsKey(letter)) {
          _lettersSelected[letter] = true;
        }
      }
    }

    // Verifica se todas as letras estão marcadas
    _selectAll = _lettersSelected.values.every((e) => e);
  }

  // Constrói o conteúdo do diálogo
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
                // Título
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    widget.initialName == null
                        ? "Vamos Conhecer-nos!"
                        : "Editar Perfil",
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Formulário
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60.w),
                  child: Column(
                    children: [
                      // Campo de nome
                      TextField(
                        controller: _nameController,
                        style: AppTextStyles.body.copyWith(fontSize: 14.sp),
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

                      // Escolha do nível
                      Text(
                        "Nível de escolaridade:",
                        style: AppTextStyles.bodyBold.copyWith(fontSize: 14.sp),
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

                      // Seleção de letras (visível apenas para 1º Ciclo)
                      if (_selectedLevel == "1º Ciclo")
                        Column(
                          children: [
                            Text(
                              "Quais as letras que já aprendeste?",
                              style: AppTextStyles.bodyBold.copyWith(
                                fontSize: 14.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Checkbox para selecionar todas
                            CheckboxListTile(
                              title: Text(
                                "Todas",
                                style: TextStyle(fontSize: 12.sp),
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

                            // Lista de checkboxes com as letras
                            SizedBox(
                              height: 150.h,
                              child: SingleChildScrollView(
                                child: Column(
                                  children:
                                      _letters.map((letter) {
                                        return CheckboxListTile(
                                          title: Text(
                                            letter,
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                          value: _lettersSelected[letter],
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _lettersSelected[letter] =
                                                  value ?? false;
                                              _selectAll = _lettersSelected
                                                  .values
                                                  .every((e) => e);
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

                // Botões de ação
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botão de eliminar (se estiver a editar)
                      if (widget.onDelete != null)
                        TextButton.icon(
                          onPressed: () {
                            widget.onDelete!();
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.delete, size: 30.sp),
                          label: Text(
                            "Eliminar",
                            style: TextStyle(fontSize: 30.sp),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.red,
                          ),
                        ),

                      // Botão de cancelar
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.cancel, size: 30.sp),
                        label: Text(
                          "Cancelar",
                          style: TextStyle(fontSize: 30.sp),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.grey,
                        ),
                      ),

                      // Botão de salvar
                      TextButton.icon(
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            final selected =
                                _lettersSelected.entries
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
                          style: TextStyle(fontSize: 30.sp),
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

  // Widget reutilizável para opção de nível de ensino
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
