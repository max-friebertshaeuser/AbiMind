import base64
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, storage, firestore
import openai

client = openai.OpenAI(api_key="")

def init_firebase():
    cred = credentials.Certificate("")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    return db

def encode_image_to_base64(image_path: Path) -> str:
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    return encoded_string

def lade_aufgabe_aus_firestore(db, fach: str, jahr: str, teil: str, aufgabe_name: str):
    doc_ref = db.collection("Abitur").document(f"{fach}_{jahr}")
    doc = doc_ref.get()
    if doc.exists:
        daten = doc.to_dict()
        aufgabe = daten.get(teil, {}).get(aufgabe_name)
        if aufgabe:
            return aufgabe  # enthält alle relevanten Felder
    return None

def frage_mit_bildern_aus_firestore(db, fach, jahr, teil, aufgabe_name, schueler_bild_dateinamen, frage_template):
    aufgabe_daten = lade_aufgabe_aus_firestore(db, fach, jahr, teil, aufgabe_name)
    if not aufgabe_daten:
        return "Fehler: Aufgabe nicht gefunden."

    bilder = []

    # Bilder aus der Aufgabenstellung
    for base64_bild in aufgabe_daten["aufgabe_bilder"]:
        bilder.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/png;base64,{base64_bild}"}
        })

    # Bilder aus der Lösung
    for base64_bild in aufgabe_daten["loesung_bilder"]:
        bilder.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/png;base64,{base64_bild}"}
        })

    # Schülerlösung (lokal)
    file = __file__
    basis_pfad = Path(file).parent
    for dateiname in schueler_bild_dateinamen:
        bilder.append({
            "type": "image_url",
            "image_url": {
                "url": f"data:image/png;base64,{encode_image_to_base64(Path.joinpath(basis_pfad, dateiname))}"
            }
        })

    # Textinhalt zusammensetzen
    text = frage_template + \
        f"\nAufgabe:\n{aufgabe_daten['aufgabe_text']}\n" \
        f"Lösung:\n{aufgabe_daten['loesung_text']}"

    response = client.chat.completions.create(
        model="gpt-4.1",
        messages=[
            {"role": "user", "content": [*bilder, {"type": "text", "text": text}]}
        ],
        max_tokens=1500
    )

    return response.choices[0].message.content.strip()


if __name__ == "__main__":
    db = init_firebase()
    schueler_bilder = ["r P1.png", "r P1 2.png"]

    frage_template = (
        "Du bekommst hier eine Mathe-Abituraufgabe und die Musterlösung. "
        "Außerdem als Bild(er) eine Schülerlösung. Vergleiche beide Lösungen und bewerte die Schülerlösung. "
        "Wenn die Schülerlösung falsch ist, korrigiere sie und gebe einen Lösungsweg vor. "
        "Bewerte es auch als falsch, wenn ein notwendiger Lösungsweg in der Schülerlösung fehlt. "
        "Schreibe nur die Korrektur, nichts drum herum. Arbeite die Teilaufgaben nacheinander ab. "
        "Schreibe zunächst zu jeder Teilaufgabe ob sie richtig oder falsch gelöst wurde, dann, wenn sie falsch war, die Korrektur. "
        "Gebe nicht die Aufgabenstellung wieder. Mache am Ende keine Zusammenfassung der Teilaufgaben. "
        "Mache bei richtigen Teilaufgaben keinerlei Anmerkung außer der Angabe, dass sie richtig ist. "
        "Spreche den Schüler bei den Korrekturvorschlägen direkt an."
    )

    antwort = frage_mit_bildern_aus_firestore(
        db=db,
        fach="Mathe",
        jahr="2024",
        teil="Pflichtteil",
        aufgabe_name="Aufgabe P1",
        schueler_bild_dateinamen=schueler_bilder,
        frage_template=frage_template
    )

    print("\nAntwort:\n", antwort)
