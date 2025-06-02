import os
import re
import uuid
import base64
from pathlib import Path
from collections import defaultdict

import firebase_admin
from firebase_admin import credentials, firestore, storage

import openai  # für die GPT-Anfragen

apiKey = 'key_h3Xk48qmdiU5uB4Q'


# --- 1) Firestore initialisieren ---
def init_firebase():
    # Pfad zu deinem Service-Account-JSON (ggf. anpassen)
    cred = credentials.Certificate("F:/Python/AbiMind/firebase/abimind-2caf8-firebase-adminsdk-fbsvc-aec7ccfb5d.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    return db


# --- 2) Hilfsfunktion: Schnittstelle zu GPT-4.1, gibt einen kurzen Ein-Satz zurück ---
def get_short_description_from_gpt(full_text: str) -> str:
    """
    Sendet den vollen Text einer Aufgabe an GPT-4.1 und bekommt
    als Antwort einen ein-zelligen, deutschsprachigen Beschreibungssatz zurück.
    """
    # Setze deinen API-Key (z.B. aus ENV-Variable)
    openai.api_key = ""

    # Prompt so gestalten, dass GPT versteht, es soll auf Deutsch antworten
    prompt = (
        "Fasse folgende Mathematik-Aufgabe in **einem** kurzen Satz auf Deutsch zusammen, "
        "so dass Schüler*innen sofort wissen, falls mehre unteraufgaben vorhanden sind fasse es so zusammen das es von a nach ... sortiert ist ohne sie zu nennen:\n\n"
        f"{full_text}\n\n"
        "Bitte nur den Satz (ohne Anführungszeichen) zurückgeben, der Satz darf auch kein Latex enthalten einfach nur eine Beschreibung in worten."
    )

    try:
        response = openai.chat.completions.create(
            model="gpt-4o-mini",  # oder "gpt-4.1-turbo" je nach Verfügbarkeit
            messages=[
                {"role": "system", "content": "Du bist ein hilfreicher Assistent, der Mathe-Aufgaben kurz zusammenfasst."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.2,   # möglichst präzise Antwort
            max_tokens=80       # reicht für einen einzigen Satz
        )
        # Die Antwort des Modells (nur der assistant-Teil)
        short_desc = response.choices[0].message.content.strip()
        return short_desc

    except Exception as e:
        print(f"Fehler bei GPT-Anfrage: {e}")
        return ""  # im Fehlerfall leeren String zurückgeben


# --- 3) Hauptfunktion: Aufgaben auslesen, GPT-Abfrage, und zurückschreiben ---
def annotate_exercises_with_short_description():
    db = init_firebase()

    # 1) Alle Examens-Dokumente holen (in deiner Struktur: collection "exams")
    exams_ref = db.collection("exams")
    exams = exams_ref.stream()  # Generator über alle Dokumente

    for exam_doc in exams:
        exam_id = exam_doc.id
        exam_data = exam_doc.to_dict()
        year = exam_data.get("year", "unbekannt")
        subject = exam_data.get("subject", "unbekannt")

        print(f"Verarbeite Exam-Dokument {exam_id} (Jahr {year}, Fach {subject})")

        # 2) In jeder Exam-Doc die Subcollection "exercises" durchlaufen
        exercises_ref = exams_ref.document(exam_id).collection("exercises")
        exercises = exercises_ref.stream()

        for exercise_doc in exercises:
            exercise_id = exercise_doc.id
            exercise_data = exercise_doc.to_dict()

            # Bereits vorhandene shortDescription überspringen
            if "shortDescription" in exercise_data:
                print(f" → Aufgabe {exercise_id} hat bereits eine shortDescription, überspringe.")
                continue

            title = exercise_data.get("title", "")
            main_description = exercise_data.get("description", "")

            # Falls keine Beschreibung vorhanden ist, überspringen
            if not main_description.strip():
                print(f"   • Aufgabe {exercise_id}: kein Beschreibungstext gefunden, überspringe.")
                continue

            # 2.5) Alle Unteraufgaben aus der Subcollection "questions" holen
            combined_text = main_description.strip() + "\n\n"
            questions_ref = exercises_ref.document(exercise_id).collection("questions")
            questions = questions_ref.stream()

            for q_doc in questions:
                q_data = q_doc.to_dict()
                q_title = q_data.get("title", "").strip()  # z. B. "a)" oder "b)"
                q_desc = q_data.get("description", "").strip()  # Text der Unteraufgabe

                if q_title and q_desc:
                    combined_text += f"Unteraufgabe {q_title}: {q_desc}\n\n"


            # 3) GPT-Anfrage: gesamten description-Text schicken
            short_desc = get_short_description_from_gpt(combined_text)
            print(combined_text)
            print("->")
            print(short_desc)
            print("______")

            # 4) Update des Dokuments mit dem Feld "shortDescription"
            try:
                exercises_ref.document(exercise_id).update({
                    "shortDescription": short_desc
                })
                print(f"   ✓ shortDescription gespeichert: „{short_desc}“")
            except Exception as e:
                print(f"   ✗ Fehler beim Speichern von shortDescription für Aufgabe {exercise_id}: {e}")

    print("Alle Aufgaben durchlaufen und ggf. annotiert.")


if __name__ == "__main__":
    annotate_exercises_with_short_description()
