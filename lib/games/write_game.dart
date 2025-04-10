// Estrutura principal do jogo "Escrita de letras, numeros e palavras"
import 'package:flutter/material.dart';
import '../widgets/tracing_painter.dart';
import 'package:audioplayers/audioplayers.dart';

class WriteGameScreen extends StatefulWidget {
  final String character;

  const WriteGameScreen({super.key, required this.character});

  @override
  WriteGameScreenState createState() => WriteGameScreenState(); // Alterado para classe pública
}

class WriteGameScreenState extends State<WriteGameScreen> {
  // Alterado para classe pública
  final List<Offset> _points = [];
  bool _isCompleted = false;
  bool _showValidationMessage = false;
  final GlobalKey _canvasKey = GlobalKey();
  late Rect letterArea;

  // AudioPlayer to control music
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Stop any playing music
      _audioPlayer.stop();
      
      // Initialize the game
      _setLetterArea();
    });
  }

  void _setLetterArea() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      letterArea = Rect.fromCenter(
        center: Offset(screenSize.width / 2, screenSize.height * 0.4),
        width: screenSize.width * 0.5,
        height: screenSize.height * 0.3,
      );
    });
  }

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

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _points.add(Offset.infinite);
    });
  }

  void _validateDrawing() {
    List<Offset> expectedPoints = _generateExpectedPoints(letterArea);

    int validPoints =
        _points
            .where((p) => expectedPoints.any((ep) => (p - ep).distance < 15))
            .length;

    double preenchimento = (validPoints / expectedPoints.length) * 100;

    if (preenchimento >= 80) {
      setState(() {
        _isCompleted = true;
        _showValidationMessage = true;
      });
      _showSuccessDialog();
    } else {
      setState(() {
        _showValidationMessage = true;
      });
      _showFailureDialog();
    }
  }

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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Parabéns!"),
            content: Text("Escreveste uma letra ${widget.character}!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetDrawing();
                },
                child: Text("Tentar outra"),
              ),
            ],
          ),
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Ops!"),
            content: Text(
              "Não preencheste corretamente a letra. Tente novamente.",
            ),
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

  void _resetDrawing() {
    setState(() {
      _points.clear();
      _isCompleted = false;
      _showValidationMessage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final canvasWidth = screenSize.width * 0.7;
    final canvasHeight = screenSize.height * 0.4;
    final fontSize = canvasHeight * 1.5;
    final strokeWidth = fontSize * 0.1;

    return Scaffold(
      appBar: AppBar(title: Text("Escreve: ${widget.character}")),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Stack(
                key: _canvasKey,
                children: [
                  Center(
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
                      child: TracingPainter(
                        widget.character,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: UserDrawingPainter(_points, strokeWidth),
                    size: Size.infinite,
                  ),
                  if (_showValidationMessage)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Text(
                          _isCompleted
                              ? "Letra correta! ✅"
                              : "Tente novamente!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double buttonWidth =
                    constraints.maxWidth > 500
                        ? 180
                        : (constraints.maxWidth - 48) / 2;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: buttonWidth,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _validateDrawing,
                        child: Text("Validar", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: buttonWidth,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _resetDrawing,
                        child: Text("Limpar", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
