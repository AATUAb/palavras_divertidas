//cursive_tracing.dart
import 'package:flutter/material.dart';
import 'package:mundodaspalavras/themes/colors.dart';
import 'package:mundodaspalavras/games/writing_game/phonetics_constants/cursive_lower.dart';
import 'package:mundodaspalavras/games/writing_game/phonetics_constants/cursive_upper.dart';
import 'package:mundodaspalavras/games/writing_game/points_manager/shape_points_manager.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_models.dart';
import 'package:mundodaspalavras/games/writing_game/enums/shape_enums.dart';

/// Responsável pelo tracing de letras cursivas 
class CursiveTracking {
  /// Converte uma letra maiúscula em seu enum correspondente.
  CursiveUpperLetters _detectCursiveUpper({
    required String letter,
  }) {
    // Cada case representa uma letra maiúscula suportada
    // Se não for reconhecida, lança erro
    switch (letter.toUpperCase()) {
      case 'A':
        return CursiveUpperLetters.A;
      case 'B':
        return CursiveUpperLetters.B;
      case 'C':
        return CursiveUpperLetters.C;
      case 'D':
        return CursiveUpperLetters.D;
      case 'E':
        return CursiveUpperLetters.E;
      case 'F':
        return CursiveUpperLetters.F;
      case 'G':
        return CursiveUpperLetters.G;
      case 'H':
        return CursiveUpperLetters.H;
      case 'I':
        return CursiveUpperLetters.I;
      case 'J':
        return CursiveUpperLetters.J;
      case 'L':
        return CursiveUpperLetters.L;
      case 'M':
        return CursiveUpperLetters.M;
      case 'N':
        return CursiveUpperLetters.N;
      case 'O':
        return CursiveUpperLetters.O;
      case 'P':
        return CursiveUpperLetters.P;
      case 'Q':
        return CursiveUpperLetters.Q;
      case 'R':
        return CursiveUpperLetters.R;
      case 'S':
        return CursiveUpperLetters.S;
      case 'T':
        return CursiveUpperLetters.T;
      case 'U':
        return CursiveUpperLetters.U;
      case 'V':
        return CursiveUpperLetters.V;
      case 'X':
        return CursiveUpperLetters.X;
      case 'Z':
        return CursiveUpperLetters.Z;
      default:
        throw UnimplementedError('Letra cursiva não suportada: $letter');
    }
  }

/// Converte uma letra minúscula em seu respectivo enum.
  CursiveLowerLetters _detectCursiveLower({required String letter,}) {
    /// Converte uma letra minúscula em seu enum correspondente.
    switch (letter) {
      case 'a':
        return CursiveLowerLetters.a;
      case 'b':
        return CursiveLowerLetters.b;
      case 'c':
        return CursiveLowerLetters.c;
      case 'd':
        return CursiveLowerLetters.d;
      case 'e':
        return CursiveLowerLetters.e;
      case 'f':
        return CursiveLowerLetters.f;
      case 'g':
        return CursiveLowerLetters.g;
      case 'h':
        return CursiveLowerLetters.h;
      case 'i':
        return CursiveLowerLetters.i;
      case 'j':
        return CursiveLowerLetters.j;
      case 'l':
        return CursiveLowerLetters.l;
      case 'm':
        return CursiveLowerLetters.m;
      case 'n':
        return CursiveLowerLetters.n;
      case 'o':
        return CursiveLowerLetters.o;
      case 'p':
        return CursiveLowerLetters.p;
      case 'q':
        return CursiveLowerLetters.q;
      case 'r':
        return CursiveLowerLetters.r;
      case 's':
        return CursiveLowerLetters.s;
      case 't':
        return CursiveLowerLetters.t;
      case 'u':
        return CursiveLowerLetters.u;
      case 'v':
        return CursiveLowerLetters.v;
      case 'x':
        return CursiveLowerLetters.x;
      case 'z':
        return CursiveLowerLetters.z;
      default:
        throw UnimplementedError('Letra cursiva minúscula não suportada: $letter');
    }
  }

  /// Verifica se a letra fornecida é uma letra maiúscula (A-Z)
  bool _isUpperCursiveUpper(String letter) =>
  RegExp(r'^[A-Z]$').hasMatch(letter);

  /// Verifica se a letra fornecida é uma letra minúscula (a-z)
  bool _isLowerCursiveLower(String letter) =>
  RegExp(r'^[a-z]$').hasMatch(letter);

