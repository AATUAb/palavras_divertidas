//machine.dart

import 'package:flutter/material.dart';
import 'package:mundodaspalavras/themes/colors.dart';
import 'package:mundodaspalavras/games/writing_game/phonetics_constants/pt_shape_path.dart';
import 'package:mundodaspalavras/games/writing_game/phonetics_constants/numbers_svg.dart';
import 'package:mundodaspalavras/games/writing_game/phonetics_constants/shape_paths.dart';
import 'package:mundodaspalavras/games/writing_game/points_manager/shape_points_manager.dart';
import 'package:mundodaspalavras/games/writing_game/tracing/writing_models.dart';
import 'package:mundodaspalavras/games/writing_game/enums/shape_enums.dart';


class TypeExtensionTracking {
  PhonicsLetters _detectTheCurrentEnumFromPhonics({required String letter}) {
    if (letter == 'a') {
      return PhonicsLetters.a;
    } else if (letter == 'q') {
      return PhonicsLetters.q;
    } else if (letter == 'e') {
      return PhonicsLetters.e;
    } else if (letter == 'r') {
      return PhonicsLetters.r;
    } else if (letter == 't') {
      return PhonicsLetters.t;
    } else if (letter == 'u') {
      return PhonicsLetters.u;
    } else if (letter == 'i') {
      return PhonicsLetters.i;
    } else if (letter == 'o') {
      return PhonicsLetters.o;
    } else if (letter == 'p') {
      return PhonicsLetters.p;
    } else if (letter == 's') {
      return PhonicsLetters.s;
    } else if (letter == 'd') {
      return PhonicsLetters.d;
    } else if (letter == 'f') {
      return PhonicsLetters.f;
    } else if (letter == 'g') {
      return PhonicsLetters.g;
    } else if (letter == 'h') {
      return PhonicsLetters.h;
    } else if (letter == 'j') {
      return PhonicsLetters.j;
    } else if (letter == 'l') {
      return PhonicsLetters.l;
    } else if (letter == 'z') {
      return PhonicsLetters.z;
    } else if (letter == 'x') {
      return PhonicsLetters.x;
    } else if (letter == 'c') {
      return PhonicsLetters.c;
    } else if (letter == 'v') {
      return PhonicsLetters.v;
    } else if (letter == 'b') {
      return PhonicsLetters.b;
    } else if (letter == 'n') {
      return PhonicsLetters.n;
    } else if (letter == 'm') {
      return PhonicsLetters.m;
    } else {
      throw Exception('Unsupported character type for tracing.');
    }
  }

  List<TraceModel> getTracingData({
    List<TraceCharModel>? chars,
    TraceWordModel? word,
    required StateOfTracing currentOfTracking,
  }) {
  
    List<TraceModel> tracingDataList = [];

    if (currentOfTracking == StateOfTracing.traceWords) {
      tracingDataList.addAll(getTraceWords(wordWithOption: word!));
    } else if (currentOfTracking == StateOfTracing.chars) {
        if(chars==null){
      return [];
    }
      for (var char in chars) {
        final letters = char.char;

        if (_isNumber(letters)) {
          tracingDataList
              .add(_getTracingDataNumbers(number: letters).first.copyWith(
                    innerPaintColor: char.traceShapeOptions.innerPaintColor,
                    outerPaintColor: char.traceShapeOptions.outerPaintColor,
                    indexColor: char.traceShapeOptions.indexColor,
                    dottedColor: char.traceShapeOptions.dottedColor,
                  ));
        } else if (_isLowerCharacter(letters)) {
          tracingDataList.add(
              _getTracingDataPhonics(letter: letters.toLowerCase())
                  .first
                  .copyWith(
                    innerPaintColor: char.traceShapeOptions.innerPaintColor,
                    outerPaintColor: char.traceShapeOptions.outerPaintColor,
                    indexColor: char.traceShapeOptions.indexColor,
                    dottedColor: char.traceShapeOptions.dottedColor,
                  ));
        } else if (_isUpperCharacter(letters)) {
          final uppers =
              _getTracingDataPhonicsUp(letter: letters.toLowerCase());
          final newBigSizedUppers = uppers
              .map((up) => up.copyWith(letterViewSize: const Size(300, 300)))
              .toList();
          tracingDataList.add(newBigSizedUppers.first.copyWith(
            innerPaintColor: char.traceShapeOptions.innerPaintColor,
            outerPaintColor: char.traceShapeOptions.outerPaintColor,
            indexColor: char.traceShapeOptions.indexColor,
            dottedColor: char.traceShapeOptions.dottedColor,
          ));
        } else {
          throw Exception('Unsupported character type for tracing.');
        }
      }
    } else {
      throw Exception('Unknown StateOfTracing value');
    }

    return tracingDataList; // Return the combined tracing data list
  }

// Helper functions to detect the type of letter

