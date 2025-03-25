# 👤 Fluxo de Trabalho Git – Tiago

Este guia é **exclusivo** para ti. Aqui encontras todos os passos para trabalhar corretamente no projeto **Mundo das Palavras**.

---

## 🧭 Branch pessoal: `dev_Tiago`

Toda a tua programação deve ser feita nesta branch.

---

## 🚀 Começar a trabalhar

### 1. Clonar o repositório

```bash
git clone https://github.com/Mundo-das-Palavras/MundodasPalavras.git
cd MundodasPalavras
```

### 2. Ir para a tua branch

```bash
git checkout dev_Tiago
```

> ⚠️ Se a branch ainda não existir localmente:
```bash
git fetch origin
git checkout dev_Tiago
```

---

## 🔄 Atualizar o teu código

```bash
git checkout mundo_das_palavras
git pull origin mundo_das_palavras

git checkout dev_Tiago
git merge mundo_das_palavras
```

---

## ✍️ Guardar alterações

```bash
git add .
git commit -m "Tiago: descreve aqui o que fizeste"
git push origin dev_Tiago
```

---

## 🧪 Enviar para teste

```bash
git checkout test
git merge dev_Tiago
git push origin test
```

---

## ✅ Finalizar

```bash
git checkout mundo_das_palavras
git merge test
git push origin mundo_das_palavras
```

---

## 💡 Dica

Trabalha sempre na tua branch e mantém-te sincronizado com a `mundo_das_palavras`. Dúvidas? Fala com a equipa ou com o GPT 😄