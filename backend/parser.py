import re
from dbm import error

import firebase_admin
from firebase_admin import credentials, storage, firestore
from pathlib import Path
import base64
import uuid


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
                               aufgabe_text: str, aufgabe_bild_pfade, aufgabe_bildnamen,
                               loesung_text: str, loesung_bild_pfade, loesung_bildnamen):
    aufgabe_bilder_base64 = [encode_image_to_base64(path) for path in aufgabe_bild_pfade]
    loesung_bilder_base64 = [encode_image_to_base64(path) for path in loesung_bild_pfade]

    doc_ref = db.collection("Abitur").document(f"{fach}_{jahr}")

    doc_ref.set({
        teil: {
            aufgabe_name: {
                "aufgabe_text": aufgabe_text,
                "aufgabe_bilder": aufgabe_bilder_base64,
                "aufgabe_bildnamen": aufgabe_bildnamen,
                "loesung_text": loesung_text,
                "loesung_bilder": loesung_bilder_base64,
                "loesung_bildnamen": loesung_bildnamen
            }
        }
    }, merge=True)

def image_to_dict(image_path: Path):
    with open(image_path, "rb") as f:
        content = base64.b64encode(f.read()).decode("utf-8")
    return {
        "uid": str(uuid.uuid4()),
        "title": image_path.name,
        "content": content
    }

def save_to_firestore_structure(db, subject: str, year: str, topic: str, exercise_data, exam_uid):
    collection_ref = db.collection("Abitur")
    doc_ref = collection_ref.document(exam_uid)


    for exercise in exercise_data:
        aufgabe_name = exercise[0][0]
        aufgabe_text = exercise[0][1]
        aufgabe_bilder = exercise[0][2]

        aufgabe_uid = str(uuid.uuid4())
        aufgabe_entry = {
            "uid": aufgabe_uid,
            "title": aufgabe_name,
            "description": aufgabe_text,
            "images": {},
            "questions": {}
        }

        # Encode Aufgabe-Bilder
        for img_path in aufgabe_bilder:
            img = image_to_dict(img_path)
            aufgabe_entry["images"][img["uid"]] = {
                "title": img["title"],
                "content": img["content"]
            }

        # Fragen + Lösungen
        for part in exercise[1:]:
            question_title = part[0]
            question_text = part[1]
            question_images = part[2]
            solution_text = part[3]
            solution_images = part[4]

            question_uid = str(uuid.uuid4())
            question_entry = {
                "uid": question_uid,
                "title": question_title,
                "description": question_text,
                "images": {},
                "solution": {
                    "description": solution_text,
                    "images": {}
                }
            }

            for img_path in question_images:
                img = image_to_dict(img_path)
                question_entry["images"][img["uid"]] = {
                    "title": img["title"],
                    "content": img["content"]
                }

            for img_path in solution_images:
                img = image_to_dict(img_path)
                question_entry["solution"]["images"][img["uid"]] = {
                    "title": img["title"],
                    "content": img["content"]
                }

            aufgabe_entry["questions"][question_uid] = question_entry

        doc_ref.set({
            year: year,
            subject: subject,
            topic: {
                aufgabe_uid: aufgabe_entry
            }
        }, merge=True)


def find_and_strip_images(latex_text: str, tex_file_path: str) -> tuple[str, list[Path]]:

    image_paths = []
    tex_dir = Path(tex_file_path).parent

    pattern = r'(\\includegraphics[^\{]*\{(?!https?://)([^}]+)\})'

    def replacer(match):
        image_name = match.group(2)
        image_path_jpg = tex_dir.joinpath("images", f"{image_name}.jpg")
        image_path_png = tex_dir.joinpath("images", f"{image_name}.png")

        if image_path_jpg.exists():
            image_paths.append(image_path_jpg)
        elif image_path_png.exists():
            image_paths.append(image_path_png)
        else:
            print(f"Bild nicht gefunden: {image_name}")
            raise FileNotFoundError

        return ""  # entfernt das includegraphics aus dem Text

    # Text bereinigen + Bilderpfade sammeln
    cleaned_text = re.sub(pattern, replacer, latex_text)

    return cleaned_text, image_paths


