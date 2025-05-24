import base64
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, firestore
import openai

# Initialize OpenAI client
token = ""
client = openai.OpenAI(api_key=token)

def init_firebase():
    """
    Initialisiert die Verbindung zu Firebase Firestore.
    """
    cred = credentials.Certificate("E:/Studium-git/abimind-2caf8-firebase-adminsdk-fbsvc-be13487a7f.json")
    firebase_admin.initialize_app(cred)
    return firestore.client()

def frage_alle_questions_mit_bildern_aus_firestore(
    db,
    user_uid: str,
    exam_uid: str,
    aufgabe_uid: str,
    frage_template: str
) -> dict[str, str]:
    """
    Für jede Teilaufgabe (Question) einer Exercise wird der GPT-Request ausgeführt.
    Die Schülerlösung (answer_image) wird aus der user-Collection geladen.
    Gibt ein Mapping von Question-ID zu GPT-Antwort zurück.
    """
    # 1) Schülerantwort (einzelner Base64-String) laden
    answer_ref = (
        db.collection("user").document(user_uid)
          .collection("exams").document(exam_uid)
          .collection("exercises").document(aufgabe_uid)
    )
    answer_snap = answer_ref.get()
    if not answer_snap.exists:
        raise ValueError(
            f"Keine Schülerantwort gefunden für User '{user_uid}', Exam '{exam_uid}', Exercise '{aufgabe_uid}'."
        )
    student_data = answer_snap.to_dict()
    student_img_b64 = student_data.get("answer_image")
    if not isinstance(student_img_b64, str):
        raise ValueError("Das Feld 'answer_image' muss ein Base64-codierter String sein.")

    # 2) Exercise-Daten abrufen
    ex_ref = db.collection("exams").document(exam_uid)
    ex_snap = ex_ref.collection("exercises").document(aufgabe_uid).get()
    if not ex_snap.exists:
        raise ValueError(
            f"Exercise '{aufgabe_uid}' nicht gefunden in Exam '{exam_uid}'."
        )
    exercise_data = ex_snap.to_dict()

    # Bereite die gemeinsamen Bilder vor (Exercise-Level + Schülerbild)
    bilder_common = []
    # Exercise-Level Bilder (falls vorhanden)
    for img in exercise_data.get("images", []):
        bilder_common.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/png;base64,{img['content']}"}
        })
    # Schülerbild einmalig anhängen
    bilder_common.append({
        "type": "image_url",
        "image_url": {"url": f"data:image/png;base64,{student_img_b64}"}
    })

    # 3) Über alle Questions iterieren
    responses: dict[str, str] = {}
    questions = ex_ref.collection("exercises").document(aufgabe_uid)\
                     .collection("questions").stream()

    for q_doc in questions:
        q_data = q_doc.to_dict()
        q_id   = q_doc.id
        q_title= q_data.get("title", q_id)

        # Pro Frage die Bilderliste frisch anlegen
        bilder = bilder_common.copy()
        # Question-Level Bilder
        for img in q_data.get("images", []):
            bilder.append({
                "type": "image_url",
                "image_url": {"url": f"data:image/png;base64,{img['content']}"}
            })
        # Musterlösungs-Bilder
        for img in q_data.get("solution_images", []):
            bilder.append({
                "type": "image_url",
                "image_url": {"url": f"data:image/png;base64,{img['content']}"}
            })

        # Prompt-Text
        prompt_text = (
            f"{frage_template}\n"
            f"Aufgabe: {exercise_data.get('title', '')} — Teilaufgabe: {q_title}\n"
            f"{exercise_data.get('description', '')}\n"
            f"{q_data.get('description', '')}\n"
            f"Lösung:\n{q_data.get('solution', '')}"
        )

        # API-Call
        resp = client.chat.completions.create(
            model="gpt-4.1",
            messages=[
                { "role": "user",
                  "content": [ *bilder, { "type": "text", "text": prompt_text } ]
                }
            ],
            max_tokens=1500
        )
        responses[q_id] = resp.choices[0].message.content.strip()

    return responses