  bool _isNumber(String letter) {
    // Check if the letter is a number
    return RegExp(r'^(10|[0-9])$').hasMatch(letter);
  }

  bool _isLowerCharacter(String letter) {
    // Check if the letter is a valid phonics character (assuming it's A-Z or a-z)
    return RegExp(r'^[a-z]$').hasMatch(letter);
  }

  bool _isUpperCharacter(String letter) {
    // Check if the letter is an uppercase phonics character
    return RegExp(r'^[A-Z]$').hasMatch(letter);
  }

  TraceModel _buildTraceModel({
    required Size letterViewSize,
    required String letterPath,
    required String indexPath,
    required String dottedPath,
    required String pointsJsonFile,
    required double scaleIndexPath,
    required double scaledottedPath,
    required Size positionIndexPath,
    Size positionDottedPath = const Size(0, 0),

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
      

      // Parâmetros fixos:
      
      strokeWidth: 70,
      disableDividedStrokes: true,
      dottedColor: AppColors.white,
      indexColor: AppColors.grey,
      indexPathPaintStyle: PaintingStyle.fill,
      dottedPathPaintStyle: PaintingStyle.stroke,
      innerPaintColor: AppColors.lightBlue,
      outerPaintColor: AppColors.darkBlue
    );
  }

  List<TraceModel> _getTracingDataNumbers({required String number,
    Size sizeOfLetter = const Size(200, 200)}) {
    List<TraceModel> listOfTraceModel = [];

    switch (number) {
      case '1':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(-34, -60),
            positionDottedPath: const Size(-28, 6),
            scaledottedPath: .8,
            scaleIndexPath: .4,
            dottedPath: NumberSvgs.shapeNumber1Dotted,
            indexPath: NumberSvgs.shapeNumber1Index,
            letterPath: NumberSvgs.shapeNumber1,
            pointsJsonFile: ShapePointsManger.number1,));
        break;