def get_year(path_name: str):
    year = ""
    match = re.search(r"Latex(\d{4})", path_name)
    if match:
        year = match.group(1)

    return year


def get_topic(path_name: str):
    task = ""
    if "Pflichtaufgaben" in path_name or "Wahlaufgabe" in path_name or "Pflichtteil" in path_name:
        task = "mandatory"

    if "Analysis" in path_name:
        task = "analysis"

    elif "Analytische_Geometrie" in path_name or "Analyt_Geometrie" in path_name:
        task = "geometry"

    elif "Stochastik" in path_name:
            task = "stochastic"

    return task


def split_subquestions(latex_text: str, exercise_name: str):
    pattern = r'(?:^|\n)\s*([a-zA-Z]\))'

    # Split by pattern, but keep delimiters
    parts = re.split(pattern, latex_text)

    subquestions = []
    current_title = None
    current_content = ""

    if parts[0].strip():
        subquestions.append([exercise_name, parts[0].strip()])

    for part in parts:
        if not part.strip():
            continue
        # part looks like "a)", "(a)" or "\textbf{a}"
        if re.match(r'^[a-zA-Z]\)$', part.strip()):
            if current_title:
                subquestions.append([current_title, current_content.strip()])
            current_title = re.sub(r'[\\\{\}\(\)]', '', part).replace("textbf", "").strip()
            current_content = ""
        else:
            current_content += part

    if current_title:
        subquestions.append([current_title, current_content.strip()])

    return subquestions


def split_into_exercises(latex_text: str, path_name: str):
    names = []
    exercises = []
    first: bool = False
    second: bool = False
    annex: bool = False
    name = ""

    parts = re.split(r'(\\section\*\{[^\}]*\})', latex_text)

    for part in parts:

        questions = split_subquestions(part, name)
        sub_exercises = []
        question_pictures = []

        if first or second or annex:

            if not annex:
                for question in questions:
                    question_pictures = []
                    if "includegraphics" in question[1]:
                        new_text = find_and_strip_images(question[1], path_name)
                        question[1] = new_text[0]
                        question_pictures.extend(new_text[1])

                    if first:
                        sub_exercises.append([question[0], question[1], question_pictures])

                    if second:
                        sub_exercises.append([question[0], question[1], question_pictures])

            if first:
                exercises.append(sub_exercises)

            if second:
                for exercise in exercises:
                    if exercise[0][0] == name:
                        if len(exercise) > 1:
                            for i in range(len(exercise)-1):
                                try:
                                    exercise[i+1].extend([sub_exercises[i][1], sub_exercises[i][2]])
                                except IndexError:
                                    print("warum")
                            break
                        else:
                            # wenn keine Unterpunkte (a, b...) existieren wird einfach nur die Loesung abgespeichert
                            try:
                                exercise.append([name, "", [],sub_exercises[0][1], sub_exercises[0][2]])
                            except IndexError:
                                print("warum2")
                            break

            if annex:
                for exercise in exercises:
                    if exercise[0][0] == name:
                        new_text = find_and_strip_images(part, path_name)
                        exercise[0][2].extend(new_text[1])
                        break

            first = False
            second = False
            annex = False

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

    uid_dict = {}

    for exam in exams:
        year = ""
        subject = "math"
        topic = ""
        latex_text = ""
        exam_uid = ""

        exam = exam.as_posix()

        year = get_year(exam)

        if uid_dict.get(year):
            exam_uid = uid_dict[year]
        else:
            exam_uid = str(uuid.uuid4())
            uid_dict[year] = exam_uid

        topic = get_topic(exam)

        with open(exam, "r", encoding="utf-8") as f:
            latex_text = f.read()

        exercises = split_into_exercises(latex_text, exam)

        for exercise in exercises:
            print(exercise)

        save_to_firestore_structure(db, subject, year, topic, exercises, exam_uid)




if __name__ == '__main__':
    main()