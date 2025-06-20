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
    - ✅ Reset do nivel, ao adicionar letras novas
    - ✅ Sincroniza nivel com utilizador
  - ConquestManager
    - ✅ Inicia com zero conquistas e contadores limpos
    - ✅ Regista conquista por acertos consecutivos na primeira tentativa
    - ✅ Regista conquista por persistencia (nao-firstTry)
    - ✅ Primeira tentativa acumula corretamente o streak
    - ✅ PersistenceCount acumula apenas em tentativas nao-firstTry

- Modelos
  - CharacterModel
    - ✅ Deve criar um caracter com os campos obrigatorios

## Testes widget

## Testes de integração

- Integração Base de Dados
  - HiveService
    - ✅ Adiciona e le utilizador
    - ✅ Atualiza utilizador existente por chave
    - ✅ Elimina utilizador existente
    - ✅ Persiste e le nivel de jogo por utilizador
    - ✅ Recupera utilizador inexistente devolve null

- Integração Flows
  - FlowIntegration
    - ✅ Integracao Flow:  Hive (Base de dados) <-> SuperWidget <-> Jogo (CountSyllables)

## Conclusão Geral da Aplicação

✅ Todos os testes passaram!
