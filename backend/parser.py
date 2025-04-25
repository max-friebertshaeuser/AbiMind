import re
from pathlib import Path


def get_year(path_name: str):
    year = ""
    match = re.search(r"Latex(\d{4})", path_name)
    if match:
        year = match.group(1)

    return year


def get_task(path_name: str):
    task = ""
    if "Pflichtaufgaben" in path_name or "Wahlaufgabe" in path_name or "Pflichtteil" in path_name:
        task = "Pflichtteil"

    if "Analysis" in path_name:
        task = "Analysis"

    elif "Analytische_Geometrie" in path_name or "Analyt_Geometrie" in path_name:
        task = "Geometrie"

    elif "Stochastik" in path_name:
            task = "Stochastik"

    return task


def split_into_exercises(latex_text: str, path_name: str):
    names = []
    exercises = []
    first: bool = False
    second: bool = False
    annex: bool = False
    name = ""

    parts = re.split(r'(\\section\*\{[^\}]*\})', latex_text)

    for part in parts:

        if first:
            exercises.append([name, part])
            first = False

        if second:
            for exercise in exercises:
                if exercise[0] == name:
                    exercise.append(part)
            second = False

        if annex:
            for exercise in exercises:
                if exercise[0] == name:
                    exercise[1] += "\n" + part
                    annex = False
                    break

        match = re.match(r'\\section\*\{(Aufgabe(?: [IVXLCDM]+)?(?: [A-Z])?(?: ?[WP]?\d+(?:\.\d+)?)?)', part)
        if match:
            if match.group(1) not in names:
                names.append(match.group(1))
                name = match.group(1)
                first = True
            else:
                # loesung
                name = match.group(1)
                second = True

        match = re.match(r'\\section\*\{[^\}]*?([a-zA-Z]{2,}.*?)\s+(Aufgabe \d+)', part)
        if match:
            if match.group(2) not in names:
                print("Something went wrong with the annex")
            else:
                name = match.group(2)
                annex = True

    return exercises



def main():
    file = Path(__file__)
    exams = Path.joinpath(file.parent,"PruefungBW").rglob("*.tex")

    # array contains tuples ("Mathe", "2024", "Pflichtteil/Analysis/Analytische Geometrie/Stochastik", Aufgabe, AufgabenText, Loesung), [Bilder]? noch offen
    array = []

    for exam in exams:
        year = ""
        subject = "Mathe"
        task = ""
        latex_text = ""

        exam = exam.as_posix()

        year = get_year(exam)

        task = get_task(exam)

        with open(exam, "r", encoding="utf-8") as f:
            latex_text = f.read()

        exercises = split_into_exercises(latex_text, exam)

        for exercise in exercises:
            latex_exercise = r"""\documentclass[10pt]{article}
\usepackage[ngerman]{babel}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage{amssymb}
\usepackage[version=4]{mhchem}
\usepackage{stmaryrd}
\usepackage{bbold}
\usepackage{graphicx}
\usepackage[export]{adjustbox}

\begin{document}
""" + "\section*{" + year + ", " + exercise[0] + "}\n" + exercise[1] + "\n\\end{document}"

            array.append((subject, year, task, exercise[0], latex_exercise, exercise[2]))

    for entry in array:
        print(entry)
        # print("\n")
        # print(entry[4])


if __name__ == '__main__':
    main()