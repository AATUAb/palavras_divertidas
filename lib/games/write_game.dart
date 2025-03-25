import 'package:flutter/material.dart';
import '../widgets/tracing_painter.dart';

class WriteGameScreen extends StatefulWidget {
  final String character;

  const WriteGameScreen({super.key, required this.character});

  @override
  _WriteGameScreenState createState() => _WriteGameScreenState();
}

class _WriteGameScreenState extends State<WriteGameScreen> {
  final List<Offset> _points = [];
  bool _isCompleted = false;
  bool _showValidationMessage = false;
  final GlobalKey _canvasKey = GlobalKey();
  late Rect letterArea;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setLetterArea();
    });
  }

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

    int validPoints = _points
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
      builder: (context) => AlertDialog(
        title: Text("Parabéns!"),
        content: Text("Você completou a letra ${widget.character}!"),
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

  void _resetDrawing() {
    setState(() {
      _points.clear();
      _isCompleted = false;
      _showValidationMessage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Escreva: ${widget.character}")),
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
                      width: 250,
                      height: 280,
                      child: TracingPainter(widget.character),
                    ),
                  ),
                  CustomPaint(
                    painter: UserDrawingPainter(_points),
                    size: Size.infinite,
                  ),
                  if (_showValidationMessage)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
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
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _validateDrawing,
                  child: Text("Validar"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetDrawing,
                  child: Text("Limpar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
