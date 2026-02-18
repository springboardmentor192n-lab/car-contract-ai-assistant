import os
import pdfplumber
import pytesseract
from pdf2image import convert_from_path
from PIL import Image

# Tesseract common paths for Windows
TESSERACT_PATHS = [
    r"C:\Program Files\Tesseract-OCR\tesseract.exe",
    r"C:\Program Files (x86)\Tesseract-OCR\tesseract.exe",
    os.path.join(os.environ.get("USERPROFILE", ""), r"AppData\Local\Tesseract-OCR\tesseract.exe")
]

def get_tesseract_command():
    # 1. Check common installation paths
    for path in TESSERACT_PATHS:
        if os.path.exists(path):
            return path
    # 2. Check if it's in the system PATH
    import shutil
    if shutil.which("tesseract"):
        return "tesseract"
    return None

pytesseract.pytesseract.tesseract_cmd = get_tesseract_command()

def check_tesseract():
    if not pytesseract.pytesseract.tesseract_cmd:
        raise RuntimeError(
            "Tesseract OCR not found. Please install it from: https://github.com/UB-Mannheim/tesseract/wiki"
        )

def extract_text_pdfplumber(pdf_path):
    text = ""
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()
            if page_text:
                text += page_text + "\n"
    return text.strip()

def extract_text_from_pdf_ocr(pdf_path):
    check_tesseract()
    images = convert_from_path(pdf_path)
    text = ""
    for img in images:
        text += pytesseract.image_to_string(img) + "\n"
    return text.strip()

def extract_text_from_image(image_path):
    check_tesseract()
    img = Image.open(image_path)
    return pytesseract.image_to_string(img)

def extract_text_pipeline(file_path):
    ext = os.path.splitext(file_path)[1].lower()

    if ext == ".pdf":
        text = extract_text_pdfplumber(file_path)
        return text if len(text) > 200 else extract_text_from_pdf_ocr(file_path)

    elif ext in [".jpg", ".jpeg", ".png"]:
        return extract_text_from_image(file_path)

    else:
        raise ValueError("Unsupported file format")