import re
from collections import defaultdict

INPUT = "test_report.txt"
OUTPUT = "report.md"

SEC_TITLES = {
    "unit/logic":    "Lógica",
    "unit/models":   "Modelos",
    "unit/utils":    "Utilidades",
    "widget/games":  "Jogos",
    "widget/common": "Widgets Comuns",
    "widget/screens":"Ecrãs",
    "integration/db":    "Integração Base de Dados",
    "integration/flows": "Integração Flows",
}

SubTitles = {
    "AllGames":        "AllGames",
    "LevelManager":    "LevelManager",
    "ConquestManager": "ConquestManager",
    "CharacterModel":  "CharacterModel",
    "UserModel":       "UserModel",
    "WordModel":       "WordModel",
}

def categoria_da_linha(linha):
    m = re.search(r"test/(integration)/(db|flows)/[^/]+\.dart", linha)
    if m:
        return f"{m.group(1)}/{m.group(2)}"
    if re.search(r"test/integration/[^/]+\.dart", linha):
        return "integration"
    m = re.search(r"test/([A-Za-z0-9_]+)/([A-Za-z0-9_]+)/[^/]+\.dart", linha)
    if m:
        return f"{m.group(1)}/{m.group(2)}"
    m = re.search(r"test/([A-Za-z0-9_]+)/[^/]+\.dart", linha)
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
    m = re.search(r"test/[A-Za-z0-9_]+/[A-Za-z0-9_]+/([A-Za-z0-9_]+)_test\.dart", linha)
    if m:
        base = ''.join(w.capitalize() for w in m.group(1).split('_'))
        return SubTitles.get(base, base)
    return nome.split()[0]

def desc_teste(entidade, nome):
    s = re.sub(rf"^{re.escape(entidade)}[\s:\-–\.]*", "", nome, flags=re.IGNORECASE)
    s = re.sub(r"^Integration[\s:\-–\.]*", "", s, flags=re.IGNORECASE)
    s = s.lstrip()
    return s[:1].upper() + s[1:] if s else nome

def main():
    estrutura = defaultdict(lambda: defaultdict(dict))
    all_pass = True

    with open(INPUT, "r", encoding="utf-8", errors="replace") as f:
        for linha in f:
            if linha.startswith("00:00 +0: loading") or "All tests passed!" in linha:
                continue
            status, nome = extrair_estado_nome_teste(linha)
            if not nome:
                continue
            sec = categoria_da_linha(linha)
            title = SEC_TITLES.get(sec, sec.capitalize())
            ent   = nome_entidade(sec, nome, linha)
            desc  = desc_teste(ent, nome)

            # Mantém o primeiro estado encontrado (❌ prevalece apenas se não existir ✅).
            prev_status = estrutura[title][ent].get(desc)
            if prev_status == "✅":
                continue
            estrutura[title][ent][desc] = status

            if status == "❌":
                all_pass = False

    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("# Relatório de testes\n\n")

        # Unitários
        f.write("## Testes unitários\n\n")
        for sec in ["Lógica", "Modelos", "Utilidades"]:
            bloco = estrutura.get(sec)
            if not bloco: continue
            f.write(f"- {sec}\n")
            if sec == "Lógica":
                ordem = ["AllGames","LevelManager","ConquestManager"]
                ents  = sorted(bloco, key=lambda x: (ordem.index(x) if x in ordem else 999, x))
            else:
                ents = bloco.keys()
            for ent in ents:
                f.write(f"  - {ent}\n")
                for desc, st in bloco[ent].items():
                    f.write(f"    - {st} {desc}\n")
            f.write("\n")

        # Widget
        f.write("## Testes widget\n\n")
        for sec in ["Jogos","Widgets Comuns","Ecrãs"]:
            bloco = estrutura.get(sec)
            if not bloco: continue
            f.write(f"- {sec}\n")
            for ent, testes in bloco.items():
                f.write(f"  - {ent}\n")
                for desc, st in testes.items():
                    f.write(f"    - {st} {desc}\n")
            f.write("\n")

        # Integração
        f.write("## Testes de integração\n\n")
        for sec in ["Integração Base de Dados","Integração Flows"]:
            bloco = estrutura.get(sec)
            if not bloco: continue
            f.write(f"- {sec}\n")
            for ent, testes in bloco.items():
                f.write(f"  - {ent}\n")
                for desc, st in testes.items():
                    f.write(f"    - {st} {desc}\n")
            f.write("\n")

        # Conclusão
        f.write("## Conclusão Geral da Aplicação\n\n")
        f.write("✅ Todos os testes passaram!\n" if all_pass else "❌ Alguns testes falharam!\n")

    print(f"Relatório gerado em: {OUTPUT}")

if __name__ == "__main__":
    main()
