import 'dart:collection';
import 'dart:math';

abstract class SequenceManager<T> {
  bool get isFinished;
  void reset();
  void registerFailure(T item);
  T? next({bool preferRetry = true});
}

class CharacterSequenceManager extends SequenceManager<String> {
  final List<String> _originalCharacters;
  final List<String> _shuffledCharacters;
  final Queue<String> _retryQueue = Queue();
  final List<String> _history = [];
  final int retryDelay;
  int _roundCounter = 0;

  CharacterSequenceManager(List<String> characters, {this.retryDelay = 2})
      : _originalCharacters = List.from(characters),
        _shuffledCharacters = List.from(characters)..shuffle();

  @override
  bool get isFinished =>
    !_shuffledCharacters.any((c) => RegExp(r'[a-zA-Z0-9]').hasMatch(c)) &&
    _retryQueue.isEmpty;

  @override
  void reset() {
    _shuffledCharacters
      ..clear()
      ..addAll(_originalCharacters)..shuffle();
    _retryQueue.clear();
    _history.clear();
    _roundCounter = 0;
  }

  @override
  void registerFailure(String character) {
    if (!_retryQueue.contains(character)) {
      _retryQueue.add(character);
    }
  }

  @override
  String? next({bool preferRetry = true}) {
    _roundCounter++;

    if (preferRetry && _retryQueue.isNotEmpty && _roundCounter > retryDelay) {
      _roundCounter = 0;
      return _retryQueue.removeFirst();
    }

    if (_shuffledCharacters.isNotEmpty) {
      final next = _shuffledCharacters.removeAt(0);
      _history.add(next);
      return next;
    }

    return null;
  }

  List<String> getRemaining({bool onlyLetters = false, bool onlyNumbers = false}) {
    if (onlyLetters) return _shuffledCharacters.where((c) => RegExp(r'[a-zA-Z]').hasMatch(c)).toList();
    if (onlyNumbers) return _shuffledCharacters.where((c) => RegExp(r'[0-9]').hasMatch(c)).toList();
    return List.from(_shuffledCharacters);
  }

  bool hasNumbers() => _shuffledCharacters.any((c) => RegExp(r'[0-9]').hasMatch(c));
  bool hasLetters() => _shuffledCharacters.any((c) => RegExp(r'[a-zA-Z]').hasMatch(c));

  List<String> takeNextForCustomChallenge({int letters = 4, int numbers = 1, bool strict = false}) {
    final result = <String>[];

    final letterList = getRemaining(onlyLetters: true);
    final numberList = getRemaining(onlyNumbers: true);

    if (strict && (letterList.length < letters || numberList.length < numbers)) {
      return [];
    }

    final selected = <String>[];
    final random = Random();

    while (selected.length < letters && letterList.isNotEmpty) {
      final i = random.nextInt(letterList.length);
      selected.add(letterList.removeAt(i));
    }

    while (selected.length < letters + numbers && numberList.isNotEmpty) {
      final i = random.nextInt(numberList.length);
      selected.add(numberList.removeAt(i));
    }

    _shuffledCharacters.removeWhere((c) => selected.contains(c));
    return selected;
  }
    
  }

// Futuramente: WordSequenceManager poderá ser adicionado seguindo a mesma lógica