  /// Retorna os dados de traçado de acordo com o estado atual:
  /// - Letras isoladas (chars)
  /// - Palavras completas (traceWords)
  List<TraceModel> getTracingData({
      List<TraceCharModel>? chars,
      TraceWordModel? word,
      required StateOfTracing currentOfTracking,
    }) {
      List<TraceModel> tracingDataList = [];

      if (currentOfTracking == StateOfTracing.traceWords) {
        tracingDataList.addAll(getTraceWords(wordWithOption: word!));
      } else if (currentOfTracking == StateOfTracing.chars) {
        if (chars == null) return [];
        for (var char in chars) {
          final letters = char.char;

          // Adiciona modelo de traçado para letra maiúscula
          if (_isUpperCursiveUpper(letters)) {
            tracingDataList.add(
              _getTracingDataCursiveUpper(letter: letters)
                .first
                .copyWith(
                  innerPaintColor: char.traceShapeOptions.innerPaintColor,
                  outerPaintColor: char.traceShapeOptions.outerPaintColor,
                  indexColor:     char.traceShapeOptions.indexColor,
                  dottedColor:    char.traceShapeOptions.dottedColor,
                )
            );
          // Adiciona modelo de traçado para letra minúscula
          } else if (_isLowerCursiveLower(letters)) {
          tracingDataList.add(
            _getTracingDataCursiveLower(letter: letters).first.copyWith(
              innerPaintColor: char.traceShapeOptions.innerPaintColor,
              outerPaintColor: char.traceShapeOptions.outerPaintColor,
              indexColor: char.traceShapeOptions.indexColor,
              dottedColor: char.traceShapeOptions.dottedColor,
            ),
          );

          }
          else {
            throw Exception('Unsupported character type for tracing.');
          }
        }
      } else {
        throw Exception('Unknown StateOfTracing value');
      }

      return tracingDataList;
    }

  /// Constrói e retorna um modelo de traçado com os parâmetros fornecidos
  TraceModel _buildCursiveTraceModel({
    required Size letterViewSize,
    required String letterPath,
    required String indexPath,
    required String dottedPath,
    required String pointsJsonFile,
    required double scaleIndexPath,
    required double scaledottedPath,
    required Size positionIndexPath,
    required Size positionDottedPath,
  }) {
    return TraceModel(
      letterViewSize: letterViewSize,
      letterPath: letterPath,
      indexPath: indexPath,
      dottedPath: dottedPath,
      pointsJsonFile: pointsJsonFile,
      scaleIndexPath: scaleIndexPath,
      scaledottedPath: scaledottedPath,
      positionIndexPath: positionIndexPath,
      positionDottedPath: positionDottedPath,

      // Estilos e cores padrão para o traçado
      strokeWidth: 20,
      disableDividedStrokes: true,
      dottedColor: AppColors.white,
      indexColor: AppColors.grey,
      indexPathPaintStyle: PaintingStyle.fill,
      dottedPathPaintStyle: PaintingStyle.stroke,
      innerPaintColor: AppColors.lightBlue,
      outerPaintColor: AppColors.darkBlue
    );
  }

  /// Retorna o modelo de traçado para letras cursivas MAIÚSCULAS
  List<TraceModel> _getTracingDataCursiveUpper({
    required String letter,
    Size sizeOfLetter = const Size(500, 500),
  }) {
    // Converte a String em enum, exatamente como em _getTracingDataPhonics
    CursiveUpperLetters currentLetter =
        _detectCursiveUpper(letter: letter);

    switch (currentLetter) {
      case CursiveUpperLetters.A:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            
            // Paths específicos para a letra A:
            letterPath: CursiveUpperSvgs.shapeLetterA,
            indexPath: CursiveUpperSvgs.indexLetterA,
            dottedPath: CursiveUpperSvgs.dottedLetterA,
            pointsJsonFile: ShapePointsManger.aCursiveUpper,
            scaleIndexPath: 0.2,
            scaledottedPath: 0.9,
            positionIndexPath: const Size(300, 400),
            positionDottedPath: const Size(1650, 1520),
          ),
        ];

