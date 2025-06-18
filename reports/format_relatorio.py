import re
from collections import defaultdict

INPUT = "test_report.txt"
OUTPUT = "report.md"

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
    m = re.search(r"test/([a-zA-Z0-9_]+)/([a-zA-Z0-9_]+)/[^/]+\.dart", linha)
    if m:
        return f"{m.group(1)}/{m.group(2)}"
    m = re.search(r"test/([a-zA-Z0-9_]+)/[^/]+\.dart", linha)
    if m:
        return m.group(1)
    return "outros"

def extrair_estado_nome_teste(linha):
    if "[E]" in linha:
        nome = linha.split(":")[-1].replace("[E]", "").strip()
        return "❌", nome
    m = re.match(r"^00:00\s+\+\d+(?:\s+-\d+)?\s*:\s.*?:\s(.+)$", linha)
    if m:
        return "✅", m.group(1).strip()
    return None, None

def extrair_erro_bloco(linhas, idx):
    bloco = []
    i = idx + 1
    while i < len(linhas):
        l = linhas[i]
        if not l.strip() or l.startswith("00:00"):
            break
        if "Expected:" in l or "Actual:" in l:
            bloco.append(l.strip())
        i += 1
    return bloco

def nome_entidade(sec, nome, linha):
    # Para os jogos, entidade é o nome do ficheiro (ex: IdentifyLettersNumbers)
    if sec == "widget/games":
        mfile = re.search(r"test/widget/games/([a-zA-Z0-9_]+)_test\.dart", linha)
        if mfile:
            return ''.join([w.capitalize() for w in mfile.group(1).split('_')])
    # Para outras seções, é o primeiro token
    return nome.split()[0]

def desc_teste(sec, entidade, nome):
    if sec == "widget/games":
        # Remove prefixos tipo "Lógica do <NomeJogo>", "Logica do <NomeJogo>Logic", "Logic do <NomeJogo>", etc.
        padrao = re.compile(
            r"^(L[oó]gica do|Logic do|Logic)?\s*"  # cobre 'Lógica do', 'Logica do', 'Logic do'
            + re.escape(entidade) + r"(Logic)?\s*",
            re.IGNORECASE
        )
        return padrao.sub("", nome).strip(" :-–")
    else:
        # Para outros casos, remove só a entidade se vier no início
        return re.sub(rf"^{re.escape(entidade)}\s*", "", nome).strip(" :-–")


def main():
    estrutura = defaultdict(lambda: defaultdict(list))
    outros = []
    all_pass = True

    with open(INPUT, "r", encoding="utf-8", errors="replace") as f:
        linhas = f.readlines()

    for idx, linha in enumerate(linhas):
        if linha.strip().startswith("00:00 +0: loading") or "All tests passed!" in linha:
            continue
        status, nome = extrair_estado_nome_teste(linha)
        if not nome:
            continue
        sec = categoria_da_linha(linha)
        title = SEC_TITLES.get(sec, sec.capitalize())
        entidade = nome_entidade(sec, nome, linha)
        desc = desc_teste(sec, entidade, nome)
        if status == "❌":
            all_pass = False
            erro_bloc = extrair_erro_bloco(linhas, idx)
            erro_md = "\n      ```text\n" + "\n".join(erro_bloc) + "\n      ```" if erro_bloc else ""
        else:
            erro_md = ""
        estrutura[title][entidade].append((status, desc, erro_md))

    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("# Relatório de testes\n\n")
        # Unitários
        f.write("## Testes unitários\n\n")
        for sec in ["Lógica", "Modelos", "Utilidades"]:
            entidade_dict = estrutura.get(sec)
            if not entidade_dict:
                continue
            f.write(f"- {sec}\n")
            for ent, testes in entidade_dict.items():
                f.write(f"  - {ent}\n")
                for status, desc, erro in testes:
                    f.write(f"    - {status} {desc}{erro}\n")
            f.write("\n")
        # Widget
        f.write("## Testes widget\n\n")
        for sec in ["Jogos", "Widgets Comuns", "Ecrãs"]:
            entidade_dict = estrutura.get(sec)
            if not entidade_dict:
                continue
            f.write(f"- {sec}\n")
            for ent, testes in entidade_dict.items():
                f.write(f"  - {ent}\n")
                for status, desc, erro in testes:
                    f.write(f"    - {status} {desc}{erro}\n")
            f.write("\n")
        # Integração
        f.write("## Testes de integração\n\n")
        for sec in ["Integração Base de Dados", "Integração Flows"]:
            entidade_dict = estrutura.get(sec)
            if not entidade_dict:
                continue
            f.write(f"- {sec}\n")
            for ent, testes in entidade_dict.items():
                f.write(f"  - {ent}\n")
                for status, desc, erro in testes:
                    f.write(f"    - {status} {desc}{erro}\n")
            f.write("\n")
        # Outros
        if outros:
            f.write("## Outros\n")
            for item in outros:
                f.write(f"- {item}\n")
            f.write("\n")
        # Conclusão
        f.write("## Conclusão Geral da Aplicação\n\n")
        f.write("✅ Todos os testes passaram!\n" if all_pass else "❌ Alguns testes falharam!\n")
    print(f"Relatório formatado gerado em: {OUTPUT}")

if __name__ == "__main__":
    main()
