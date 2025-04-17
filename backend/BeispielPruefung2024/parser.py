import re
from pathlib import Path

import re

def parse_abitur_latex(text, fach="Mathematik", jahr="2024"):
    aufgaben = re.split(r'\\section\*\{Aufgabe ([^\}]+)\}', text)
    lösungen = re.split(r'\\section\*\{Aufgabe ([^\}]+):\}', text)

    # Wir nehmen die Lösungsteile ab der ersten Lösung
    lösungen = lösungen[1:]  # [Nummer1, Lösung1, Nummer2, Lösung2, ...]
    aufgaben = aufgaben[1:]  # [Nummer1, Aufgabe1, Nummer2, Aufgabe2, ...]

    tupel_liste = []

    for i in range(0, len(aufgaben), 2):
        nummer = aufgaben[i].strip()
        aufgabe = aufgaben[i+1].strip()
        # Finde die zugehörige Lösung
        lösung = ""
        for j in range(0, len(lösungen), 2):
            if lösungen[j].strip() == nummer:
                lösung = lösungen[j+1].strip()
                break
        tupel_liste.append((fach, jahr, nummer, aufgabe, lösung))

    return tupel_liste

file = __file__
file_path = Path.joinpath(Path(file).parent,"testpruefung.tex")

with open(file_path, "r", encoding="utf-8") as f:
    text = f.read()

tupel = parse_abitur_latex(text)
for eintrag in tupel:
    print(eintrag)
    print("\n\n")

