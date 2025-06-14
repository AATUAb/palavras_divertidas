import re

INPUT = "relatorio.txt"
OUTPUT = "relatorio_formatado.md"

import re

def extrair_linhas_importantes(linha):
    # Ignora linhas de loading e caminhos
    if linha.strip().startswith("00:00 +0: loading"):
        return None
    # Todos os testes passaram
    if "All tests passed!" in linha:
        return "\n\n✅ **Todos os testes passaram!**\n"
    # Extrai só o texto depois do segundo ": "
    match = re.match(r"^.*?: .*?: (.+)$", linha)
    if match:
        return "- " + match.group(1).strip()
    return None

def main():
    with open(INPUT, "r", encoding="utf-8", errors="replace") as f:
        linhas = f.readlines()

    resultados = [extrair_linhas_importantes(l) for l in linhas]
    resultados = [l for l in resultados if l]

    # Cabeçalho do relatório
    cabecalho = "# Relatório de Testes Unitários\n\n"
    cabecalho += "## Resumo dos testes\n\n"

    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write(cabecalho)
        f.write("\n".join(resultados))

    print(f"Relatório formatado gerado em: {OUTPUT}")

if __name__ == "__main__":
    main()
