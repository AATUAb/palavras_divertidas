import 'package:flutter/material.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/tracing_models.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/tracing_page.dart';
import '../../models/user_model.dart'; // se precisares de usar o user para algo

class WritingGame extends StatelessWidget {
  final UserModel user; 
  const WritingGame({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracing Game'),
      ),
      body: Column(
        children: [
          Expanded(
            child: TracingCharsGame(
              showAnchor: true,
              traceShapeModel: [
                TraceCharsModel(chars: [
                  TraceCharModel(
                    char: 'X',
                    traceShapeOptions:
                        const TraceShapeOptions(innerPaintColor: Colors.orange),
                  )
                ])
              ],
              onTracingUpdated: (int currentTracingIndex) async {
                print('/////onTracingUpdated:' +
                    currentTracingIndex.toString());
              },
              onGameFinished: (int screenIndex) async {
                print('/////onGameFinished:' + screenIndex.toString());
              },
              onCurrentTracingScreenFinished: (int currentScreenIndex) async {
                print('/////onCurrentTracingScreenFinished:' +
                    currentScreenIndex.toString());
              },
            ),
          ),
        ],
      ),
    );
  }
}