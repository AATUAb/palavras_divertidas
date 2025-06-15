# Relatório de testes

## Resumo dos testes unitários

### unit/logic
- LevelManager Deve iniciar com o nivel do utilizador
- LevelManager Deve incrementar nivel ao obter acertos suficientes
- LevelManager Deve incrementar nivel ao obter acertos suficientes [E]
- LevelManager Deve descer de nivel apos erros consecutivos
- LevelManager Deve descer de nivel apos erros consecutivos [E]
- LevelManager Nao deve ultrapassar o nivel maximo
- LevelManager Nao deve descer abaixo do nivel minimo
- LevelManager Deve calcular precisao corretamente
- LevelManager Reset ao progresso e nivel
- LevelManager Sincroniza nivel com utilizador

### unit/models
- CharacterModel Deve criar um caracter com os campos obrigatorios
- UserModel Deve criar um utilizador com os campos obrigatorios
- WordModel Deve criar uma palavra com todos os campos obrigatorios e opcionais
- WordModel Deve criar uma palavra sem campos opcionais

## Resumo dos testes widget

### widget/games
- Logica do IdentifyLettersNumbers Gera opcoes corretas - deve gerar o numero correto de elementos, todos iguais ao target, podendo variar em maiusculas/minusculas
- Logica do IdentifyLettersNumbers Gera opcoes erradas - nunca deve conter o target
- Logica do IdentifyLettersNumbers retryIsUsed deve retornar true apenas se o caracter ja estiver utilizado
- Logica do IdentifyLettersNumbers Geracao de errados deve suportar mistura de letras e numeros

## Resumo dos testes de integração


