import easyocr

reader = easyocr.Reader(['ch_sim','en']) # this needs to run only once to load the model into memory

result = reader.readtext('backend/BeispielPruefungAlsBild/BeispielPruefung2024-001.png')

# Text aus der Liste extrahieren und zu einem String formatieren
extracted_text = "\n".join([text for _, text, _ in result])

# Text in eine Datei schreiben
with open("backend/ocr/output.txt", "w", encoding="utf-8") as f:
    f.write(extracted_text)