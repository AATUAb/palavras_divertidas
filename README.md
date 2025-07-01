


<p align="center">
  <img src="assets\images\PD_icon.png" alt="PD" width="96"/><br>
  <h1 align="center">Palavras Divertidas</h1>
</p>
<br>


## 📝 Descrição Geral

O Palavras Divertidas é uma aplicação multiplataforma desenvolvida em Flutter, focada na consolidação da alfabetização de crianças dos 5 aos 8 anos. Recorre a jogos sérios e elementos de gamificação para tornar o processo de aprendizagem da leitura e escrita em português europeu mais divertido, seguro e adaptado ao ritmo de cada criança.

---

## 🎯 Objetivos do Projeto

- Promover a consolidação da leitura, escrita e consciência fonológica através de jogos interativos.
- Adaptar os desafios e conteúdos ao nível de escolaridade e desempenho individual de cada criança.
- Garantir uma experiência segura, sem necessidade de ligação à Internet.
- Oferecer feedback imediato e recompensas para motivar a progressão no processo de alfabetização.

---

## 🛠️ Funcionalidades

- Seis jogos educativos, cada um com diferentes objetivos pedagógicos.
- Níveis de dificuldade progressivos e adaptáveis.
- Feedback visual e sonoro imediato.
- Sistema de conquistas para recompensar o progresso.
- Funcionamento totalmente offline.
- Interface simples, colorida e acessível a crianças pequenas.

---

## 🏗️ Arquitetura da Aplicação

A aplicação segue uma arquitetura modular e organizada, separando a lógica dos jogos, gestão de dados, temas e componentes visuais:

```
lib/
├── games/        # Lógica e widgets dos jogos
├── models/       # Modelos de dados (utilizador, progresso, conquistas, etc.)
├── screens/      # Ecrãs principais, menus e fluxos de navegação
├── services/     # Serviços de acesso a dados, gestão de lógica central, APIs locais
├── themes/       # Definições de cores, fontes e temas visuais
├── widgets/      # Componentes de UI reutilizáveis
└── main.dart     # Ponto de entrada da aplicação
```

---

## 🎮 Jogos Disponíveis

- **Identificação de Letras/Números** – Reconhecer letras e números apresentados de diferentes formas.
- **Escrever** – Traçar corretamente letras e números, seguindo indicações visuais.
- **Contar Sílabas** – Contar e identificar o número de sílabas em palavras.
- **Encontrar Imagens** – Associar sons/áudios a imagens corretas.
- **Ouvir e Encontrar Palavras** – Escolher a palavra certa após ouvir o áudio correspondente.
- **Sílabas Perdidas** – Completar palavras com a sílaba correta.

Cada jogo foi desenvolvido em conformidade com as orientações curriculares do pré-escolar e do 1.º ciclo em Portugal.

---

## 🏅 Elementos de Gamificação

- Níveis de dificuldade progressiva
- Feedback imediato (visual e sonoro)
- Sistema de recompensas e caderneta de conquistas
- Temporizador e desafios com tempo limitado
- Adaptação personalizada do conteúdo e dos jogos

---

## 💻 Tecnologias Utilizadas

- **Flutter (Dart):** Framework principal para desenvolvimento multiplataforma.
- **Hive:** Base de dados local e rápida, sem necessidade de Internet.
- **Google Fonts:** Fontes pedagógicas adaptadas a cada nível de escolaridade.
- **Trello:** Gestão ágil das tarefas do projeto.
- **GitHub:** Controlo de versões.

---

## 🚀 Instalação e Execução

* **Clonar o repositório:**
  ```bash
  git clone https://github.com/teu-username/palavras-divertidas.git
  ```
* **Aceder à pasta do projeto:**
  ```bash
  cd palavras-divertidas
  ```
* **Instalar dependências:**
  ```bash
  flutter pub get
  ```
* **Executar a aplicação:**
  ```bash
  flutter run
  ```

---

## 👥 Colaboradores

- Alexandre Gomes da Silva Soares – [2101521]
- Ana Luísa Garcia Nobre Duarte Guerreiro – [2103229]
- Tiago Filipe Borges Bento – [2000719]

### 🎓 Orientação científica

* Professor Doutor Ricardo José Vieira Baptista

### 🧩 Consultoria externa

- Mara Teixeira (Educadora de Infância)
- Elisabete Lopes (Professora 1.º ciclo)
- Irina Afonso (Terapeuta da Fala)

---

## 📜 Licença

Este projeto é distribuído para fins académicos e de demonstração. Para mais informações, consultar os autores do projeto.
