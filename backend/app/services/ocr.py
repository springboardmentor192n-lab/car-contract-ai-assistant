import easyocr
from pdf2image import convert_from_path
import numpy as np
from PIL import Image

reader = easyocr.Reader(['en'], gpu=False)


def extract_text_from_image(image_path: str) -> str:
    image = Image.open(image_path)
    image_np = np.array(image)
    results = reader.readtext(image_np, detail=0)
    return " ".join(results)


def extract_text_from_pdf(pdf_path: str) -> str:
    pages = convert_from_path(pdf_path)
    text = []

    for page in pages:
        image_np = np.array(page)
        results = reader.readtext(image_np, detail=0)
        text.extend(results)

    return " ".join(text)


def extract_text(file_path: str) -> str:
    if file_path.lower().endswith(".pdf"):
        return extract_text_from_pdf(file_path)
    else:
        return extract_text_from_image(file_path)
