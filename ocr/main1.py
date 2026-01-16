import pytesseract
from pdf2image import convert_from_path


pages = convert_from_path("agreement.pdf", 500)

text = ""
start_page = 0
end_page = 2
for i in range(start_page, end_page):
    text += pytesseract.image_to_string(pages[i], lang='eng') + "\n"

with open("Scanned.txt", "w", encoding='utf-8') as f:
    f.write(text)


