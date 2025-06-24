# Relatório de testes à aplicação "Palavras Mágicas"


## Testes unitários

- Lógica
  - AllGames
    - ✅ Jogo 1: Permite identificar o target como correto
    - ✅ Jogo 2: Permite escrever numeros e letras (maiusculas e minusculas)
    - ✅ Jogo 3: Inclui 2/3 opcões (1/2 distratores + 1 target)
    - ✅ Jogo 4: Inclui 2/3 opcões (1/2 distratores + 1 target)
    - ✅ Jogo 5: Permite verificar a correspondência do som com o target
    - ✅ Jogo 6: Preenche silaba em falta na palavra target
  - LevelManager
    - ✅ Deve iniciar com o nivel do utilizador
    - ✅ Deve subir um nivel se tiver 80% ou superior de taxa de acerto, após uma ronda de 8 respostas corretas
    - ✅ Nao deve ultrapassar o nivel maximo
    - ✅ Deve descer um nivel se tiver taxa de acerto inferior a 50%, após uma ronda com 4 respostas incorretas
    - ✅ Não deve descer abaixo do nivel minimo
    - ✅ Deve calcular precisão corretamente
    - ✅ Reset do nivel, ao adicionar letras novas
    - ✅ Sincroniza nivel com utilizador
  - ConquestManager
    - ✅ Inicia com zero conquistas e contadores limpos
    - ✅ Regista conquista por acertos consecutivos na primeira tentativa
    - ✅ Regista conquista por persistência (nao-firstTry)
    - ✅ Primeira tentativa acumula corretamente o streak
    - ✅ PersistenceCount acumula apenas em tentativas não-firstTry
- Modelos
  - CharacterModel
    - ✅ Deve criar um caracter com os campos obrigatórios
  - UserModel
    - ✅ Deve criar um utilizador com os campos obrigatórios
  - WordModel
    - ✅ Deve criar uma palavra com todos os campos obrigatórios e opcionais
    - ✅ Deve criar uma palavra sem campos opcionais

## Testes de widget

- Ecrãs
  - MenuDesign
    - ✅ Deve renderizar elementos principais do MenuDesign
    - ✅ Deve executar callback de onHomePressed ao clicar no botao home

## Testes de integração

- Integração Base de Dados
  - HiveService
    - ✅ Adiciona e lê utilizador
    - ✅ Atualiza utilizador existente por chave
    - ✅ Elimina utilizador existente
    - ✅ Persiste e lê nivel de jogo por utilizador
    - ✅ Recupera utilizador inexistente devolve null
- Integração de Fluxos
  - FlowIntegration
    - ✅ Hive (Base de dados) <-> LevelManager <-> SuperWidget <-> Jogo (CountSyllables)

## Testes de performance

- Arranque da aplicação

  - StartUp
    - ✅ O ecrã principal carrega em menos de 5 segundos (tempo medido: 3ms)

## Conclusão Geral da Aplicação

✅ Todos os testes passaram!
