import easyocr
from pdf2image import convert_from_path
from PIL import Image
import os
reader = easyocr.Reader(['en'], gpu=False)

def extract_text_ocr(file_path):
    """
    Extracts text from scanned PDFs or image files using EasyOCR.
    """
    text = ""

    file_extension = os.path.splitext(file_path)[1].lower()

    if file_extension == ".pdf":
        images = convert_from_path(file_path)
    else:
        images = [Image.open(file_path)]

    for img in images:
        results = reader.readtext(img)
        for (_, line, _) in results:
            text += line + " "

    return text