def correctExercice(user_uid : str, exam_uid : str, aufgabe_uid : str):
    db = init_firebase()
    frage_template = (
        "Du bekommst hier eine Mathe-Abituraufgabe und die Musterlösung. "
        "Außerdem als Bild(er) eine Schülerlösung. Vergleiche beide Lösungen und bewerte die Schülerlösung. "
        "Wenn die Schülerlösung falsch ist, korrigiere sie und gebe einen Lösungsweg vor. Beachte, dass die Aufgabe nicht exakt gleich wie die Musterlösung sein muss. WIchtig ist, dass das Ergebnis richtig bzw. der Lösungsweg im Rahmen der Musterlösung nachvollziehbar ist."
        "Bewerte es auch als falsch, wenn ein notwendiger Lösungsweg in der Schülerlösung fehlt. "
        "Schreibe nur die Korrektur, nichts drum herum. Arbeite die Teilaufgaben nacheinander ab. "
        "Schreibe zunächst zu jeder Teilaufgabe ob sie richtig oder falsch gelöst wurde, dann, wenn sie falsch war, die Korrektur. " 
        "Wenn die Aufgabe richtig ist, schreibe nur 'richtig', wenn sie falsch ist, schreibe 'falsch,' und dann die Korrektur."
        "Gebe nicht die Aufgabenstellung wieder. Mache am Ende keine Zusammenfassung der Teilaufgaben. "
        "Mache bei richtigen Teilaufgaben keinerlei Anmerkung außer der Angabe, dass sie richtig ist. "
        "Spreche den Schüler bei den Korrekturvorschlägen direkt an. Verhalte dich wie ein Lehrer."
    )

    ergebnisse = frage_alle_questions_mit_bildern_aus_firestore(
        db=db,
        user_uid=user_uid,
        exam_uid=exam_uid,
        aufgabe_uid=aufgabe_uid,
        frage_template=frage_template
    )

    full_correction_text = ""
    for qid, antwort in ergebnisse.items():
        full_correction_text += f"{{{qid}}}\n{antwort}\n\n"

    exercise_ref = (
        db.collection("user").document(user_uid)
          .collection("exams").document(exam_uid)
          .collection("exercises").document(aufgabe_uid)
    )

    exercise_ref.update({ "correction": full_correction_text.strip() })

    # Optional zur Kontrolle ausgeben
    print("Korrektur erfolgreich gespeichert:")
    print(full_correction_text)


def main():
    db = init_firebase()
    frage_template = (
        "Du bekommst hier eine Mathe-Abituraufgabe und die Musterlösung. "
        "Außerdem als Bild(er) eine Schülerlösung. Vergleiche beide Lösungen und bewerte die Schülerlösung. "
        "Wenn die Schülerlösung falsch ist, korrigiere sie und gebe einen Lösungsweg vor. Beachte, dass die Aufgabe nicht exakt gleich wie die Musterlösung sein muss. WIchtig ist, dass das Ergebnis richtig bzw. der Lösungsweg im Rahmen der Musterlösung nachvollziehbar ist."
        "Bewerte es auch als falsch, wenn ein notwendiger Lösungsweg in der Schülerlösung fehlt. "
        "Schreibe nur die Korrektur, nichts drum herum. Arbeite die Teilaufgaben nacheinander ab. "
        "Schreibe zunächst zu jeder Teilaufgabe ob sie richtig oder falsch gelöst wurde, dann, wenn sie falsch war, die Korrektur. " 
        "Wenn die Aufgabe richtig ist, schreibe nur 'richtig', wenn sie falsch ist, schreibe 'falsch,' und dann die Korrektur."
        "Gebe nicht die Aufgabenstellung wieder. Mache am Ende keine Zusammenfassung der Teilaufgaben. "
        "Mache bei richtigen Teilaufgaben keinerlei Anmerkung außer der Angabe, dass sie richtig ist. "
        "Spreche den Schüler bei den Korrekturvorschlägen direkt an. Verhalte dich wie ein Lehrer."
        "Bewerte die Teilaufgaben als Ganzes. Auch wenn sie auf mehrere Bilder verteilt sind. Die Korrektur soll die gesamte Schülerlösung über mehrere Bilder hinweg berücksichtigen."
    )

    ergebnisse = frage_alle_questions_mit_bildern_aus_firestore(
        db=db,
        user_uid="TNddezDjmEYDGEx0HdcMWvEQVbv1",
        exam_uid="BLILtj4qkTk5RJVM1sfH",
        aufgabe_uid="09Xxx1t1RT59AgyJhBsi",
        frage_template=frage_template
    )

    full_correction_text = ""
    for qid, antwort in ergebnisse.items():
        full_correction_text += f"{{{qid}}}\n{antwort}\n\n"

    exercise_ref = (
        db.collection("user").document("TNddezDjmEYDGEx0HdcMWvEQVbv1")
          .collection("exams").document("BLILtj4qkTk5RJVM1sfH")
          .collection("exercises").document("09Xxx1t1RT59AgyJhBsi")
    )

    exercise_ref.update({ "correction": full_correction_text.strip() })

    # Optional zur Kontrolle ausgeben
    print("Korrektur erfolgreich gespeichert:")
    print(full_correction_text)


if __name__ == '__main__':
    main()