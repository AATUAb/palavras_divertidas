# Relatório de testes

## Testes unitários

- Lógica
  - LevelManager
    - ✅ Deve iniciar com o nivel do utilizador
    - ✅ Deve subir um nivel se tiver 80% ou superior de taxa de acerto, apos uma ronda de 8 respostas corretas
    - ✅ Nao deve ultrapassar o nivel maximo
    - ✅ Deve descer um nivel se tiver taxa de acerto inferior a 50%, apos uma ronda com 4 respostas incorretas
    - ✅ Nao deve descer abaixo do nivel minimo
    - ✅ Deve calcular precisao corretamente
    - ✅ Reset ao progresso e nivel
    - ✅ Sincroniza nivel com utilizador

- Modelos
  - CharacterModel
    - ✅ Deve criar um caracter com os campos obrigatorios
  - UserModel
    - ✅ Deve criar um utilizador com os campos obrigatorios
  - WordModel
    - ✅ Deve criar uma palavra com todos os campos obrigatorios e opcionais
    - ✅ Deve criar uma palavra sem campos opcionais

## Testes widget

- Jogos
  - IdentifyLettersNumbersLogic
    - ✅ Logica do IdentifyLettersNumbers Gera opcoes corretas - deve gerar o numero correto de elementos, todos iguais ao target, podendo variar em maiusculas/minusculas
    - ✅ Logica do IdentifyLettersNumbers Gera opcoes erradas - nunca deve conter o target
    - ✅ Logica do IdentifyLettersNumbers retryIsUsed deve retornar true apenas se o caracter ja estiver utilizado
    - ✅ Logica do IdentifyLettersNumbers Geracao de errados deve suportar mistura de letras e numeros

## Testes de integração

## Conclusão Geral da Aplicação

✅ Todos os testes passaram!
