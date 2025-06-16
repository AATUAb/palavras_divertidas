// Testes unitários ao modelo UserModel
//
// Este ficheiro cobre as validações essenciais para o modelo de dados UserModel, nomeadamente:
// - Criação de instâncias válidas com todos os campos obrigatórios.
// - Verificação do correto mapeamento dos atributos obrigatórios (name, schoolLevel).
// - Validação dos valores por omissão nos campos opcionais.
// - Garantia de integridade da estrutura base de dados do utilizador.

import 'package:flutter_test/flutter_test.dart';
import 'package:mundodaspalavras/models/user_model.dart';

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
    });
  });
}
