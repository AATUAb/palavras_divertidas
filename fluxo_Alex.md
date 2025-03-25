# 👤 Fluxo de Trabalho Git – Alexandre

Este guia é **exclusivo** para ti. Aqui encontras todos os passos para trabalhar corretamente no projeto **Mundo das Palavras**.

---

## 🧭 Branch pessoal: `dev_Alexandre`

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
git checkout dev_Alexandre
```

> ⚠️ Se a branch ainda não existir localmente:
```bash
git fetch origin
git checkout dev_Alexandre
```

---

## 🔄 Atualizar o teu código

```bash
git checkout mundo_das_palavras
git pull origin mundo_das_palavras

git checkout dev_Alexandre
git merge mundo_das_palavras
```

---

## ✍️ Guardar alterações

```bash
git add .
git commit -m "Alexandre: descreve aqui o que fizeste"
git push origin dev_Alexandre
```

---

## 🧪 Enviar para teste

```bash
git checkout test
git merge dev_Alexandre
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