import easyocr
from pdf2image import convert_from_path

# Initialize EasyOCR reader (English)
reader = easyocr.Reader(['en'], gpu=False)

def extract_text_ocr(pdf_path):
    """
    Extracts text from scanned PDFs using EasyOCR.
    """
    text = ""

    # Convert PDF pages to images
    images = convert_from_path(pdf_path)

    for img in images:
        results = reader.readtext(img)
        for (_, line, _) in results:
            text += line + " "

    return text
