# Fluxo de Trabalho da Ana 🧠

Este ficheiro descreve o processo que a **Ana** deve seguir para trabalhar com o repositório do projeto *Mundo das Palavras* de forma organizada, segura e integrada com os restantes devs.

---

## 🔧 Primeira vez a configurar o projeto

1. **Abrir terminal no VS Code** ou no sistema.
2. **Clonar o repositório principal:**

```bash
git clone https://github.com/Mundo-das-Palavras/Mundo-das-Palavras.git
cd Mundo-das-Palavras
```

3. **Trocar para a branch de desenvolvimento da Ana:**

```bash
git checkout dev_Ana
```

> ⚠️ Se a branch ainda não existir localmente, este comando vai buscá-la automaticamente do GitHub.

4. **Instalar todas as dependências do Flutter:**

```bash
flutter pub get
```

5. **Abrir o projeto no VS Code e iniciar o desenvolvimento.**

---

## 💾 Guardar o trabalho feito

1. **Adicionar ficheiros alterados:**

```bash
git add .
```

2. **Fazer commit com mensagem clara:**

```bash
git commit -m "feat: [descrição clara da tarefa feita]"
```

3. **Enviar para o GitHub (push):**

```bash
git push origin dev_Ana
```

---

## 🔄 Manter o projeto atualizado com a branch de testes

Antes de começares um novo dia de trabalho:

```bash
git checkout testes
git pull origin testes
git checkout dev_Ana
git merge testes
```

Resolve qualquer conflito se houver, testa bem e depois:

```bash
git push origin dev_Ana
```

---

## ✅ Submeter para testes

Quando quiseres que o teu trabalho vá para a branch de **testes**, pede revisão ou cria um Pull Request no GitHub da `dev_Ana` para `testes`.

---

## 👩‍💻 Dúvidas?

Fala com o responsável de repositório ou com o GPT favorito da equipa 😄