      case '2':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(-50, 20),
            positionDottedPath: const Size(0, -5),
            scaleIndexPath: .8,
            scaledottedPath: 1,
            dottedPath: NumberSvgs.shapeNumber2Dotted,
            indexPath: NumberSvgs.shapeNumber2Index,
            letterPath: NumberSvgs.shapeNumber2,
            pointsJsonFile: ShapePointsManger.number2,
            ));
        break;
      case '3':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(-25, -30),
            positionDottedPath: const Size(-5, 0),
            scaleIndexPath: .4,
            scaledottedPath: .9,
            dottedPath: NumberSvgs.shapeNumber3Dotted,
            indexPath: NumberSvgs.shapeNumber3Index,
            letterPath: NumberSvgs.shapeNumber3,
            pointsJsonFile: ShapePointsManger.number3,
            ));
        break;
      case '4':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(-10, -33),
            positionDottedPath: const Size(-3, -10),
            scaledottedPath: .85,
            scaleIndexPath: .66, 
            dottedPath: NumberSvgs.shapeNumber4Dotted,
            indexPath: NumberSvgs.shapeNumber4Index,
            letterPath: NumberSvgs.shapeNumber4,
            pointsJsonFile: ShapePointsManger.number4,
        ));
        break;
      case '5':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(0, -50),
            positionDottedPath: const Size(-5, 0),
            scaleIndexPath: .5,
            scaledottedPath: .95,
            dottedPath: NumberSvgs.shapeNumber5Dotted,
            indexPath: NumberSvgs.shapeNumber5Index,
            letterPath: NumberSvgs.shapeNumber5,
            pointsJsonFile: ShapePointsManger.number5
            ));
        break;
      case '6':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(5, -90),
            positionDottedPath: const Size(-5, 0),
            scaleIndexPath: .1,
            scaledottedPath: .9,
            dottedPath: NumberSvgs.shapeNumber6Dotted,
            indexPath: NumberSvgs.shapeNumber6Index,
            letterPath: NumberSvgs.shapeNumber6,
            pointsJsonFile: ShapePointsManger.number6,
        ));
        break;
      case '7':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(0, -90),
            positionDottedPath: const Size(0, -5),
            scaledottedPath: .9,
            scaleIndexPath: .6,
            dottedPath: NumberSvgs.shapeNumber7Dotted,
            indexPath: NumberSvgs.shapeNumber7Index,
            letterPath: NumberSvgs.shapeNumber7,
            pointsJsonFile: ShapePointsManger.number7,
            ));
        break;
      case '8':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(50, -50),
            positionDottedPath: const Size(5, 0),
            scaleIndexPath: .07,
            scaledottedPath: 1,
            dottedPath: NumberSvgs.shapeNumber8Dotted,
            indexPath: NumberSvgs.shapeNumber8Index,
            letterPath: NumberSvgs.shapeNumber8,
            pointsJsonFile: ShapePointsManger.number8,
            ));
        break;
      case '9':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(55, -30),
            positionDottedPath: const Size(0, -5),
            scaleIndexPath: .18,
            scaledottedPath: .9,
            dottedPath: NumberSvgs.shapeNumber9Dotted,
            indexPath: NumberSvgs.shapeNumber9Index,
            letterPath: NumberSvgs.shapeNumber9,
            pointsJsonFile: ShapePointsManger.number9,
        ));
        break;
      case '0':
        listOfTraceModel.add(_buildTraceModel(
            letterViewSize: sizeOfLetter,
            positionIndexPath: const Size(-10, -90),
            positionDottedPath: const Size(-5, -5),
            scaledottedPath: .9,
            scaleIndexPath: .08,
            dottedPath: NumberSvgs.shapeNumber0Dotted,
            indexPath: NumberSvgs.shapeNumber0Index,
            letterPath: NumberSvgs.shapeNumber0,
            pointsJsonFile: ShapePointsManger.number0,
        ));
        break;
    }

    return listOfTraceModel;
  }

  List<TraceModel> getTraceWords({
    required TraceWordModel wordWithOption,
    Size sizeOfLetter = const Size(500, 500),
  }) {
    List<TraceModel> letters = [];
    int i = 0;
    final word = wordWithOption.word;
    while (i < word.length) {
      if (word[i] == '1' && i + 1 < word.length && word[i + 1] == '0') {
        // Check if current character is '1' and next is '0' (treat it as 10)
        if (word[i] == '1' && word[i + 1] == '0') {
          letters.add(_getTracingDataNumbers(number: '10').first.copyWith(
                isSpace: (i + 2 < word.length &&
                    word[i + 2] == ' '), // Check if next character is a space
              ));
          i += 2; // Skip the next character (i + 1) since we've handled '10'
          continue;
        }
      }

      bool isNextSpace = (i + 1 < word.length) &&
          word[i + 1] == ' '; // Check if the next character is a space

      if (_isNumber(word[i])) {
        letters.add(_getTracingDataNumbers(number: word[i]).first.copyWith(
              isSpace: isNextSpace,
            ));
      } else if (_isLowerCharacter(word[i])) {
        letters.add(_getTracingDataPhonics(letter: word[i].toLowerCase())
            .first
            .copyWith(
              isSpace: isNextSpace,
            ));
      } else if (_isUpperCharacter(word[i])) {
        final uppers = _getTracingDataPhonicsUp(letter: word[i].toLowerCase());
        final newBigSizedUppers = uppers
            .map((up) => up.copyWith(letterViewSize: const Size(300, 300)))
            .first;
        letters.add(newBigSizedUppers.copyWith(isSpace: isNextSpace));
      }

      i++; // Move to the next character
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

  List<TraceModel> _getTracingDataPhonics(
      {required String letter, Size sizeOfLetter = const Size(200, 200)}) {
    PhonicsLetters currentLetter =
        _detectTheCurrentEnumFromPhonics(letter: letter);

    switch (currentLetter) {
      case PhonicsLetters.n:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.nlowerShapeDotted,
              indexPath: PTShapePaths.nlowerShapeIndex,
              scaleIndexPath: .3,
              positionDottedPath: const Size(0, 0),
              positionIndexPath: const Size(-50, -65),
              scaledottedPath: .75,
              letterPath: PTShapePaths.nlowerShape,
              pointsJsonFile: ShapePointsManger.nLowerShape,
          )
        ];
      case PhonicsLetters.e:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.eLowerShapeDotted,
              indexPath: PTShapePaths.eLowerShapeIndex,
              scaleIndexPath: .12,
              positionDottedPath: const Size(0, 0),
              positionIndexPath: const Size(-20, -5),
              scaledottedPath: .75,
              letterPath: PTShapePaths.eLowerShape,
              pointsJsonFile: ShapePointsManger.eLowerShape,
              ),
        ];
      case PhonicsLetters.d:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.dLowerShapeDotted,
              indexPath: PTShapePaths.dLowerShapeIndex,
              scaleIndexPath: .35,
              positionDottedPath: const Size(0, 10),
              positionIndexPath: const Size(30, -60),
              scaledottedPath: .85,
              letterPath: PTShapePaths.dLowerShape,
              pointsJsonFile: ShapePointsManger.dlowerShape
              ),
        ];

      case PhonicsLetters.o:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.oShapeBigShapeDotted,
              indexPath: PTShapePaths.oShapeBigShapeIndex,
              scaleIndexPath: .15,
              positionDottedPath: const Size(5, 0),
              positionIndexPath: const Size(-10, -70),
              scaledottedPath: .85,
              letterPath: PTShapePaths.oShapeBigShape,
              pointsJsonFile: ShapePointsManger.oUpperShape
              ),
        ];
      case PhonicsLetters.g:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.gLowrShapeDotted,
              indexPath: PTShapePaths.gLowrShapeIndex,
              scaleIndexPath: .2,
              positionIndexPath: const Size(40, -75),
              positionDottedPath: const Size(0, 0),
              scaledottedPath: .8,
              letterPath: PTShapePaths.gLowrShape,
              pointsJsonFile: ShapePointsManger.glowerShape)
        ];
      case PhonicsLetters.f:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.fLowerShapeDotted,
              indexPath: PTShapePaths.fLowerShapeIndex,
              scaleIndexPath: .4,
              positionIndexPath: const Size(10, -55),
              positionDottedPath: const Size(10, 0),
              scaledottedPath: .8,
              letterPath: PTShapePaths.fLowerShape,
              pointsJsonFile: ShapePointsManger.flowerShape
              ),
        ];
      case PhonicsLetters.b:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.blowerShapeDotted,
              indexPath: PTShapePaths.blowerShapeIndex,
              scaleIndexPath: .4,
              positionIndexPath: const Size(-30, -55),
              positionDottedPath: const Size(0, 10),
              scaledottedPath: .8,
              letterPath: PTShapePaths.blowerShape,
              pointsJsonFile: ShapePointsManger.blowerShape
              ),
        ];
      case PhonicsLetters.l:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.lLowerShapeDotted,
              indexPath: PTShapePaths.lLowerShapeIndex,
              scaleIndexPath: .1,
              scaledottedPath: .93,
              positionIndexPath: const Size(0, -55),
              positionDottedPath: const Size(5, 0),
              letterPath: PTShapePaths.lLowerShape,
              pointsJsonFile: ShapePointsManger.llowerShape)
        ];

      case PhonicsLetters.u:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.uLowerShapeDotted,
              indexPath: PTShapePaths.uLowerShapeIndex,
              scaleIndexPath: .7,
              scaledottedPath: .8,
              positionIndexPath: const Size(0, -70),
              positionDottedPath: const Size(0, 10),
              letterPath: PTShapePaths.uLowerShape,
              pointsJsonFile: ShapePointsManger.ulowerShape
              ),
        ];

      case PhonicsLetters.j:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.jlowerShapeDotetd,
              indexPath: PTShapePaths.jlowerShapeIndex,
              scaleIndexPath: .3,
              scaledottedPath: .65,
              positionIndexPath: const Size(22, -65),
              positionDottedPath: const Size(0, 25),
              letterPath: PTShapePaths.jlowerShape,
              pointsJsonFile: ShapePointsManger.jlowerShape
              ),
        ];

      case PhonicsLetters.h:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.hLowerShapeDotted,
              indexPath: PTShapePaths.hlowerShapeIndex,
              scaleIndexPath: .45,
              scaledottedPath: .85,
              positionIndexPath: const Size(-40, -45),
              positionDottedPath: const Size(0, 10),
              letterPath: PTShapePaths.hLoweCaseShape,
              pointsJsonFile: ShapePointsManger.hlowerShape
              ),
        ];

      case PhonicsLetters.s:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.sDotted,
              indexPath: ShapePaths.sIndex,
              scaleIndexPath: .65,
              positionIndexPath: const Size(-10, 0),
              scaledottedPath: .8,
              letterPath: ShapePaths.s3,
              pointsJsonFile: ShapePointsManger.sShape
              )
        ];
      case PhonicsLetters.a:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.aDotted,
              indexPath: ShapePaths.aIndex,
              scaleIndexPath: .3,
              positionIndexPath: const Size(50, -60),
              scaledottedPath: .8,
              letterPath: ShapePaths.aShape,
              pointsJsonFile: ShapePointsManger.aShape,)
        ];
      case PhonicsLetters.m:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.mDotted,
              indexPath: ShapePaths.mIndex,
              scaleIndexPath: .6,
              scaledottedPath: .8,
              positionIndexPath: const Size(-30, -50),
              letterPath: ShapePaths.mshape,
              pointsJsonFile: ShapePointsManger.mShape
              ),
        ];
      case PhonicsLetters.q:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.qshapeDotted,
              positionIndexPath: const Size(40, -80),
              indexPath: ShapePaths.qshapeIndex,
              scaleIndexPath: .2,
              scaledottedPath: .8,
              letterPath: ShapePaths.qshape,
              pointsJsonFile: ShapePointsManger.qShape,),
        ];
      case PhonicsLetters.v:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.vShapeDotted,
              positionIndexPath: const Size(-30, -0),
              indexPath: ShapePaths.vShapeIndex,
              scaleIndexPath: .9,
              scaledottedPath: .8,
              letterPath: ShapePaths.vshape,
              pointsJsonFile: ShapePointsManger.vShape,
              ),
        ];
      case PhonicsLetters.x:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.xDotted,
              positionIndexPath: const Size(-0, -75),
              indexPath: ShapePaths.xIndex,
              scaleIndexPath: .7,
              scaledottedPath: .8,
              letterPath: ShapePaths.xShape,
              pointsJsonFile: ShapePointsManger.xShape
              ),
        ];
      case PhonicsLetters.z:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.zShapeDotted,
              positionIndexPath: const Size(-80, -70),
              indexPath: ShapePaths.zShapeIndex,
              scaleIndexPath: .1,
              scaledottedPath: .8,
              letterPath: ShapePaths.zShape,
              pointsJsonFile: ShapePointsManger.zShape
              ),
        ];
      case PhonicsLetters.t:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.tshapeDotted,
              indexPath: ShapePaths.tshapeIndex,
              letterPath: ShapePaths.tShape,
              scaledottedPath: .8,
              scaleIndexPath: .33,
              positionDottedPath: const Size(2, 10),
              positionIndexPath: const Size(-30, -60),
              pointsJsonFile: ShapePointsManger.tShape,),
        ];
      case PhonicsLetters.c:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.cshapeDoted,
              indexPath: ShapePaths.cshapeIndex,
              scaleIndexPath: .1,
              positionIndexPath: const Size(140, -25),
              positionDottedPath: const Size(5, 0),
              scaledottedPath: .9,
              letterPath: ShapePaths.cshaped,
              pointsJsonFile: ShapePointsManger.cShape
              ),
        ];
      case PhonicsLetters.r:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.rShapeDotted,
              indexPath: ShapePaths.rshapeIndex,
              scaleIndexPath: .5,
              positionIndexPath: const Size(-10, -50),
              scaledottedPath: .8,
              letterPath: ShapePaths.rshape,
              pointsJsonFile: ShapePointsManger.rShape
              ),
        ];
      case PhonicsLetters.i:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.iShapeDotetd,
              positionDottedPath: const Size(12, 20),
              positionIndexPath: const Size(-15, -35),
              indexPath: ShapePaths.iShapeIndex,
              scaleIndexPath: .5,
              scaledottedPath: .5,
              letterPath: ShapePaths.iShape,
              pointsJsonFile: ShapePointsManger.iShape
              ),
        ];
      case PhonicsLetters.p:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.pShapeDotted,
              positionDottedPath: const Size(0, 5),
              positionIndexPath: const Size(-46, -70),
              indexPath: ShapePaths.pShapeIndex,
              scaleIndexPath: .2,
              scaledottedPath: .9,
              letterPath: ShapePaths.pShape,
              pointsJsonFile: ShapePointsManger.pShape,
          ),
        ];
      default:
      throw UnimplementedError('Letra não suportada: $currentLetter');
    }
  }

  List<TraceModel> _getTracingDataPhonicsUp(
      {required String letter, Size sizeOfLetter = const Size(200, 200)}) {
    PhonicsLetters currentLetter =
        _detectTheCurrentEnumFromPhonics(letter: letter);

    switch (currentLetter) {
      case PhonicsLetters.l:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.lBigShapeDotted,
              indexPath: PTShapePaths.lBigShapeIndex,
              scaleIndexPath: .85,
              scaledottedPath: .8,
              positionIndexPath: const Size(-45, 0),
              positionDottedPath: const Size(0, 10),
              letterPath: PTShapePaths.lBigShape,
              pointsJsonFile: ShapePointsManger.lUpperShape,
          ),
        ];
      case PhonicsLetters.u:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.uBigShapeDotted,
              indexPath: PTShapePaths.uBigShapeIndex,
              scaleIndexPath: .15,
              scaledottedPath: .93,
              positionIndexPath: const Size(-50, -70),
              positionDottedPath: const Size(5, 0),
              letterPath: PTShapePaths.uBigShape,
              pointsJsonFile: ShapePointsManger.uUpperShape
              ),
        ];
      case PhonicsLetters.j:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.jBigShapeDotted,
              indexPath: PTShapePaths.jBigShapeIndex,
              scaleIndexPath: .28,
              scaledottedPath: .93,
              positionIndexPath: const Size(-22, -70),
              positionDottedPath: const Size(0, 0),
              letterPath: PTShapePaths.jBigShape,
              pointsJsonFile: ShapePointsManger.jUpperShape),
        ];

      case PhonicsLetters.h:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.hBigShapeDotted,
              indexPath: PTShapePaths.hBigShapeIndex,
              scaleIndexPath: .75,
              scaledottedPath: .8,
              positionIndexPath: const Size(0, -45),
              positionDottedPath: const Size(0, 10),
              letterPath: PTShapePaths.hBigShape,
              pointsJsonFile: ShapePointsManger.hUpperShape
              ),
        ];

      case PhonicsLetters.o:
        return [
          _getTracingDataPhonics(
                  letter: 'o', sizeOfLetter: const Size(200, 200))
              .first,
        ];

      case PhonicsLetters.g:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.gShapeBigShapeDotted,
              indexPath: PTShapePaths.gShapeBigShapeIndex,
              scaleIndexPath: .4,
              positionIndexPath: const Size(40, -30),
              scaledottedPath: .85,
              letterPath: PTShapePaths.gShapeBigShape,
              pointsJsonFile: ShapePointsManger.gUpperShape
              ),
        ];

      case PhonicsLetters.f:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.fShapeBigShapeDotted,
              indexPath: PTShapePaths.fShapeBigShapeIndex,
              scaleIndexPath: .5,
              positionIndexPath: const Size(-45, -40),
              scaledottedPath: .85,
              letterPath: PTShapePaths.fShapeBigShape,
              pointsJsonFile: ShapePointsManger.fUpperShape,),
        ];

      case PhonicsLetters.d:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.dBigShapeDotted,
              indexPath: PTShapePaths.dBigShapeIndex,
              scaleIndexPath: .3,
              positionIndexPath: const Size(-45, -80),
              scaledottedPath: .85,
              letterPath: PTShapePaths.dBigShape,
              pointsJsonFile: ShapePointsManger.dUpperShape
              ),
        ];
      case PhonicsLetters.e:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.eBigShapeDotted,
              indexPath: PTShapePaths.eBigShapeIndex,
              scaleIndexPath: .8,
              positionIndexPath: const Size(-20, 0),
              scaledottedPath: .85,
              letterPath: PTShapePaths.eBigShape,
              pointsJsonFile: ShapePointsManger.eUpperShape
              ),
        ];
      case PhonicsLetters.n:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.nBigShapeDotted,
              indexPath: PTShapePaths.nBigShapeIndex,
              scaleIndexPath: .94,
              positionIndexPath: const Size(0, 0),
              scaledottedPath: .87,
              letterPath: PTShapePaths.nBigShape,
              pointsJsonFile: ShapePointsManger.nUpperShape
              ),
        ];
      case PhonicsLetters.b:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.bShapeBigShapeDotted,
              indexPath: PTShapePaths.bShapeBigShapeIndex,
              scaleIndexPath: .25,
              positionIndexPath: const Size(-30, -80),
              scaledottedPath: .85,
              letterPath: PTShapePaths.bShapeBigShape,
              pointsJsonFile: ShapePointsManger.bUpperShape
              ),
        ];

      case PhonicsLetters.s:
        // s phone
        return [
          _getTracingDataPhonics(
                  letter: 's', sizeOfLetter: const Size(200, 200))
              .first,
        ];
      case PhonicsLetters.a:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.aShapeBigDotted,
              indexPath: PTShapePaths.aShapeBigShapeIndex,
              scaleIndexPath: .3,
              positionIndexPath: const Size(-50,70),
              scaledottedPath: .8,
              letterPath: PTShapePaths.aShapeBigShape,
              pointsJsonFile: ShapePointsManger.aUpperShape
              ),
        ];
      case PhonicsLetters.m:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.mSHapeBigDoted,
              indexPath: PTShapePaths.mShapeBigIndex,
              scaleIndexPath: .9,
              scaledottedPath: .9,
              positionIndexPath: const Size(0, 2),
              positionDottedPath: const Size(10,5),
              letterPath: PTShapePaths.mShapeBigShape,
              pointsJsonFile: ShapePointsManger.mUpperShape
              ),
        ];
      case PhonicsLetters.q:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.qBigShapeDotted,
              positionIndexPath: const Size(10, 55),
              indexPath: PTShapePaths.qBigShapesIndex,
              scaleIndexPath: .3,
              scaledottedPath: .9,
              letterPath: PTShapePaths.qBigShapes,
              pointsJsonFile: ShapePointsManger.qUpperShape
              ),
        ];
      case PhonicsLetters.v:
        return [
          _getTracingDataPhonics(
                  letter: 'v', sizeOfLetter: const Size(200, 200))
              .first,
        ];
      case PhonicsLetters.x:
        return [
          _getTracingDataPhonics(
                  letter: 'x', sizeOfLetter: const Size(200, 200))
              .first,
        ];
      case PhonicsLetters.z:
        return [
          _getTracingDataPhonics(
                  letter: 'z', sizeOfLetter: const Size(200, 200))
              .first,
        ];
      case PhonicsLetters.t:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.tShapeBigShapeDotted,
              indexPath: PTShapePaths.tShapeBigShapeIndex,
              letterPath: PTShapePaths.tShapeBigShape,
              scaledottedPath: .8,
              scaleIndexPath: .35,
              positionDottedPath: const Size(5, -5),
              positionIndexPath: const Size(-30, -70),
              pointsJsonFile: ShapePointsManger.tUpperShape
              ),
        ];
      case PhonicsLetters.c:
        return [
          _getTracingDataPhonics(letter: 'c').first,
        ];
      case PhonicsLetters.r:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.rShapeBigShapeDotted,
              indexPath: PTShapePaths.rShapeBigShapeIndex,
              scaleIndexPath: .5,
              positionIndexPath: const Size(-20, -40),
              scaledottedPath: .9,
              letterPath: PTShapePaths.rShapeBigShape,
              pointsJsonFile: ShapePointsManger.rUpperShape),
        ];
      case PhonicsLetters.i:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.iShapeBigShapeDotted,
              positionDottedPath: const Size(10, 0),
              positionIndexPath: const Size(-22, 0),
              indexPath: PTShapePaths.iShapeBigShapeIndex,
              scaleIndexPath: .95,
              scaledottedPath: .9,
              letterPath: PTShapePaths.iShapeBigShape,
              pointsJsonFile: ShapePointsManger.iUpperShape),
        ];
      case PhonicsLetters.p:
        return [
          _buildTraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.pBigShapeDotted,
              positionDottedPath: const Size(-5, 5),
              positionIndexPath: const Size(-40, -80),
              indexPath: PTShapePaths.pBigShapeIndex,
              scaleIndexPath: .25,
              scaledottedPath: .92,
              letterPath: PTShapePaths.pBigShape,
              pointsJsonFile: ShapePointsManger.pUpperShape
              ),
        ];
      default:
      throw UnimplementedError('Letra não suportada: $currentLetter');
    }
  }
}