      case CursiveUpperLetters.B:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra B:
            letterPath: CursiveUpperSvgs.shapeLetterB,
            indexPath: CursiveUpperSvgs.indexLetterB,
            dottedPath: CursiveUpperSvgs.dottedLetterB,
            pointsJsonFile: ShapePointsManger.bCursiveUpper,
            scaleIndexPath: 0.3,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(320, 160),
            positionDottedPath: const Size(1500, 1400),

          ),
        ];

      case CursiveUpperLetters.C:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra C:
            letterPath: CursiveUpperSvgs.shapeLetterC,
            indexPath: CursiveUpperSvgs.indexLetterC,
            dottedPath: CursiveUpperSvgs.dottedLetterC,
            pointsJsonFile: ShapePointsManger.cCursiveUpper,
            scaleIndexPath: 0.08,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(380, 0),
            positionDottedPath: const Size(1920, 1505),
          ),
        ];
      case CursiveUpperLetters.D:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra D:
            letterPath: CursiveUpperSvgs.shapeLetterD,
            indexPath: CursiveUpperSvgs.indexLetterD,
            dottedPath: CursiveUpperSvgs.dottedLetterD,
            pointsJsonFile: ShapePointsManger.dCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(330, -100),
            positionDottedPath: const Size(1550, 1505),
          ),
        ];
      case CursiveUpperLetters.E:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra E:
            letterPath: CursiveUpperSvgs.shapeLetterE,
            indexPath: CursiveUpperSvgs.indexLetterE,
            dottedPath: CursiveUpperSvgs.dottedLetterE,
            pointsJsonFile: ShapePointsManger.eCursiveUpper,
            scaleIndexPath: 0.6,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(150,-100),
            positionDottedPath: const Size(1720, 1420),
            )
        ];
      case CursiveUpperLetters.F:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra F:
            letterPath: CursiveUpperSvgs.shapeLetterF,
            indexPath: CursiveUpperSvgs.indexLetterF,
            dottedPath: CursiveUpperSvgs.dottedLetterF,
            pointsJsonFile: ShapePointsManger.fCursiveUpper,
            scaleIndexPath: 0.5,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(150,0),
            positionDottedPath: const Size(1560, 1410),
          ),
        ];
      case CursiveUpperLetters.G:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra G:
            letterPath: CursiveUpperSvgs.shapeLetterG,
            indexPath: CursiveUpperSvgs.indexLetterG,
            dottedPath: CursiveUpperSvgs.dottedLetterG,
            pointsJsonFile: ShapePointsManger.gCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(250,300),
            positionDottedPath: const Size(1720, 1910),
          ),
        ];
      case CursiveUpperLetters.H:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra H:
            letterPath: CursiveUpperSvgs.shapeLetterH,
            indexPath: CursiveUpperSvgs.indexLetterH,
            dottedPath: CursiveUpperSvgs.dottedLetterH,
            pointsJsonFile: ShapePointsManger.hCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(200,-100),
            positionDottedPath: const Size(1600, 1380),
          ),
        ];
      case CursiveUpperLetters.I:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra I:
            letterPath: CursiveUpperSvgs.shapeLetterI,
            indexPath: CursiveUpperSvgs.indexLetterI,
            dottedPath: CursiveUpperSvgs.dottedLetterI,
            pointsJsonFile: ShapePointsManger.iCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(300,-100),
            positionDottedPath: const Size(1660, 1350),
          ),
        ];
      case CursiveUpperLetters.J:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra J:
            letterPath: CursiveUpperSvgs.shapeLetterJ,
            indexPath: CursiveUpperSvgs.indexLetterJ,
            dottedPath: CursiveUpperSvgs.dottedLetterJ,
            pointsJsonFile: ShapePointsManger.jCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(350,300),
            positionDottedPath: const Size(1660, 1750),
          ),
        ];
    case CursiveUpperLetters.L:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra L:
            letterPath: CursiveUpperSvgs.shapeLetterL,
            indexPath: CursiveUpperSvgs.indexLetterL,
            dottedPath: CursiveUpperSvgs.dottedLetterL,
            pointsJsonFile: ShapePointsManger.lCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(150,50),
            positionDottedPath: const Size(1760, 1580),
          ),
        ];
    case CursiveUpperLetters.M:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra M:
            letterPath: CursiveUpperSvgs.shapeLetterM,
            indexPath: CursiveUpperSvgs.indexLetterM,
            dottedPath: CursiveUpperSvgs.dottedLetterM,
            pointsJsonFile: ShapePointsManger.mCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(150,150),
            positionDottedPath: const Size(1460, 1400),
          ),
        ];
      case CursiveUpperLetters.N:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra N:
            letterPath: CursiveUpperSvgs.shapeLetterN,
            indexPath: CursiveUpperSvgs.indexLetterN,
            dottedPath: CursiveUpperSvgs.dottedLetterN,
            pointsJsonFile: ShapePointsManger.nCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(00,200),
            positionDottedPath: const Size(1360, 1350),
          ),
        ];
      case CursiveUpperLetters.O:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra O:
            letterPath: CursiveUpperSvgs.shapeLetterO,
            indexPath: CursiveUpperSvgs.indexLetterO,
            dottedPath: CursiveUpperSvgs.dottedLetterO,
            pointsJsonFile: ShapePointsManger.oCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(450,-150),
            positionDottedPath: const Size(1710, 1450),
          ),
        ];
      case CursiveUpperLetters.P:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra P:
            letterPath: CursiveUpperSvgs.shapeLetterP,
            indexPath: CursiveUpperSvgs.indexLetterP,
            dottedPath: CursiveUpperSvgs.dottedLetterP,
            pointsJsonFile: ShapePointsManger.pCursiveUpper,
            scaleIndexPath: 0.2,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(250,0),
            positionDottedPath: const Size(1670, 1520),
          ),
        ];
    case CursiveUpperLetters.Q:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra Q:
            letterPath: CursiveUpperSvgs.shapeLetterQ,
            indexPath: CursiveUpperSvgs.indexLetterQ,
            dottedPath: CursiveUpperSvgs.dottedLetterQ,
            pointsJsonFile: ShapePointsManger.qCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(200,0),
            positionDottedPath: const Size(1700, 1520),
          ),
        ];
      case CursiveUpperLetters.R:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra R:
            letterPath: CursiveUpperSvgs.shapeLetterR,
            indexPath: CursiveUpperSvgs.indexLetterR,
            dottedPath: CursiveUpperSvgs.dottedLetterR,
            pointsJsonFile: ShapePointsManger.rCursiveUpper,
            scaleIndexPath: 0.25,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(300,0),
            positionDottedPath: const Size(1700, 1520),
          ),
        ];
      case CursiveUpperLetters.S:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra S:
            letterPath: CursiveUpperSvgs.shapeLetterS,
            indexPath: CursiveUpperSvgs.indexLetterS,
            dottedPath: CursiveUpperSvgs.dottedLetterS,
            pointsJsonFile: ShapePointsManger.sCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(300,0),
            positionDottedPath: const Size(1780, 1500),
          ),
        ];
      case CursiveUpperLetters.T:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra S:
            letterPath: CursiveUpperSvgs.shapeLetterT,
            indexPath: CursiveUpperSvgs.indexLetterT,
            dottedPath: CursiveUpperSvgs.dottedLetterT,
            pointsJsonFile: ShapePointsManger.tCursiveUpper,
            scaleIndexPath: 0.25,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(600,-100),
            positionDottedPath: const Size(1900, 1430),
          ),
        ];
      case CursiveUpperLetters.U:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra U:
            letterPath: CursiveUpperSvgs.shapeLetterU,
            indexPath: CursiveUpperSvgs.indexLetterU,
            dottedPath: CursiveUpperSvgs.dottedLetterU,
            pointsJsonFile: ShapePointsManger.uCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(400,-100),
            positionDottedPath: const Size(1550, 1230),
          ),
        ];
      case CursiveUpperLetters.V:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra V:
            letterPath: CursiveUpperSvgs.shapeLetterV,
            indexPath: CursiveUpperSvgs.indexLetterV,
            dottedPath: CursiveUpperSvgs.dottedLetterV,
            pointsJsonFile: ShapePointsManger.vCursiveUpper,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(1000,0),
            positionDottedPath: const Size(2360, 1490),
          ),
        ];
      case CursiveUpperLetters.X:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra X:
            letterPath: CursiveUpperSvgs.shapeLetterX,
            indexPath: CursiveUpperSvgs.indexLetterX,
            dottedPath: CursiveUpperSvgs.dottedLetterX,
            pointsJsonFile: ShapePointsManger.xCursiveUpper,
            scaleIndexPath: 0.7,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(100,0),
            positionDottedPath: const Size(1500, 1420),
          ),
        ];
      case CursiveUpperLetters.Z:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra Z:
            letterPath: CursiveUpperSvgs.shapeLetterZ,
            indexPath: CursiveUpperSvgs.indexLetterZ,
            dottedPath: CursiveUpperSvgs.dottedLetterZ,
            pointsJsonFile: ShapePointsManger.zCursiveUpper,
            scaleIndexPath: 0.6,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(0,-200),
            positionDottedPath: const Size(1600, 1480),
          ),
        ];    
        }
  }
  
  /// Retorna o modelo de traçado para letras cursivas minúsculas
  List<TraceModel> _getTracingDataCursiveLower({
    required String letter,
    Size sizeOfLetter = const Size(400, 400),
  }) {
    CursiveLowerLetters currentLetter = _detectCursiveLower(letter: letter);

    switch (currentLetter) {
      case CursiveLowerLetters.a:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra a:
            letterPath: cursiveLowerSvgs.shapeLettera,
            indexPath: cursiveLowerSvgs.indexLettera,
            dottedPath: cursiveLowerSvgs.dottedLettera,
            pointsJsonFile: ShapePointsManger.aCursiveLower,
            scaleIndexPath: 0.15,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(180, -100),
            positionDottedPath: const Size(580, 600),
          ),
        ];
      case CursiveLowerLetters.b:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra b:
            letterPath: cursiveLowerSvgs.shapeLetterb,
            indexPath: cursiveLowerSvgs.indexLetterb,
            dottedPath: cursiveLowerSvgs.dottedLetterb,
            pointsJsonFile: ShapePointsManger.bCursiveLower,
            scaleIndexPath: 0.08,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(580,700),
            positionDottedPath: const Size(1880, 1460),
          ),
        ];
      case CursiveLowerLetters.c:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra c:
            letterPath: cursiveLowerSvgs.shapeLetterc,
            indexPath: cursiveLowerSvgs.indexLetterc,
            dottedPath: cursiveLowerSvgs.dottedLetterc,
            pointsJsonFile: ShapePointsManger.cCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(100, -30),
            positionDottedPath: const Size(650, 620),
          ),
        ];
      case CursiveLowerLetters.d:
        return [
          TraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra d:
            letterPath: cursiveLowerSvgs.shapeLetterd,
            indexPath: cursiveLowerSvgs.indexLetterd,
            dottedPath: cursiveLowerSvgs.dottedLetterd,
            pointsJsonFile: ShapePointsManger.dCursiveLower,
            scaleIndexPath: 0.6,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(500,-100),
            positionDottedPath: const Size(1600, 1360),
          ),
        ];
      case CursiveLowerLetters.e:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra e:
            letterPath: cursiveLowerSvgs.shapeLettere,
            indexPath: cursiveLowerSvgs.indexLettere,
            dottedPath: cursiveLowerSvgs.dottedLettere,
            pointsJsonFile: ShapePointsManger.eCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(0,150),
            positionDottedPath: const Size(700, 625),
          ),
        ];
      case CursiveLowerLetters.f:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra f:
            letterPath: cursiveLowerSvgs.shapeLetterf,
            indexPath: cursiveLowerSvgs.indexLetterf,
            dottedPath: cursiveLowerSvgs.dottedLetterf,
            pointsJsonFile: ShapePointsManger.fCursiveLower,
            scaleIndexPath: 0.08,
            scaledottedPath: 0.97,
            positionIndexPath: const Size(850,580),
            positionDottedPath: const Size(2605, 1980),
          ),
        ];
      case CursiveLowerLetters.g:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra g:
            letterPath: cursiveLowerSvgs.shapeLetterg,
            indexPath: cursiveLowerSvgs.indexLetterg,
            dottedPath: cursiveLowerSvgs.dottedLetterg,
            pointsJsonFile: ShapePointsManger.gCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(570,210),
            positionDottedPath: const Size(1590, 1660),
          ),
        ];
      case CursiveLowerLetters.h:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra h:
            letterPath: cursiveLowerSvgs.shapeLetterh,
            indexPath: cursiveLowerSvgs.indexLetterh,
            dottedPath: cursiveLowerSvgs.dottedLetterh,
            pointsJsonFile: ShapePointsManger.hCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(350,310),
            positionDottedPath: const Size(1780, 1410),
          ),
        ];
      case CursiveLowerLetters.i:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra i:
            letterPath: cursiveLowerSvgs.shapeLetteri,
            indexPath: cursiveLowerSvgs.indexLetteri,
            dottedPath: cursiveLowerSvgs.dottedLetteri,
            pointsJsonFile: ShapePointsManger.iCursiveLower,
            scaleIndexPath: 0.8,
            scaledottedPath: 0.70,
            positionIndexPath: const Size(270,100),
            positionDottedPath: const Size(950,780),
          ),
        ];
      case CursiveLowerLetters.j:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths específicos para a letra j:
            letterPath: cursiveLowerSvgs.shapeLetterj,
            indexPath: cursiveLowerSvgs.indexLetterj,
            dottedPath: cursiveLowerSvgs.dottedLetterj,
            pointsJsonFile: ShapePointsManger.jCursiveLower,
            scaleIndexPath: 0.6,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(1200,600),
            positionDottedPath: const Size(2380,2180),
          ),
        ];
      case CursiveLowerLetters.l:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra l:
            letterPath: cursiveLowerSvgs.shapeLetterl,
            indexPath: cursiveLowerSvgs.indexLetterl,
            dottedPath: cursiveLowerSvgs.dottedLetterl,
            pointsJsonFile: ShapePointsManger.lCursiveLower,
            scaleIndexPath: 0.08,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(550,650),
            positionDottedPath: const Size(1850,1400),
          ),
        ];
      case CursiveLowerLetters.m:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra m:
            letterPath: cursiveLowerSvgs.shapeLetterm,
            indexPath: cursiveLowerSvgs.indexLetterm,
            dottedPath: cursiveLowerSvgs.dottedLetterm,
            pointsJsonFile: ShapePointsManger.mCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(-200,400),
            positionDottedPath: const Size(1210,1425),
          ),
        ];
      case CursiveLowerLetters.n:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra n:
            letterPath: cursiveLowerSvgs.shapeLettern,
            indexPath: cursiveLowerSvgs.indexLettern,
            dottedPath: cursiveLowerSvgs.dottedLettern,
            pointsJsonFile: ShapePointsManger.nCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(-120,120),
            positionDottedPath: const Size(840,890),
          ),
        ];
      case CursiveLowerLetters.o:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra o:
            letterPath: cursiveLowerSvgs.shapeLettero,
            indexPath: cursiveLowerSvgs.indexLettero,
            dottedPath: cursiveLowerSvgs.dottedLettero,
            pointsJsonFile: ShapePointsManger.oCursiveLower,
            scaleIndexPath: 0.10,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(-100,0),
            positionDottedPath: const Size(620,610),
          ),
        ];
      case CursiveLowerLetters.p:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra p:
            letterPath: cursiveLowerSvgs.shapeLetterp,
            indexPath: cursiveLowerSvgs.indexLetterp,
            dottedPath: cursiveLowerSvgs.dottedLetterp,
            pointsJsonFile: ShapePointsManger.pCursiveLower,
            scaleIndexPath: 0.35,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(600,150),
            positionDottedPath: const Size(2260,1800),
          ),
        ];
      case CursiveLowerLetters.q:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra q:
            letterPath: cursiveLowerSvgs.shapeLetterq,
            indexPath: cursiveLowerSvgs.indexLetterq,
            dottedPath: cursiveLowerSvgs.dottedLetterq,
            pointsJsonFile: ShapePointsManger.qCursiveLower,
            scaleIndexPath: 0.10,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(450,500),
            positionDottedPath: const Size(1500,1820),
          ),
        ];
      case CursiveLowerLetters.r:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra r:
            letterPath: cursiveLowerSvgs.shapeLetterr,
            indexPath: cursiveLowerSvgs.indexLetterr,
            dottedPath: cursiveLowerSvgs.dottedLetterr,
            pointsJsonFile: ShapePointsManger.rCursiveLower,
            scaleIndexPath: 0.12,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(0,50),
            positionDottedPath: const Size(770,660),
          ),
        ];
      case CursiveLowerLetters.s:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra s:
            letterPath: cursiveLowerSvgs.shapeLetters,
            indexPath: cursiveLowerSvgs.indexLetters,
            dottedPath: cursiveLowerSvgs.dottedLetters,
            pointsJsonFile: ShapePointsManger.sCursiveLower,
            scaleIndexPath: 0.12,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(-50,50),
            positionDottedPath: const Size(720,660),
          ),
        ];
      case CursiveLowerLetters.t:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra t:
            letterPath: cursiveLowerSvgs.shapeLettert,
            indexPath: cursiveLowerSvgs.indexLettert,
            dottedPath: cursiveLowerSvgs.dottedLettert,
            pointsJsonFile: ShapePointsManger.tCursiveLower,
            scaleIndexPath: 0.7,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(400,0),
            positionDottedPath: const Size(1820,1300),
          ),
        ];
      case CursiveLowerLetters.u:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra u:
            letterPath: cursiveLowerSvgs.shapeLetteru,
            indexPath: cursiveLowerSvgs.indexLetteru,
            dottedPath: cursiveLowerSvgs.dottedLetteru,
            pointsJsonFile: ShapePointsManger.uCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(-100,150),
            positionDottedPath: const Size(660,650),
          ),
        ];
      case CursiveLowerLetters.v:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra v:
            letterPath: cursiveLowerSvgs.shapeLetterv,
            indexPath: cursiveLowerSvgs.indexLetterv,
            dottedPath: cursiveLowerSvgs.dottedLetterv,
            pointsJsonFile: ShapePointsManger.vCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(-150,200),
            positionDottedPath: const Size(700,710),
          ),
        ];
      case CursiveLowerLetters.x:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra x:
            letterPath: cursiveLowerSvgs.shapeLetterx,
            indexPath: cursiveLowerSvgs.indexLetterx,
            dottedPath: cursiveLowerSvgs.dottedLetterx,
            pointsJsonFile: ShapePointsManger.xCursiveLower,
            scaleIndexPath: 1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(-80,-50),
            positionDottedPath: const Size(800,855),
          ),
        ];
      case CursiveLowerLetters.z:
        return [
          _buildCursiveTraceModel(
            letterViewSize: sizeOfLetter,
            // Paths para a letra z:
            letterPath: cursiveLowerSvgs.shapeLetterz,
            indexPath: cursiveLowerSvgs.indexLetterz,
            dottedPath: cursiveLowerSvgs.dottedLetterz,
            pointsJsonFile: ShapePointsManger.zCursiveLower,
            scaleIndexPath: 0.1,
            scaledottedPath: 0.95,
            positionIndexPath: const Size(250,100),
            positionDottedPath: const Size(1680,1420),
          ),
        ];
            }
  }

  /// Retorna os dados de traçado para uma palavra completa
  /// (apenas letras maiúsculas suportadas neste método)
  /// Melhoria para o futuro
  List<TraceModel> getTraceWords({
    required TraceWordModel wordWithOption,
    Size sizeOfLetter = const Size(500, 500),
  }) {
    List<TraceModel> letters = [];
    int i = 0;
    final word = wordWithOption.word;

    while (i < word.length) {
      String currentChar = word[i];

      bool isNextSpace = (i + 1 < word.length) && word[i + 1] == ' ';

      // Adaptado para suportar apenas letras cursivas maiúsculas (A-Z)
      if (_isUpperCursiveUpper(currentChar)) {
        final trace = _getTracingDataCursiveUpper(letter: currentChar)
            .first
            .copyWith(isSpace: isNextSpace);
        letters.add(trace);
      }

      // Comentado: suporte para números
      /*
      else if (_isNumber(currentChar)) {
        letters.add(_getTracingDataNumbers(number: currentChar).first.copyWith(
          isSpace: isNextSpace,
        ));
      }
      */

      // Comentado: suporte para fonemas minúsculos
      /*
      else if (_isPhonicsCharacter(currentChar)) {
        letters.add(
          _getTracingDataPhonics(letter: currentChar.toLowerCase())
              .first
              .copyWith(isSpace: isNextSpace),
        );
      }
      */

      // Comentado: suporte para fonemas maiúsculos
      /*
      else if (_isUpperCasePhonicsCharacter(currentChar)) {
        final uppers = _getTracingDataPhonicsUp(letter: currentChar.toLowerCase());
        final newBigSizedUppers = uppers
            .map((up) => up.copyWith(letterViewSize: const Size(300, 300)))
            .first;
        letters.add(newBigSizedUppers.copyWith(isSpace: isNextSpace));
      }
      */

      else {
        throw Exception('Unsupported character in tracing word: $currentChar');
      }

      i++;
    }

    return letters
        .map((e) => e.copyWith(
              innerPaintColor: wordWithOption.traceShapeOptions.innerPaintColor,
              outerPaintColor: wordWithOption.traceShapeOptions.outerPaintColor,
              indexColor: wordWithOption.traceShapeOptions.indexColor,
              dottedColor: wordWithOption.traceShapeOptions.dottedColor,
            ))
        .toList();
  }

}
