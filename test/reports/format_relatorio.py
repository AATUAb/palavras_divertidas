import re
from collections import defaultdict, OrderedDict

INPUT = "relatorio.txt"
OUTPUT = "relatorio_formatado.md"

# Define os títulos de secção por diretório principal
SEC_TITLES = OrderedDict([
    ("unit", "Resumo dos testes unitários"),
    ("widget", "Resumo dos testes widget"),
    ("integration", "Resumo dos testes de integração"),
])

def categoria_da_linha(linha):
    """
    Extrai até dois níveis: ex: unit/logic, widget/games, integration/db
    """
    match = re.search(r"test/([a-zA-Z0-9_]+)/([a-zA-Z0-9_]+)/[^/]+\.dart", linha)
    if match:
        return match.group(1), f"{match.group(1)}/{match.group(2)}"
    match = re.search(r"test/([a-zA-Z0-9_]+)/[^/]+\.dart", linha)
    if match:
        return match.group(1), match.group(1)
    return "outros", "outros"

def extrair_nome_teste(linha):
    match = re.match(r"^.*?: .*?: (.+)$", linha)
    if match:
        return "- " + match.group(1).strip()
    return None

def main():
    # Estrutura: {secao_principal: {subsecao: [testes]}}
    secao_dict = {sec: defaultdict(list) for sec in SEC_TITLES}
    outros = defaultdict(list)

    with open(INPUT, "r", encoding="utf-8", errors="replace") as f:
        linhas = f.readlines()

    for linha in linhas:
        if linha.strip().startswith("00:00 +0: loading"):
            continue
        if "All tests passed!" in linha:
            outros["outros"].append("\n\n✅ **Todos os testes passaram!**\n")
            continue
        nome = extrair_nome_teste(linha)
        if nome:
            secao, subsecao = categoria_da_linha(linha)
            if secao in secao_dict:
                secao_dict[secao][subsecao].append(nome)
            else:
                outros[subsecao].append(nome)

    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("# Relatório de testes\n\n")
        for secao, secao_label in SEC_TITLES.items():
            f.write(f"## {secao_label}\n\n")
            for subsecao in sorted(secao_dict[secao]):
                f.write(f"### {subsecao}\n")
                f.write("\n".join(secao_dict[secao][subsecao]))
                f.write("\n\n")
        # Outros e sucesso global no fim
        for subsecao in outros:
            f.write("\n".join(outros[subsecao]))
        f.write("\n")

    print(f"Relatório formatado gerado em: {OUTPUT}")

if __name__ == "__main__":
    main()
