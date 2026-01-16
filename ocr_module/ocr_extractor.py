import easyocr
from PIL import Image
import os

reader = easyocr.Reader(['en'], gpu=False)

def extract_text_ocr(file_path):
    """
    OCR is applied ONLY for image files.
    PDFs are NOT processed here.
    """

    text = ""
    extension = os.path.splitext(file_path)[1].lower()

    if extension not in [".jpg", ".jpeg", ".png"]:
        return text  # Skip OCR for PDFs completely

    image = Image.open(file_path)
    results = reader.readtext(image)

    for (_, line, _) in results:
        text += line + " "

    return text
