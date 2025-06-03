//enum_of_numbers_and_letters.dart

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
        } else if (_isPhonicsCharacter(letters)) {
          tracingDataList.add(
              _getTracingDataPhonics(letter: letters.toLowerCase())
                  .first
                  .copyWith(
                    innerPaintColor: char.traceShapeOptions.innerPaintColor,
                    outerPaintColor: char.traceShapeOptions.outerPaintColor,
                    indexColor: char.traceShapeOptions.indexColor,
                    dottedColor: char.traceShapeOptions.dottedColor,
                  ));
        } else if (_isUpperCasePhonicsCharacter(letters)) {
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

  bool _isPhonicsCharacter(String letter) {
    // Check if the letter is a valid phonics character (assuming it's A-Z or a-z)
    return RegExp(r'^[a-z]$').hasMatch(letter);
  }

  bool _isUpperCasePhonicsCharacter(String letter) {
    // Check if the letter is an uppercase phonics character
    return RegExp(r'^[A-Z]$').hasMatch(letter);
  }

  List<TraceModel> _getTracingDataNumbers({required String number}) {
    List<TraceModel> listOfTraceModel = [];

    switch (number) {
      case '1':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(-12, -85),
            positionDottedPath: const Size(-31, 10),
            scaledottedPath: .8,
            scaleIndexPath: .1,
            dottedPath: NumberSvgs.shapeNumber1Dotted,
            indexPath: NumberSvgs.shapeNumber1Index,
            letterPath: NumberSvgs.shapeNumber1,
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            pointsJsonFile: ShapePointsManger.number1,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;

      case '2':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(-50, 20),
            positionDottedPath: const Size(0, -5),
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            scaleIndexPath: .8,
            scaledottedPath: 1,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber2Dotted,
            indexPath: NumberSvgs.shapeNumber2Index,
            letterPath: NumberSvgs.shapeNumber2,
            pointsJsonFile: ShapePointsManger.number2,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;
      case '3':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(-25, -30),
            positionDottedPath: const Size(-5, 0),
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            scaleIndexPath: .4,
            scaledottedPath: .9,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber3Dotted,
            indexPath: NumberSvgs.shapeNumber3Index,
            letterPath: NumberSvgs.shapeNumber3,
            pointsJsonFile: ShapePointsManger.number3,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;
      case '4':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(-10, -33),
            positionDottedPath: const Size(-3, -10),
            scaledottedPath: .85,
            disableDividedStrokes: true,
            scaleIndexPath: .66,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber4Dotted,
            indexPath: NumberSvgs.shapeNumber4Index,
            letterPath: NumberSvgs.shapeNumber4,
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            strokeWidth: 70,
            // distanceToCheck: 10,
            pointsJsonFile: ShapePointsManger.number4,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;
      case '5':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(-30, -50),
            positionDottedPath: const Size(-5, 0),
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            scaleIndexPath: .5,
            scaledottedPath: .95,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber5Dotted,
            indexPath: NumberSvgs.shapeNumber5Index,
            letterPath: NumberSvgs.shapeNumber5,
            pointsJsonFile: ShapePointsManger.number5,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;
      case '6':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(5, -90),
            positionDottedPath: const Size(-5, 0),
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            scaleIndexPath: .1,
            scaledottedPath: .9,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber6Dotted,
            indexPath: NumberSvgs.shapeNumber6Index,
            letterPath: NumberSvgs.shapeNumber6,
            pointsJsonFile: ShapePointsManger.number6,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;
      case '7':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(0, -90),
            positionDottedPath: const Size(0, -5),
            scaledottedPath: .9,
            scaleIndexPath: .6,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber7Dotted,
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            indexPath: NumberSvgs.shapeNumber7Index,
            letterPath: NumberSvgs.shapeNumber7,
            strokeWidth: 70,
            pointsJsonFile: ShapePointsManger.number7,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;
      case '8':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(50, -50),
            positionDottedPath: const Size(5, 0),
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            scaleIndexPath: .07,
            scaledottedPath: 1,
            strokeWidth: 70,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber8Dotted,
            indexPath: NumberSvgs.shapeNumber8Index,
            letterPath: NumberSvgs.shapeNumber8,
            pointsJsonFile: ShapePointsManger.number8,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;
      case '9':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(55, -30),
            positionDottedPath: const Size(0, -5),
            indexPathPaintStyle: PaintingStyle.fill,
            dottedPathPaintStyle: PaintingStyle.stroke,
            scaleIndexPath: .18,
            scaledottedPath: .9,
            strokeWidth: 70,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber9Dotted,
            indexPath: NumberSvgs.shapeNumber9Index,
            letterPath: NumberSvgs.shapeNumber9,
            pointsJsonFile: ShapePointsManger.number9,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
        break;
      case '0':
        listOfTraceModel.add(TraceModel(
            positionIndexPath: const Size(-10, -90),
            positionDottedPath: const Size(-5, -5),
            scaledottedPath: .9,
            scaleIndexPath: .08,
            indexPathPaintStyle: PaintingStyle.fill,
            dottedColor: AppColors.grey,
            indexColor: AppColors.white,
            dottedPath: NumberSvgs.shapeNumber0Dotted,
            indexPath: NumberSvgs.shapeNumber0Index,
            letterPath: NumberSvgs.shapeNumber0,
            pointsJsonFile: ShapePointsManger.number0,
            innerPaintColor: AppColors.lightBlue,
            outerPaintColor: AppColors.darkBlue));
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
      } else if (_isPhonicsCharacter(word[i])) {
        letters.add(_getTracingDataPhonics(letter: word[i].toLowerCase())
            .first
            .copyWith(
              isSpace: isNextSpace,
            ));
      } else if (_isUpperCasePhonicsCharacter(word[i])) {
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
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.nlowerShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.nlowerShapeIndex,
              strokeWidth: 70,
              disableDividedStrokes: true,
              scaleIndexPath: .3,
              positionDottedPath: const Size(0, 0),
              positionIndexPath: const Size(-50, -65),
              scaledottedPath: .75,
              letterPath: PTShapePaths.nlowerShape,
              pointsJsonFile: ShapePointsManger.nLowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.e:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.eLowerShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.eLowerShapeIndex,
              strokeWidth: 70,
              disableDividedStrokes: true,
              scaleIndexPath: .12,
              positionDottedPath: const Size(0, 0),
              positionIndexPath: const Size(-20, -5),
              scaledottedPath: .75,
              letterPath: PTShapePaths.eLowerShape,
              pointsJsonFile: ShapePointsManger.eLowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.d:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.dLowerShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.dLowerShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .35,
              positionDottedPath: const Size(0, 10),
              positionIndexPath: const Size(30, -60),
              scaledottedPath: .85,
              letterPath: PTShapePaths.dLowerShape,
              pointsJsonFile: ShapePointsManger.dlowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];

      case PhonicsLetters.o:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              dottedPath: PTShapePaths.oShapeBigShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.oShapeBigShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .15,
              positionDottedPath: const Size(5, 0),
              positionIndexPath: const Size(-10, -70),
              scaledottedPath: .85,
              letterPath: PTShapePaths.oShapeBigShape,
              pointsJsonFile: ShapePointsManger.oUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.g:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.gLowrShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.gLowrShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .2,
              positionIndexPath: const Size(40, -75),
              positionDottedPath: const Size(0, 0),
              scaledottedPath: .8,
              letterPath: PTShapePaths.gLowrShape,
              pointsJsonFile: ShapePointsManger.glowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.f:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.fLowerShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.fLowerShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .4,
              positionIndexPath: const Size(10, -55),
              positionDottedPath: const Size(10, 0),
              scaledottedPath: .8,
              letterPath: PTShapePaths.fLowerShape,
              pointsJsonFile: ShapePointsManger.flowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.b:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.blowerShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.blowerShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .4,
              positionIndexPath: const Size(-30, -55),
              positionDottedPath: const Size(0, 10),
              scaledottedPath: .8,
              letterPath: PTShapePaths.blowerShape,
              pointsJsonFile: ShapePointsManger.blowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.l:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.lLowerShapeDotted,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              indexPath: PTShapePaths.lLowerShapeIndex,
              scaleIndexPath: .1,
              scaledottedPath: .93,
              positionIndexPath: const Size(0, -55),
              positionDottedPath: const Size(5, 0),
              letterPath: PTShapePaths.lLowerShape,
              pointsJsonFile: ShapePointsManger.llowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue)
        ];

      case PhonicsLetters.u:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.uLowerShapeDotted,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPath: PTShapePaths.uLowerShapeIndex,
              scaleIndexPath: .7,
              scaledottedPath: .8,
              positionIndexPath: const Size(0, -70),
              positionDottedPath: const Size(0, 10),
              letterPath: PTShapePaths.uLowerShape,
              pointsJsonFile: ShapePointsManger.ulowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];

      case PhonicsLetters.j:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.jlowerShapeDotetd,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPath: PTShapePaths.jlowerShapeIndex,
              scaleIndexPath: .3,
              scaledottedPath: .65,
              positionIndexPath: const Size(22, -65),
              positionDottedPath: const Size(0, 25),
              letterPath: PTShapePaths.jlowerShape,
              pointsJsonFile: ShapePointsManger.jlowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];

      case PhonicsLetters.h:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.hLowerShapeDotted,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPath: PTShapePaths.hlowerShapeIndex,
              scaleIndexPath: .45,
              scaledottedPath: .85,
              positionIndexPath: const Size(-40, -45),
              positionDottedPath: const Size(0, 10),
              letterPath: PTShapePaths.hLoweCaseShape,
              pointsJsonFile: ShapePointsManger.hlowerShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];

      case PhonicsLetters.s:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              dottedPath: ShapePaths.sDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: ShapePaths.sIndex,
              strokeWidth: 70,
              scaleIndexPath: .65,
              positionIndexPath: const Size(-10, 0),
              scaledottedPath: .8,
              letterPath: ShapePaths.s3,
              pointsJsonFile: ShapePointsManger.sShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue)
        ];
      case PhonicsLetters.a:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.aDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: ShapePaths.aIndex,
              dottedPathPaintStyle: PaintingStyle.fill,
              indexPathPaintStyle: PaintingStyle.fill,
              scaleIndexPath: .3,
              positionIndexPath: const Size(50, -60),
              scaledottedPath: .8,
              letterPath: ShapePaths.aShape,
              strokeWidth: 70,
              pointsJsonFile: ShapePointsManger.aShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue)
        ];
      case PhonicsLetters.m:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.mDotted,
              strokeWidth: 70,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: ShapePaths.mIndex,
              indexPathPaintStyle: PaintingStyle.fill,
              scaleIndexPath: .6,
              scaledottedPath: .8,
              positionIndexPath: const Size(-30, -50),
              letterPath: ShapePaths.mshape,
              pointsJsonFile: ShapePointsManger.mShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.q:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.qshapeDotted,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPathPaintStyle: PaintingStyle.fill,
              positionIndexPath: const Size(40, -80),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: ShapePaths.qshapeIndex,
              scaleIndexPath: .2,
              scaledottedPath: .8,
              letterPath: ShapePaths.qshape,
              pointsJsonFile: ShapePointsManger.qShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.v:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.vShapeDotted,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              positionIndexPath: const Size(-30, -0),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: ShapePaths.vShapeIndex,
              scaleIndexPath: .9,
              scaledottedPath: .8,
              letterPath: ShapePaths.vshape,
              pointsJsonFile: ShapePointsManger.vShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.x:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.xDotted,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              positionIndexPath: const Size(-0, -75),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: ShapePaths.xIndex,
              scaleIndexPath: .7,
              scaledottedPath: .8,
              disableDividedStrokes: true,
              letterPath: ShapePaths.xShape,
              pointsJsonFile: ShapePointsManger.xShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.z:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.zShapeDotted,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              positionIndexPath: const Size(0, 0),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: ShapePaths.zShapeIndex,
              scaleIndexPath: .7,
              scaledottedPath: .8,
              letterPath: ShapePaths.zShape,
              pointsJsonFile: ShapePointsManger.zShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.t:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.tshapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: ShapePaths.tshapeIndex,
              letterPath: ShapePaths.tShape,
              strokeWidth: 70,
              scaledottedPath: .8,
              scaleIndexPath: .33,
              positionDottedPath: const Size(2, 10),
              positionIndexPath: const Size(-30, -60),
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPathPaintStyle: PaintingStyle.fill,
              pointsJsonFile: ShapePointsManger.tShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.c:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              dottedPath: ShapePaths.cshapeDoted,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: ShapePaths.cshapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .1,
              positionIndexPath: const Size(140, -25),
              positionDottedPath: const Size(5, 0),
              scaledottedPath: .9,
              letterPath: ShapePaths.cshaped,
              pointsJsonFile: ShapePointsManger.cShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.r:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.rShapeDotted,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: ShapePaths.rshapeIndex,
              scaleIndexPath: .5,
              positionIndexPath: const Size(-10, -50),
              scaledottedPath: .8,
              letterPath: ShapePaths.rshape,
              pointsJsonFile: ShapePointsManger.rShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.i:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.iShapeDotetd,
              dottedPathPaintStyle: PaintingStyle.fill,
              indexPathPaintStyle: PaintingStyle.fill,
              positionDottedPath: const Size(12, 20),
              positionIndexPath: const Size(-15, -35),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: ShapePaths.iShapeIndex,
              scaleIndexPath: .5,
              scaledottedPath: .5,
              letterPath: ShapePaths.iShape,
              pointsJsonFile: ShapePointsManger.iShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.p:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: ShapePaths.pShapeDotted,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPathPaintStyle: PaintingStyle.fill,
              positionDottedPath: const Size(0, 5),
              positionIndexPath: const Size(-46, -70),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: ShapePaths.pShapeIndex,
              scaleIndexPath: .2,
              scaledottedPath: .9,
              letterPath: ShapePaths.pShape,
              pointsJsonFile: ShapePointsManger.pShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
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
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.lBigShapeDotted,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              indexPath: PTShapePaths.lBigShapeIndex,
              scaleIndexPath: .85,
              scaledottedPath: .8,
              positionIndexPath: const Size(-45, 0),
              positionDottedPath: const Size(0, 10),
              letterPath: PTShapePaths.lBigShape,
              pointsJsonFile: ShapePointsManger.lUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.u:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.uBigShapeDotted,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPath: PTShapePaths.uBigShapeIndex,
              scaleIndexPath: .15,
              scaledottedPath: .93,
              positionIndexPath: const Size(-50, -70),
              positionDottedPath: const Size(5, 0),
              letterPath: PTShapePaths.uBigShape,
              pointsJsonFile: ShapePointsManger.uUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.j:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.jBigShapeDotted,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPath: PTShapePaths.jBigShapeIndex,
              scaleIndexPath: .28,
              scaledottedPath: .93,
              positionIndexPath: const Size(-22, -70),
              positionDottedPath: const Size(0, 0),
              letterPath: PTShapePaths.jBigShape,
              pointsJsonFile: ShapePointsManger.jUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];

      case PhonicsLetters.h:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.hBigShapeDotted,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPath: PTShapePaths.hBigShapeIndex,
              scaleIndexPath: .75,
              scaledottedPath: .8,
              positionIndexPath: const Size(0, -45),
              positionDottedPath: const Size(0, 10),
              letterPath: PTShapePaths.hBigShape,
              pointsJsonFile: ShapePointsManger.hUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];

      case PhonicsLetters.o:
        return [
          _getTracingDataPhonics(
                  letter: 'o', sizeOfLetter: const Size(200, 200))
              .first,
        ];

      case PhonicsLetters.g:
        return [
          TraceModel(
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.gShapeBigShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.gShapeBigShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .4,
              positionIndexPath: const Size(40, -30),
              scaledottedPath: .85,
              letterPath: PTShapePaths.gShapeBigShape,
              pointsJsonFile: ShapePointsManger.gUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];

      case PhonicsLetters.f:
        return [
          TraceModel(
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.fShapeBigShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.fShapeBigShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .5,
              positionIndexPath: const Size(-45, -40),
              scaledottedPath: .85,
              letterPath: PTShapePaths.fShapeBigShape,
              pointsJsonFile: ShapePointsManger.fUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];

      case PhonicsLetters.d:
        return [
          TraceModel(
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.dBigShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.dBigShapeIndex,
              strokeWidth: 75,
              scaleIndexPath: .3,
              positionIndexPath: const Size(-45, -80),
              scaledottedPath: .85,
              letterPath: PTShapePaths.dBigShape,
              pointsJsonFile: ShapePointsManger.dUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.e:
        return [
          TraceModel(
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.eBigShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.eBigShapeIndex,
              strokeWidth: 75,
              scaleIndexPath: .8,
              positionIndexPath: const Size(-20, 0),
              scaledottedPath: .85,
              letterPath: PTShapePaths.eBigShape,
              pointsJsonFile: ShapePointsManger.eUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.n:
        return [
          TraceModel(
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.nBigShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.nBigShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .94,
              distanceToCheck: 25,
              disableDividedStrokes: true,
              positionIndexPath: const Size(0, 0),
              scaledottedPath: .87,
              letterPath: PTShapePaths.nBigShape,
              pointsJsonFile: ShapePointsManger.nUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.b:
        return [
          TraceModel(
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              dottedPath: PTShapePaths.bShapeBigShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.bShapeBigShapeIndex,
              strokeWidth: 70,
              scaleIndexPath: .25,
              positionIndexPath: const Size(-30, -80),
              scaledottedPath: .85,
              letterPath: PTShapePaths.bShapeBigShape,
              pointsJsonFile: ShapePointsManger.bUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
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
          TraceModel(
              dottedPath: PTShapePaths.aShapeBigDotted,
              dottedColor: AppColors.white,
              disableDividedStrokes: true,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.aShapeBigShapeIndex,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPathPaintStyle: PaintingStyle.fill,
              scaleIndexPath: .67,
              positionIndexPath: const Size(-15, -20),
              scaledottedPath: .8,
              letterPath: PTShapePaths.aShapeBigShape,
              strokeWidth: 70,
              pointsJsonFile: ShapePointsManger.aUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.m:
        return [
          TraceModel(
              letterViewSize: sizeOfLetter,
              dottedPath: PTShapePaths.mSHapeBigDoted,
              strokeWidth: 70,
              disableDividedStrokes: true,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPath: PTShapePaths.mShapeBigIndex,
              scaleIndexPath: .9,
              scaledottedPath: .9,
              positionIndexPath: const Size(0, 2),
              letterPath: PTShapePaths.mShapeBigShape,
              pointsJsonFile: ShapePointsManger.mUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.q:
        return [
          TraceModel(
              dottedPath: PTShapePaths.qBigShapeDotted,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPathPaintStyle: PaintingStyle.fill,
              positionIndexPath: const Size(10, 55),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: PTShapePaths.qBigShapesIndex,
              scaleIndexPath: .3,
              scaledottedPath: .9,
              letterPath: PTShapePaths.qBigShapes,
              pointsJsonFile: ShapePointsManger.qUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
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
          TraceModel(
              dottedPath: PTShapePaths.tShapeBigShapeDotted,
              dottedColor: AppColors.white,
              indexColor: AppColors.grey,
              indexPath: PTShapePaths.tShapeBigShapeIndex,
              letterPath: PTShapePaths.tShapeBigShape,
              strokeWidth: 70,
              scaledottedPath: .8,
              scaleIndexPath: .35,
              disableDividedStrokes: true,
              positionDottedPath: const Size(5, -5),
              positionIndexPath: const Size(-30, -70),
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPathPaintStyle: PaintingStyle.fill,
              pointsJsonFile: ShapePointsManger.tUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.c:
        return [
          _getTracingDataPhonics(letter: 'c').first,
        ];
      case PhonicsLetters.r:
        return [
          TraceModel(
              dottedPath: PTShapePaths.rShapeBigShapeDotted,
              indexPathPaintStyle: PaintingStyle.fill,
              dottedPathPaintStyle: PaintingStyle.fill,
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: PTShapePaths.rShapeBigShapeIndex,
              scaleIndexPath: .5,
              positionIndexPath: const Size(-20, -40),
              scaledottedPath: .9,
              letterPath: PTShapePaths.rShapeBigShape,
              pointsJsonFile: ShapePointsManger.rUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.i:
        return [
          TraceModel(
              dottedPath: PTShapePaths.iShapeBigShapeDotted,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPathPaintStyle: PaintingStyle.fill,
              positionDottedPath: const Size(10, 0),
              positionIndexPath: const Size(-22, 0),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: PTShapePaths.iShapeBigShapeIndex,
              scaleIndexPath: .95,
              scaledottedPath: .9,
              letterPath: PTShapePaths.iShapeBigShape,
              pointsJsonFile: ShapePointsManger.iUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      case PhonicsLetters.p:
        return [
          TraceModel(
              dottedPath: PTShapePaths.pBigShapeDotted,
              dottedPathPaintStyle: PaintingStyle.stroke,
              indexPathPaintStyle: PaintingStyle.fill,
              positionDottedPath: const Size(-5, 5),
              positionIndexPath: const Size(-40, -80),
              strokeWidth: 70,
              dottedColor: AppColors.grey,
              indexColor: AppColors.white,
              indexPath: PTShapePaths.pBigShapeIndex,
              scaleIndexPath: .25,
              scaledottedPath: .92,
              letterPath: PTShapePaths.pBigShape,
              pointsJsonFile: ShapePointsManger.pUpperShape,
              innerPaintColor: AppColors.darkBlue,
              outerPaintColor: AppColors.darkBlue),
        ];
      default:
      throw UnimplementedError('Letra não suportada: $currentLetter');
    }
  }
}
