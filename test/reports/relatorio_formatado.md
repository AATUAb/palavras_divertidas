# Relatório de testes

### Testes unitários

##### Lógica

- ✅ LevelManager Deve iniciar com o nivel do utilizador
- ✅ LevelManager Deve subir um nivel apos dois ciclos completos de acertos
- ❌ LevelManager Deve subir um nivel apos dois ciclos completos de acertos
```text
Expected: <2>
Actual: <1>
```

- ✅ LevelManager Nao deve ultrapassar o nivel maximo
- ✅ LevelManager Deve descer um nivel apos um ciclo de erros
- ❌ LevelManager Deve descer um nivel apos um ciclo de erros
```text
Expected: <1>
Actual: <2>
```

- ✅ LevelManager Nao deve descer abaixo do nivel minimo
- ✅ LevelManager Deve calcular precisao corretamente
- ✅ LevelManager Reset ao progresso e nivel
- ✅ LevelManager Sincroniza nivel com utilizador

##### Modelos

- ✅ CharacterModel Deve criar um caracter com os campos obrigatorios
- ✅ UserModel Deve criar um utilizador com os campos obrigatorios
- ✅ WordModel Deve criar uma palavra com todos os campos obrigatorios e opcionais
- ✅ WordModel Deve criar uma palavra sem campos opcionais

## Testes widget

##### Jogos

- ✅ Logica do IdentifyLettersNumbers Gera opcoes corretas - deve gerar o numero correto de elementos, todos iguais ao target, podendo variar em maiusculas/minusculas
- ✅ Logica do IdentifyLettersNumbers Gera opcoes erradas - nunca deve conter o target
- ✅ Logica do IdentifyLettersNumbers retryIsUsed deve retornar true apenas se o caracter ja estiver utilizado
- ✅ Logica do IdentifyLettersNumbers Geracao de errados deve suportar mistura de letras e numeros

## Testes de integração

## Conclusão Geral da Aplicação

❌ **Alguns testes falharam!**
