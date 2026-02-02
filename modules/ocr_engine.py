import pdfplumber
import pytesseract
from PIL import Image

# Configuration for Windows
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

def get_text_from_file(uploaded_file):
    try:
        if uploaded_file.name.lower().endswith(".pdf"):
            with pdfplumber.open(uploaded_file) as pdf:
                return "".join([page.extract_text() or "" for page in pdf.pages])
        else:
            img = Image.open(uploaded_file)
            return pytesseract.image_to_string(img)
    except Exception as e:
        return f"OCR Error: {str(e)}"