import aspose.pdf as ap

input_pdf = "backend/BeispielPruefung2024.pdf"

output_tex = "backend/pdf-to-latex-test/BeispielPruefung2024Gen.tex"

document = ap.Document(input_pdf)

# TeX-Export-Optionen setzen
options = ap.LaTeXSaveOptions()

document.save(output_tex, options)