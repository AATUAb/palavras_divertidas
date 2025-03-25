//Estrutura principal para o jogo "Escrever". Jogo 2

import 'package:flutter/material.dart';
import '../widgets/tracing_painter.dart';

// Tela onde o utilizador deve desenhar (escrever) uma letra ou número
class WriteGameScreen extends StatefulWidget {
  final String character; // Letra ou número que deve ser escrito

  const WriteGameScreen({super.key, required this.character});

  @override
  _WriteGameScreenState createState() => _WriteGameScreenState();
}

class _WriteGameScreenState extends State<WriteGameScreen> {
  final List<Offset> _points = []; // Lista de pontos desenhados pelo utilizador
  bool _isCompleted = false; // Indica se o desenho foi validado com sucesso
  bool _showValidationMessage = false; // Exibe mensagem após validação
  final GlobalKey _canvasKey = GlobalKey(); // Referência ao canvas

  // Área onde a letra será considerada válida (zona de validação)
  late Rect letterArea;

  // Inicializa o componente e define a área da letra após renderização inicial
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setLetterArea();
    });
  }

  // Define uma área retangular onde a letra deve ser escrita
  void _setLetterArea() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      letterArea = Rect.fromCenter(
        center: Offset(screenSize.width * 0.6, screenSize.height * 0.5),
        width: 220,
        height: 280,
      );
    });
  }

  // Captura os pontos desenhados enquanto o utilizador arrasta o dedo
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isCompleted) {
      final RenderBox box =
          _canvasKey.currentContext!.findRenderObject() as RenderBox;
      Offset localPosition = box.globalToLocal(details.globalPosition);

      setState(() {
        _points.add(localPosition);
      });
    }
  }

  // Marca o fim de um traço desenhado
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _points.add(Offset.infinite); // Usado para separar traços
    });
  }

  // Valida o desenho do utilizador comparando com pontos esperados
  void _validateDrawing() {
    List<Offset> expectedPoints = _generateExpectedPoints(letterArea);

    // Conta quantos pontos desenhados estão próximos dos esperados
    int validPoints =
        _points
            .where((p) => expectedPoints.any((ep) => (p - ep).distance < 15))
            .length;

    double preenchimento = (validPoints / expectedPoints.length) * 100;

    if (preenchimento >= 80) {
      // Se pelo menos 80% da letra for coberta
      setState(() {
        _isCompleted = true;
        _showValidationMessage = true;
      });

      _showSuccessDialog(); // Mostra mensagem de sucesso
    } else {
      setState(() {
        _showValidationMessage = true;
      });

      _showFailureDialog(); // Mostra mensagem de falha
    }
  }

  // Gera uma grade de pontos dentro da área da letra para validação
  List<Offset> _generateExpectedPoints(Rect area) {
    List<Offset> points = [];
    int stepX = (area.width / 10).round();
    int stepY = (area.height / 10).round();

    for (double x = area.left; x <= area.right; x += stepX) {
      for (double y = area.top; y <= area.bottom; y += stepY) {
        points.add(Offset(x, y));
      }
    }

    return points;
  }

  // Exibe diálogo quando o utilizador completa a letra corretamente
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Parabéns!"),
        content: Text("Você completou a letra ${widget.character}!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetDrawing(); // Permite tentar outra letra
            },
            child: Text("Tentar outra"),
          ),
        ],
      ),
    );
  }

  // Exibe diálogo de erro quando a validação falha
  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ops!"),
        content: Text("Você não preencheu corretamente a letra. Tente novamente."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Limpa todos os pontos desenhados e reseta o estado
  void _resetDrawing() {
    setState(() {
      _points.clear();
      _isCompleted = false;
      _showValidationMessage = false;
    });
  }

  // Monta a interface com o botão de validação e área de desenho
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Escreva: ${widget.character}")),
      body: Row(
        children: [
          // Coluna lateral com botões de controle
          Padding(
            padding: const EdgeInsets.all(90.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _validateDrawing,
                  child: Text("Validar"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _resetDrawing,
                  child: Text("Limpar"),
                ),
                if (_showValidationMessage)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _isCompleted
                          ? "Letra correta! ✅"
                          : "Preencha a letra corretamente!",
                      style: TextStyle(
                        color: _isCompleted ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Área de desenho principal
          Expanded(
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Stack(
                key: _canvasKey,
                children: [
                  // Exibe o contorno da letra/número como referência
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 280,
                      child: TracingPainter(widget.character),
                    ),
                  ),

                  // Exibe o traço feito pelo utilizador
                  CustomPaint(
                    painter: UserDrawingPainter(_points),
                    size: Size.infinite,
                  ),

                  // Ícone de sucesso quando a letra for completada corretamente
                  if (_isCompleted)
                    Center(
                      child: Icon(
                        Icons.check_circle,
                        size: 90,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
