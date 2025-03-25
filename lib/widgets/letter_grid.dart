// Widget usado no jogo "identify_letter_numbers", jogo 1

import 'package:flutter/material.dart';

/// Widget reutilizável que exibe uma grelha de letras ou caracteres
class LetterGrid extends StatelessWidget {
  final List<String> options;        // Lista de letras/caracteres a mostrar
  final Function(String) onSelect;   // Função chamada ao selecionar uma letra

  const LetterGrid({
    required this.options,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,     // Espaçamento horizontal entre botões
      runSpacing: 10,  // Espaçamento vertical quando quebra de linha
      children: options
          .map(
            (char) => ElevatedButton(
              onPressed: () => onSelect(char), // Aciona callback ao clicar
              child: Text(
                char,
                style: TextStyle(fontSize: 24), // Tamanho do texto da letra
              ),
            ),
          )
          .toList(),
    );
  }
}
