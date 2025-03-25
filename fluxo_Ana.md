# 👤 Fluxo de Trabalho Git – Ana

Este guia é **exclusivo** para ti. Aqui encontras todos os passos para trabalhar corretamente no projeto **Mundo das Palavras**.

---

## 🧭 Branch pessoal: `dev_Ana`

Toda a tua programação deve ser feita nesta branch.

---

## 🚀 Começar a trabalhar

### 1. Clonar o repositório

```bash
<<<<<<< HEAD
git clone https://github.com/Mundo-das-Palavras/MundodasPalavras.git
cd MundodasPalavras
=======
git clone https://github.com/Mundo-das-Palavras/Mundo-das-Palavras.git
cd Mundo-das-Palavras
>>>>>>> mundo_das_palavras
```

### 2. Ir para a tua branch

```bash
<<<<<<< HEAD
git checkout dev_Ana
```

> ⚠️ Se a branch ainda não existir localmente:

```bash
git fetch origin
git checkout dev_Ana
=======
git checkout dev_Ana dev_Ana
```

> ⚠️ Se a branch ainda não existir localmente:
```bash
git fetch origin
git checkout dev_Ana dev_Ana
>>>>>>> mundo_das_palavras
```

---

## 🔄 Atualizar o teu código

```bash
<<<<<<< HEAD
git checkout mundo_das_palavras
git pull origin mundo_das_palavras

git checkout dev_Ana
=======
git checkout dev_Ana mundo_das_palavras
git pull origin mundo_das_palavras

git checkout dev_Ana dev_Ana
>>>>>>> mundo_das_palavras
git merge mundo_das_palavras
```

---

## ✍️ Guardar alterações

```bash
git add .
git commit -m "Ana: descreve aqui o que fizeste"
git push origin dev_Ana
```

---

## 🧪 Enviar para teste

```bash
<<<<<<< HEAD
git checkout test
=======
git checkout dev_Ana test
>>>>>>> mundo_das_palavras
git merge dev_Ana
git push origin test
```

---

## ✅ Finalizar

```bash
<<<<<<< HEAD
git checkout mundo_das_palavras
git merge test
git push origin mundo_das_palavras
```
=======
git checkout dev_Ana mundo_das_palavras
git merge test
git push origin mundo_das_palavras
```

---

## 💡 Dica

Trabalha sempre na tua branch e mantém-te sincronizado com a `mundo_das_palavras`. Dúvidas? Fala com a equipa ou com o GPT 😄
>>>>>>> mundo_das_palavras
