import openai
import base64
from pathlib import Path

client = openai.OpenAI(api_key="")

def encode_image_to_base64(pfad):
    with open(pfad, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")

def frage_mit_bildern(bild_dateinamen, frage):
    file = __file__
    basis_pfad = Path(file).parent

    bilder = [
        {
            "type": "image_url",
            "image_url": {
                "url": f"data:image/png;base64,{encode_image_to_base64(Path.joinpath(basis_pfad, dateiname))}"
            }
        }
        for dateiname in bild_dateinamen
    ]

    response = client.chat.completions.create(  # ← das ist neu
        model="gpt-4.1",
        messages=[
            {"role": "user", "content": [*bilder, {"type": "text", "text": frage}]}
        ],
        max_tokens=1000
    )

    return response.choices[0].message.content.strip()

# Beispiel-Nutzung
if __name__ == "__main__":
    # richtig: dateinamen = ["r P1.png", "r P1 2.png", "2025_04_10_061d85015d58a3a45928g-2.jpg"]
    dateinamen = ["f P1.png", "2025_04_10_061d85015d58a3a45928g-2.jpg"]
    frage = "Du bekommst hier eine Mathe-Abituraufgabe und die Musterlösung." \
            "Außerdem als Bild eine Schülerlösung. Vergleiche beide Lösungen und bewerte die Schülerlösung." \
            "Wenn die Schülerlösung falsch ist, korrigiere sie und gebe einen Lösungsweg vor." \
            "Bewerte es auch als falsch, wenn ein notwendiger Lösungsweg in der Schülerlösung fehlt." \
            "Schreibe nur die Korrektur, nichts drum herum. Arbeite die Teilaufgaben nacheinander ab. Schreibe zunächst zu jeder Teilaufgabe ob sie richtig oder falsch gelöst wurde, dann, wenn sie falsch war, die Korrektur. Gebe nicht die Aufgabenstellung wieder. Mache am Ende keine Zusammenfassung der Teilaufgaben. Mache bei richtigen Teilaufgaben keinerlei Anmerkung außer der Angabe, dass sie richtig ist. Spreche den Schüler bei den Korrekturvorschlägen direkt an." \
            "Aufgabe:" \
            "\section*{Aufgabe P1: (2 BE und 3 BE)}"\
            "Die Abbildung zeigt den Graphen $G_{f}$ der in $\mathbb{R}$ definierten Funktion $f$ mit $f(x)=2 \cdot \sin \left(\frac{1}{2} x\right)$.\\" \
            "\includegraphics[max width=\textwidth, center]{2025_04_10_061d85015d58a3a45928g-2}\\" \
            "a) Beurteilen Sie mithilfe der Abbildung, ob der Wert des Integrals $\int_{-2}^{8} f(x) d x$ negativ ist.\\" \
            "b) Weisen Sie rechnerisch nach, dass die folgende Aussage zutriff: Die Tangente an $\mathrm{G}_{\mathrm{f}}$ im Koordinatenursprung ist die Gerade durch die Punkte (-1|-1) und (1|1)." \
            "Lösung:" \
            "\section*{Aufgabe P1:}" \
            "a) Das Integral beschreibt den orientierten Inhalt der Fläche, die der Graph $G_{f}$, die $x$-Achse und die senkrechten Geraden $x=-2$ und $x=8$ einschließen.\\" \
            "Da der Flächeninhalt oberhalb der $x$-Achse größer ist als der Flächeninhalt unterhalb der x-Achse, ist der Wert des Integrals positiv, also nicht negativ.\\" \
            "b) Tangentengleichung im Ursprung $\mathrm{O}(0 \mid 0)$ :" \
            "Allgemeine Tangentengleichung: $y=f^{\prime}(u) \cdot(x-u)+f(u)$\\" \
            "Einsetzen der Berührstelle $u=0: y=f^{\prime}(0) \cdot(x-0)+f(0)$\\" \
            "Es gilt $f(0)=2 \cdot \sin (0)=0$.\\" \
            "Wegen $f^{\prime}(x)=2 \cdot \cos \left(\frac{1}{2} x\right) \cdot \frac{1}{2}=\cos \left(\frac{1}{2} x\right)$ gilt $f^{\prime}(0)=\cos (0)=1$.\\" \
            "Gleichung der Tangente: $y=1 \cdot(x-0)+0 \Leftrightarrow y=x$\\" \
            "Da die Gerade $y=x$ durch die Punkte (-1|-1) und (1|1) verläuft ist nachgewiesen, dass die Aussage richtig ist."
    antwort = frage_mit_bildern(dateinamen, frage)
    print("\nAntwort:\n", antwort)
