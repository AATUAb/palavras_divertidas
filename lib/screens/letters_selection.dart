// Caixa de seleção de letras para o 1.º ciclo
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../themes/colors.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';

// Expande letras combinadas para uso no jogo (ex: "Vogais" → "a", "e", "i", "o", "u")
List<String> expandKnownLetters(List<String> knownSelections) {
  final expanded = <String>[];

  for (final item in knownSelections) {
    final normalized = item.trim().toLowerCase();

    if (normalized.startsWith('vogais')) {
      expanded.addAll(['a', 'e', 'i', 'o', 'u']);
    } else if (normalized == 'br, cr, dr, fr, gr, pr, tr, vr') {
      expanded.addAll(['br', 'cr', 'dr', 'fr', 'gr', 'pr', 'tr', 'vr']);
    } else if (normalized == 'bl, cl, fl, gl, pl, tl') {
      expanded.addAll(['bl', 'cl', 'fl', 'gl', 'pl', 'tl']);
    } else if (normalized.contains(',')) {
      final parts = normalized.split(',');
      for (final part in parts) {
        final clean = part.trim();
        if (clean.isNotEmpty) expanded.add(clean);
      }
    } else {
      expanded.add(normalized);
    }
  }
  return expanded;
}

// Classe geral para mostrar uma caixa de diálogo com letras
Future<void> showLettersDialog({
  required BuildContext context,
  required UserModel user,
  required List<String> initialSelection,
  required void Function(List<String> selectedLetters) onSaved,
}) async {
  final List<String> letters = [
    "Vogais: A,E, I, O, U", "P", "T", "L", "D", "M", "V",
    "C", "Q", "N", "R", "B", "G", "J", "F", "S", "Z", "H", "X",
    "CH", "LH", "NH",
    "BR, CR, DR, FR, GR, PR, TR, VR",
    "BL, CL, FL, GL, PL, TL",
  ];

  Map<String, bool> selectedMap = {
    for (var l in letters) l: initialSelection.contains(l),
  };

  bool selectAll = selectedMap.values.every((v) => v);
  bool allSelectedMode = false;

  final player = AudioPlayer();
  final ValueNotifier<bool> introPlayed = ValueNotifier(false);

  void playIntroSoundOnce(AudioPlayer player, bool hasPlayed, void Function() markAsPlayed) {
    if (!hasPlayed) {
      markAsPlayed();
      player.stop().then((_) {
        player.play(AssetSource('sounds/select_letters.ogg'));
      });
    }
  }

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

                              return GestureDetector(
                                onTap: () async {
                                  final currentContext = context;
                                  if (allSelectedMode) {
                                    await player.stop();
                                    await player.play(AssetSource('sounds/clean_letters.ogg'));

                                    if (!currentContext.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Já clicaste em todas as letras. Clica em Limpar para desmarcar."),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    return;
                                  }

                                  if (canTap) {
                                    selectedMap[letter] = !isSelected;
                                    selectAll = selectedMap.values.every((v) => v);
                                    setState(() {});
                                  } else {
                                    await player.stop();
                                    await player.play(AssetSource('sounds/before_letter.ogg'));
                                    if (!currentContext.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Ainda não clicaste na opção anterior."),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
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
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.cancel, size: 20.sp, color: AppColors.grey),
                            label: Text("Cancelar", style: TextStyle(color: AppColors.grey)),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.check, size: 20.sp),
                            label: Text("Ok"),
                            onPressed: () async {
                              final selected = selectedMap.entries
                                  .where((e) => e.value)
                                  .map((e) => e.key)
                                  .toList();

                              user.knownLetters = selected;
                              await user.save();

                              await handleLetterUpdateAndResetLevel(
                                user: user,
                                gameNames: [
                                  'Ouvir e Procurar Palavra',
                                  'Sílabas perdidas',
                                  'Escrever',
                                ],
                                isLetterDependent: true,
                              );

                              onSaved(selected);
                              debugPrint('🔠 Letras atualizadas: $selected');
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
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

  Future<void> handleLetterUpdateAndResetLevel({
  required UserModel user,
  required List<String> gameNames, 
  bool isLetterDependent = true,
}) async {
  if (!isLetterDependent || user.schoolLevel != '1º Ciclo') return;

  final expanded = expandKnownLetters(user.knownLetters)..sort();
  final currentHash = expanded.join(',').toLowerCase();
  final previousHash = user.lastLettersHash ?? '';

  if (currentHash != previousHash) {
    user
      ..gameLevel = 1
      ..lastLettersHash = currentHash;

    await user.save();

    for (final game in gameNames) {
      await HiveService.saveGameLevel(
        userKey: user.key.toString(),
        gameName: game,
        level: 1,
      );
    }
  }
}