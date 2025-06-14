import 'package:flutter_test/flutter_test.dart';
import 'package:mundodaspalavras/models/user_model.dart';

/// Teste unitário para o modelo UserModel.
/// Objetivo: Garantir que o objeto UserModel é criado corretamente
/// e que os campos obrigatórios são atribuídos como esperado.
///
/// Este teste valida que a estrutura base de dados do utilizador
/// não sofre quebras ou alterações inesperadas.
///
/// Para executar: flutter test test/models/user_model_test.dart
void main() {
  group('UserModel', () {
    test('Deve criar um utilizador com os campos obrigatorios', () {
      // Arrange: Preparar dados mínimos de teste.
      final user = UserModel(name: 'Tiago', schoolLevel: '1º Ciclo');

      // Assert: Validar se os campos obrigatórios foram atribuídos corretamente.
      expect(user.name, equals('Tiago'));
      expect(user.schoolLevel, equals('1º Ciclo'));

      // Assert: Validar se os campos opcionais usam os valores por omissão.
      expect(user.knownLetters, isEmpty);
      expect(user.gameLevel, equals(1));
      expect(user.conquest, equals(0));
      expect(user.firstTrySuccesses, equals(0));
      expect(user.gamesAccuracy, isEmpty);
      expect(user.gamesAverageTime, isEmpty);
      // ...pode adicionar mais expects para outros campos opcionais se necessário.

      // Nota: Atualize este teste se a estrutura do modelo for alterada.
    });
  });
}
