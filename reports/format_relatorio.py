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

NOMES_HUMANOS = {
    "AllGames": "AllGames",
    "LevelManager": "LevelManager",
    "ConquerManager": "ConquerManager",
    # Modelos:
    "CharacterModel": "CharacterModel",
    "UserModel": "UserModel",
    "WordModel": "WordModel",
    # Outros se necessário...
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

def nome_entidade(sec, nome, linha):
    mfile = re.search(r"test/[a-zA-Z0-9_]+/[a-zA-Z0-9_]+/([a-zA-Z0-9_]+)_test\.dart", linha)
    if mfile:
        nome_base = ''.join([w.capitalize() for w in mfile.group(1).split('_')])
        return NOMES_HUMANOS.get(nome_base, nome_base)
    return nome.split()[0]

def desc_teste(entidade, nome):
    # Remove o nome da entidade do início (seguido de espaços, dois pontos, hífen, etc.)
    desc = re.sub(rf"^{re.escape(entidade)}[\s:\-–\.]*", "", nome, flags=re.IGNORECASE)
    # Limpa espaços extra no início
    desc = desc.lstrip()
    return desc[0].upper() + desc[1:] if desc else nome



def main():
    estrutura = defaultdict(lambda: defaultdict(list))
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
        desc = desc_teste(entidade, nome)
        if status == "❌":
            all_pass = False
        estrutura[title][entidade].append((status, desc))

    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("# Relatório de testes\n\n")
        # Unitários
        f.write("## Testes unitários\n\n")
        for sec in ["Lógica", "Modelos", "Utilidades"]:
            entidade_dict = estrutura.get(sec)
            if not entidade_dict:
                continue
            f.write(f"- {sec}\n")
            # Ordem manual típica: LevelManager, AllGames, ConquerManager
            if sec == "Lógica":
                ordem_logica = ["AllGames", "LevelManager", "ConquerManager"]
                entidades_ordenadas = sorted(
                    entidade_dict,
                    key=lambda x: (ordem_logica.index(x) if x in ordem_logica else 999, x)
                )
            else:
                entidades_ordenadas = entidade_dict.keys()
            for ent in entidades_ordenadas:
                f.write(f"  - {ent}\n")
                for status, desc in estrutura[sec][ent]:
                    f.write(f"    - {status} {desc}\n")
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
                for status, desc in testes:
                    f.write(f"    - {status} {desc}\n")
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
                for status, desc in testes:
                    f.write(f"    - {status} {desc}\n")
            f.write("\n")
        # Conclusão
        f.write("## Conclusão Geral da Aplicação\n\n")
        f.write("✅ Todos os testes passaram!\n" if all_pass else "❌ Alguns testes falharam!\n")
    print(f"Relatório formatado gerado em: {OUTPUT}")

if __name__ == "__main__":
    main()
