import re
from collections import defaultdict

INPUT = "relatorio.txt"
OUTPUT = "relatorio_formatado.md"

SEC_TITLES = {
    "unit/logic": "Lógica",
    "unit/models": "Modelos",
    "unit/utils": "Utilidades",
    "widget/games": "Jogos",
    "widget/common": "Widgets Comuns",
    "widget/screens": "Ecrãs",
    "integration/db": "Integração Base de Dados",
    "integration/flows": "Integração Flows",
}

def categoria_da_linha(linha):
    match = re.search(r"test/([a-zA-Z0-9_]+)/([a-zA-Z0-9_]+)/[^/]+\.dart", linha)
    if match:
        return f"{match.group(1)}/{match.group(2)}"
    match = re.search(r"test/([a-zA-Z0-9_]+)/[^/]+\.dart", linha)
    if match:
        return match.group(1)
    return "outros"

def extrair_estado_nome_teste(linha):
    # Verifica se é linha de falha (tem [E])
    if "[E]" in linha:
        nome = linha.split(":")[-1].replace("[E]", "").strip()
        return "fail", nome
    # Caso contrário, se for linha de teste passou
    match = re.match(r"^00:00\s+\+\d+(?:\s+-\d+)?\s*:\s.*?:\s(.+)$", linha)
    if match:
        nome = match.group(1).strip()
        return "pass", nome
    return None, None

def extrair_erro_bloco(linhas, idx):
    # Extrai apenas Expected/Actual do bloco de erro (até linha vazia ou nova asserção)
    erro = []
    i = idx + 1
    while i < len(linhas):
        l = linhas[i]
        if l.strip() == "" or l.startswith("00:00"):
            break
        if "Expected:" in l or "Actual:" in l:
            erro.append(l.strip())
        i += 1
    return erro

def main():
    secao_dict = defaultdict(list)
    outros = []
    all_tests_passed = True

    with open(INPUT, "r", encoding="utf-8", errors="replace") as f:
        linhas = f.readlines()

    idx = 0
    while idx < len(linhas):
        linha = linhas[idx]
        if linha.strip().startswith("00:00 +0: loading"):
            idx += 1
            continue
        if "All tests passed!" in linha:
            idx += 1
            continue
        estado, nome = extrair_estado_nome_teste(linha)
        if nome:
            if estado == "pass":
                resultado_md = f"- ✅ {nome}"
            elif estado == "fail":
                erro = extrair_erro_bloco(linhas, idx)
                bloco_md = ""
                if erro:
                    bloco_md = "\n```text\n" + "\n".join(erro) + "\n```\n"
                resultado_md = f"- ❌ {nome}{bloco_md}"
                all_tests_passed = False
            else:
                resultado_md = f"- {nome}"
            secao = categoria_da_linha(linha)
            if secao in SEC_TITLES:
                secao_dict[secao].append(resultado_md)
            else:
                outros.append(resultado_md)
        idx += 1

    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("# Relatório de testes\n\n")
        f.write("### Testes unitários\n\n")
        for secao in ["unit/logic", "unit/models", "unit/utils"]:
            if secao_dict[secao]:
                f.write(f"##### {SEC_TITLES[secao]}\n\n")
                f.write("\n".join(secao_dict[secao]) + "\n\n")
        f.write("## Testes widget\n\n")
        for secao in ["widget/games", "widget/common", "widget/screens"]:
            if secao_dict[secao]:
                f.write(f"##### {SEC_TITLES[secao]}\n\n")
                f.write("\n".join(secao_dict[secao]) + "\n\n")
        f.write("## Testes de integração\n\n")
        for secao in ["integration/db", "integration/flows"]:
            if secao_dict[secao]:
                f.write(f"##### {SEC_TITLES[secao]}\n\n")
                f.write("\n".join(secao_dict[secao]) + "\n\n")
        if outros:
            f.write("##### Outros\n\n")
            f.write("\n".join(outros) + "\n\n")
        
        # Conclusão final separada!
        f.write("## Conclusão Geral da Aplicação\n\n")
        if all_tests_passed:
            f.write("✅ **Todos os testes passaram!**\n")
        else:
            f.write("❌ **Alguns testes falharam!**\n")

    print(f"Relatório formatado gerado em: {OUTPUT}")

if __name__ == "__main__":
    main()
