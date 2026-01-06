import pdfplumber

with pdfplumber.open("car_lease.pdf") as pdf:
    text = ""
    for page in pdf.pages:
        text += page.extract_text()

print(text)
