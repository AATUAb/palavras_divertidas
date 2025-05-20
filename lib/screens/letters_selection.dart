// Caixa de seleção de letras para o 1.º ciclo
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../themes/colors.dart';

// Classe geral para mostrar uma caixa de diálogo com letras
Future<void> showLettersDialog({
  required BuildContext context,
  required List<String> initialSelection,
  required void Function(List<String> selectedLetters) onSaved,
}) async {
  // Lista de letras e sons disponíveis para seleção
  final List<String> letters = [
    "Vogais: A,E, I, O, U", "P", "T", "L", "D", "M", "V",
    "C", "Q", "N", "R", "B", "G", "J", "F", "S", "Z", "H", "X",
    "CH", "LH", "NH",
    "BR, CR, DR, FR, GR, PR, TR, VR",
    "BL, CL, FL, GL, PL, TL",
  ];

  // Mapeia as letras com base na seleção inicial do utilizador
  Map<String, bool> selectedMap = {
    for (var l in letters) l: initialSelection.contains(l),
  };

  bool selectAll = selectedMap.values.every((v) => v);
  bool allSelectedMode = false;

  final player = AudioPlayer();
  final ValueNotifier<bool> introPlayed = ValueNotifier(false);

 // Toca o som de instrução uma única vez ao abrir a caixa de diálogo
 void playIntroSoundOnce(AudioPlayer player, bool hasPlayed, void Function() markAsPlayed) {
  if (!hasPlayed) {
    markAsPlayed();
    player.stop().then((_) {
      player.play(AssetSource('sounds/select_letters.ogg'));
    });
  }
}
 
 // Controla a exibição e interações da caixa de diálogo
  await showDialog(
  context: context,
  builder: (context) => StatefulBuilder(
    builder: (context, setState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        playIntroSoundOnce(player, introPlayed.value, () => introPlayed.value = true);
      });

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 500.h),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        // Título principal da caixa de diálogo
                        Text(
                        "Escolhe as letras ou sons que já aprendeste na escola",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                selectAll = !selectAll;
                                allSelectedMode = selectAll;
                                selectedMap.updateAll((key, _) => selectAll);
                                setState(() {});
                              },
                              // Botão para selecionar todas as letras
                              icon: Icon(
                                selectAll ? Icons.check_box : Icons.check_box_outline_blank,
                                size: 20.sp,
                                color: AppColors.green,
                              ),
                              label: Text(
                                "Todas",
                                style: TextStyle(fontSize: 20.sp, color: AppColors.green),
                              ),
                            ),
                            // Botão para limpar todas as seleções
                            TextButton.icon(
                              onPressed: () {
                                selectedMap.updateAll((key, _) => false);
                                selectAll = false;
                                allSelectedMode = false;
                                setState(() {});
                              },
                              icon: Icon(Icons.clear, size: 20.sp, color: AppColors.red),
                              label: Text(
                                "Limpar",
                                style: TextStyle(fontSize: 20.sp, color: AppColors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: letters.asMap().entries.map((entry) {
                              final index = entry.key;
                              final letter = entry.value;
                              final isSelected = selectedMap[letter] ?? false;

                              final lastSelectedIndex = letters.lastIndexWhere((l) => selectedMap[l] == true);
                              final canTap = index == 0 || index == lastSelectedIndex + 1 || isSelected;

                              // Se todas as letras estiverem selecionadas, impede mais seleções e mostra aviso com som
                              return GestureDetector(
                                onTap: () async {
                                  if (allSelectedMode) {
                                    await player.stop();
                                    await player.play(AssetSource('sounds/clean_letters.ogg'));

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Já clicaste em todas as letras. Clica em Limpar para desmarcar."),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    return;
                                  }

                                  // Verifica se a letra anterior foi selecionada. Se não, bloqueia a ação e dá texto e som com informação
                                  if (canTap) {
                                    selectedMap[letter] = !isSelected;
                                    selectAll = selectedMap.values.every((v) => v);
                                    setState(() {});
                                  } else {
                                    try {
                                    await player.stop();
                                    await player.play(AssetSource('sounds/before_letter.ogg'));
                                    } catch (e) {
                                      debugPrint('Erro ao reproduzir som: $e');
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Ainda não clicaste na opção anterior."),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                // Ajusta a opacidade da letra com base no estado de seleção
                                child: Opacity(
                                  opacity: canTap ? 1.0 : 0.4,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.green : AppColors.lightGrey,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isSelected ? AppColors.green : AppColors.grey,
                                      ),
                                    ),
                                    child: Text(
                                      letter,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Botões "Cancelar" e "OK" no final da caixa de diálogo
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.cancel, size: 20.sp, color: AppColors.grey),
                            label: Text("Cancelar", style: TextStyle(color: AppColors.grey)),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.check, size: 20.sp),
                            label: Text("Ok"),
                            onPressed: () {
                              final selected = selectedMap.entries
                                  .where((e) => e.value)
                                  .map((e) => e.key)
                                  .toList();
                              onSaved(selected);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}


