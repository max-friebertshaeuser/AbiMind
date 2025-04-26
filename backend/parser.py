import re
from dbm import error

import firebase_admin
from firebase_admin import credentials, storage, firestore
from pathlib import Path
import base64


def init_firebase():
    cred = credentials.Certificate("F:/Python/AbiMind/firebase/abimind-2caf8-firebase-adminsdk-fbsvc-aec7ccfb5d.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    return db


def encode_image_to_base64(image_path: Path) -> str:
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    return encoded_string


def save_exercise_to_firestore(db, fach: str, jahr: str, teil: str, aufgabe_name: str,
                               aufgabe_text: str, aufgabe_bild_pfade, loesung_text: str, loesung_bild_pfade):
    aufgabe_bilder_base64 = [encode_image_to_base64(path) for path in aufgabe_bild_pfade]
    loesung_bilder_base64 = [encode_image_to_base64(path) for path in loesung_bild_pfade]

    doc_ref = db.collection("Abitur").document(f"{fach}_{jahr}")

    # Merke: Teil wie Pflichtteil/Analysis usw. wird als verschachtelte Map gespeichert
    doc_ref.set({
        teil: {
            aufgabe_name: {
                "aufgabe_text": aufgabe_text,
                "aufgabe_bilder": aufgabe_bilder_base64,
                "loesung_text": loesung_text,
                "loesung_bilder": loesung_bilder_base64
            }
        }
    }, merge=True)  # merge=True damit vorhandene Aufgaben nicht überschrieben werden


def find_image_paths_from_latex(latex_text: str, tex_file_path: str):
    image_paths = []

    tex_dir = Path(tex_file_path).parent  # Ordner, in dem die .tex-Datei liegt

    # Regex: Nur lokale Bilder, keine URLs
    pattern = r'\\includegraphics[^\{]*\{(?!https?://)([^}]+)\}'

    for match in re.finditer(pattern, latex_text):
        image_name = match.group(1)
        image_path_jpg = tex_dir.joinpath("images", (image_name + ".jpg"))
        image_path_png = tex_dir.joinpath("images", (image_name + ".png"))

        if image_path_jpg.exists():
            image_paths.append(image_path_jpg)
        elif image_path_png.exists():
            image_paths.append(image_path_png)
        else:
            print(f"Bilddatei nicht gefunden: {image_name}")
            raise FileNotFoundError

    return image_paths


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

        first_paths = []
        second_paths = []
        annex_paths = []

        if "includegraphics" in part:
            paths = find_image_paths_from_latex(part, path_name)
            if first:
                first_paths = paths
            if second:
                second_paths = paths
            if annex:
                annex_paths = paths

        if first:
            exercises.append([name, part, first_paths])
            first = False

        if second:
            for exercise in exercises:
                if exercise[0] == name:
                    exercise.append(part)
                    exercise.append(second_paths)
            second = False

        if annex:
            for exercise in exercises:
                if exercise[0] == name:
                    exercise[1] += "\n" + part
                    exercise[2].extend(annex_paths)
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
    db = init_firebase()
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
""" + "\\section*{" + year + ", " + exercise[0] + "}\n" + exercise[1] + "\n\\end{document}"

            array.append((subject, year, task, exercise[0], latex_exercise, exercise[2], exercise[3], exercise[4]))

    for entry in array:
        print(entry)
        # print("\n")
        # print(entry[4])

    for entry in array:
        fach, jahr, teil, aufgabe_name, aufgabe_text, aufgabe_bild_pfade, loesung_text, loesung_bild_pfade = entry
        save_exercise_to_firestore(db, fach, jahr, teil, aufgabe_name, aufgabe_text, aufgabe_bild_pfade, loesung_text, loesung_bild_pfade)

if __name__ == '__main__':
    main()