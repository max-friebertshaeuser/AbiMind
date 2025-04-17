import re
from pathlib import Path

def parse_tasks(text):
    # Regex für Pflicht- und Wahlaufgaben (P1, P2, ..., W1, W2, ...)
    pattern = re.compile(r'\b(P\d+|W\d+)\b(.*?)(?=\n(?:P\d+|W\d+)\b|\Z)', re.DOTALL)

    aufgaben = {}
    for match in pattern.finditer(text):
        aufgaben_nr = match.group(1).strip()
        aufgaben_text = match.group(2).strip()
        aufgaben[aufgaben_nr] = aufgaben_text

    return aufgaben

def read_file_and_parse(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    return parse_tasks(content)

if __name__ == "__main__":
    file = __file__
    file_path = Path.joinpath(Path(file).parent,"")
    result = read_file_and_parse(file_path)
    for key, value in result.items():
        print(f"{key}:\n{value}\n{'-'*40}")
