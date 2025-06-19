# Relatório de testes

## Testes unitários

- Lógica
  - AllGames
    - ✅ Jogo 1: Permite identificar o target como correto
    - ✅ Jogo 2: Permite escrever numeros e letras (maiusculas e minusculas)
    - ✅ Jogo 3: Inclui 2/3 opcoes (1/2 distratores + 1 target)
    - ✅ Jogo 4: Inclui 2/3 opcoes (1/2 distratores + 1 target)
    - ✅ Jogo 5: Permite verificar a correspondencia do som com o target
    - ✅ Jogo 6: Preenche silaba em falta na palavra target
  - LevelManager
    - ✅ Deve iniciar com o nivel do utilizador
    - ✅ Deve subir um nivel se tiver 80% ou superior de taxa de acerto, apos uma ronda de 8 respostas corretas
    - ✅ Nao deve ultrapassar o nivel maximo
    - ✅ Deve descer um nivel se tiver taxa de acerto inferior a 50%, apos uma ronda com 4 respostas incorretas
    - ✅ Nao deve descer abaixo do nivel minimo
    - ✅ Deve calcular precisao corretamente
    - ✅ Reset do nivel, ao adicionar letras novas
    - ✅ Sincroniza nivel com utilizador
  - ConquerManager
    - ✅ ConquestManager Inicia com zero conquistas e contadores limpos
    - ✅ ConquestManager Regista conquista por acertos consecutivos na primeira tentativa
    - ✅ ConquestManager Regista conquista por persistencia (nao-firstTry)
    - ✅ ConquestManager Primeira tentativa acumula corretamente o streak
    - ✅ ConquestManager PersistenceCount acumula apenas em tentativas nao-firstTry

- Modelos
  - CharacterModel
    - ✅ Deve criar um caracter com os campos obrigatorios

## Testes widget

## Testes de integração

- Integração Base de Dados
  - HiveService
    - ✅ Integration Adiciona e le utilizadores
    - ❌ Integration Adiciona e le utilizadores
    - ✅ Integration Atualiza utilizador por chave
    - ❌ Integration Atualiza utilizador por chave
    - ✅ Integration Elimina utilizador
    - ❌ Integration Elimina utilizador
    - ✅ Integration Persiste e le nivel do jogo
    - ❌ Integration Persiste e le nivel do jogo
    - ✅ Integration Recupera utilizador inexistente devolve null
    - ❌ Integration Recupera utilizador inexistente devolve null

## Conclusão Geral da Aplicação

❌ Alguns testes falharam!
