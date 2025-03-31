
# 🧭 Guia de Trabalho com a Branch `testes`

## 👩‍💻 Exemplo: Developer Ana

---

### 🔹 1. Confirmar que estás na tua branch pessoal (`dev_Ana`)

```bash
git checkout dev_Ana
```

---

### 🔹 2. Atualizar a tua branch `dev_Ana` com as últimas alterações testadas (branch `testes`)

```bash
git merge testes
```

> ⚠️ Importante: Se houver conflitos, a versão da `testes` deve prevalecer, pois é a mais recente e estável.

---

### 🔹 3. Trabalhar na tua branch `dev_Ana` com as tuas alterações

- Edita o código, testa, e assegura-te que tudo funciona como esperado.
- Usa boas práticas de desenvolvimento e commits explicativos.

---

### 🔹 4. Confirmar alterações antes de enviar

```bash
git status
git add .
git commit -m "Descrição clara das alterações feitas pela Ana"
```

---

### 🔹 5. Enviar as alterações da `dev_Ana` para o GitHub

```bash
git push origin dev_Ana
```

---

### 🔹 6. Quando terminares o teu trabalho, funde a tua branch na `testes`

```bash
git checkout testes
git merge dev_Ana
```

---

### 🔹 7. Atualizar a branch `testes` no GitHub (para os outros developers)

```bash
git push origin testes
```

---

## 📌 Notas Finais

- ✅ Trabalha sempre na tua própria branch (`dev_Nome`).
- 🔁 Atualiza regularmente com a branch `testes` para não ficares desatualizado.
- 🔐 A branch `testes` representa a base testada e estável da aplicação.
- ☁️ A `testes` deve estar sempre sincronizada com o GitHub para que todos possam aceder à versão mais recente e validada.
